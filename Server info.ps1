# Get basic system information
$hostname = hostname
$systemInfo = Get-WmiObject Win32_ComputerSystem
$operatingSystem = Get-WmiObject Win32_OperatingSystem
$networkAdapter = Get-WmiObject Win32_NetworkAdapterConfiguration | Where-Object { $_.IPAddress -ne $null }

# Display basic system information
$output = @"
System Information:
------------------------------
Manufacturer: $($systemInfo.Manufacturer)
Model: $($systemInfo.Model)
OS Name: $($operatingSystem.Caption)
OS Version: $($operatingSystem.Version)
System Type: $($systemInfo.SystemType)
Total Physical Memory: $([math]::Round($systemInfo.TotalPhysicalMemory / 1GB, 2)) GB
Hostname: $($hostname)
IP Address: $($networkAdapter.IPAddress)

"@

# Get CPU information
$cpuInfo = Get-WmiObject Win32_Processor

# Display CPU information
$output += @"
CPU Information:
------------------------
Name: $($cpuInfo.Name)
Manufacturer: $($cpuInfo.Manufacturer)
Number of Cores: $($cpuInfo.NumberOfCores)
Number of Logical Processors: $($cpuInfo.NumberOfLogicalProcessors)

"@

# Get drive space information
$driveInfo = Get-WmiObject Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 }

# Display drive space information
$output += @"
Drive Space Information:
--------------------

"@
foreach ($drive in $driveInfo) {
    $output += @"
Drive Letter: $($drive.DeviceID)
Volume Name: $($drive.VolumeName)
File System: $($drive.FileSystem)
Total Size: $([math]::Round($drive.Size / 1GB, 2)) GB
Free Space: $([math]::Round($drive.FreeSpace / 1GB, 2)) GB

"@
}

$output +=@"
===========================================================================================================

"@
#Write the output to a text file
#$output Out-File -FilePath "C:\system_info.txt"

#-----------------------------------------------------------------------------------------------------------------------------------------------------------
# Web site and web application information

$output += @"

#####WEB SITES & WEB APP INFORMATION#####


"@

# Get the list of websites
$websites = Get-Website

# Iterate through each website
foreach ($website in $websites) {
    $websiteName = $website.Name
    $bindings = $website.Bindings.Collection
    $physicalPath = $website.physicalPath
    $websiteAppPool = $website.applicationPool
    $state = $website.State

    # Output the website details
    $output += @"
Website Name: $websiteName
Physical Path: $physicalPath
App Pool: $websiteAppPool
State: $state
Bindings:
"@
    foreach ($binding in $bindings) {
        $output += @"
Protocol: $($binding.Protocol), IP Address: $($binding.BindingInformation)
"@
    }

    $output += @"
The applications hosted are as follows:

"@
    #Get the list of applications hosted under the website
    $applications = Get-WebApplication -Site $websiteName

    #Output the applications hosted under the website
    foreach ($app in $applications) {
        $output += @"
Application: $($app.Path)
App Pool: $($app.applicationPool)
Physical Path: $($app.PhysicalPath)
"@
    }

    $output += @"
-------------------------------------
"@
}
$output += @"
===============================================================================================
#####APPLICATION POOLS INFORMATION#####

"@
$output | Out-File -FilePath "C:\$hostname.txt"

# Get application pool details
Get-ChildItem IIS:\AppPools | ForEach-Object {
    [PSCustomObject]@{
        Name = $_.Name
        Status = $_.State
        DotNetCLRVersion = $_.ManagedRuntimeVersion
        ManagedPipelineMode = $_.ManagedPipelineMode
        Identity = $_.ProcessModel.IdentityType
    }
} | Out-File "C:\$hostname.txt" -Append

# Marker for services information
$marker = @"
==========================================================================================================
#####SERVICES INFORMATION#####
"@ | Out-File "C:\$hostname.txt" -Append

# Get the services whose description contains "NAME XYZ"
$services = Get-WmiObject -Query "SELECT * FROM Win32_Service" | Select-Object Name, State, StartMode, Description | Where-Object { $_.Description -like 'NAME XYZ*' }

# Format the services as a table and export to a text file
$services | Format-Table -AutoSize | Out-File "C:\$hostname.txt" -Append

# Marker for scheduled tasks information
$marker = @"
==============================================================================================================

#####SCHEDULED TASKS INFORMATION#####
"@ | Out-File "C:\$hostname.txt" -Append

# Retrieve all scheduled tasks
$scheduledTasks = Get-ScheduledTask

# Filter out Windows tasks and display the remaining tasks
$scheduledTasks | Format-Table TaskName, TaskPath, State -Wrap | Out-File "C:\$hostname.txt" -Append

# Marker for MSMQ information
$marker = @"
=======================
#####MSMQ INFORMATION#####
"@ | Out-File "C:\$hostname.txt" -Append

# Fetch private MSMQ details
$privateQueues = Get-MsmqQueue -QueueType Private

# Output the details
$privateQueues | Format-Table QueueName, Transactional, Path -Wrap | Out-File "C:\$hostname.txt" -Append
