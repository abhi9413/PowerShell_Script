$requesterName = "$(Release.RequestedForEmail)"
$ServerName = hostname

Write-Host "Waiting for 2 minutes before checking the services..."
Start-Sleep -Seconds 120

# List of services to monitor
$monitorServices = @("services.Name1", "services.Name2",...)
$allServices = Get-WmiObject -Class Win32_Service
# Filter services based on names or descriptions
$services = $allServices | Where-Object { $monitorServices -contains $_.Name -or $monitorServices -contains $_.Description }

#Get all services with descriptions starting with "XYZ"
#$services Get-wmiobject -Query "Select from win32_service" select-object Name, state, Description ?{$_.Description like 'XYZ*')

$allRunning = $true
$errorMessages = @()
# Initialize a flag to track if all services are running
$allRunning = $true

# Initialize the HTML body for the email
$emailBody = @"
<html>
<head>
<style>
table {
    border-collapse: collapse;
    width: 95%;
    margin: 8px;
}
th, td {
    border: 1px solid #dddddd;
    text-align: center;
    padding: 6px;
    background-color: #FFFFFF;
}
th {
    background-color: #D3D3D3;
    color: #000000;
}
p {
    margin-bottom: 3px;
}
</style>
</head>
<body>
<p>Hi All,
<br>
Greetings of the day!</p>
<p>This is the status of the services which are available on the <i><b>$ServerName.</b></i><br>
Here are the details :-
<ul>
<li><strong>Pipeline Name:</strong> $(Release.DefinitionName)</li>
<li><strong>Release Number:</strong> $(Release.ReleaseName)</li>
<li><strong>Release URL:</strong> $(System.TeamFoundationCollectionUri)$(System.TeamProject)/_release?releaseId=$(Release.ReleaseId)</li>
</ul>
<br>
<br>
<table border="1" cellpadding="5" cellspacing="0" style="border-collapse: collapse;">
<tr>
<th>Service Name</th>
<th>Description</th>
<th>Status</th>
</tr>
"@

foreach ($service in $services) {
    $status = if ($service.State -eq "Running") { "Running" } else { "Not Running" }
    $color = if ($service.State -eq "Running") { "green" } else { "red" }
    $dot = if ($service.State -eq "Running") { "&#x1F7E2;" } else { "&#x1F534;" } # Unicode characters for green and red dots

    # Append service status to the email body
    $emailBody += @"
<tr>
<td>$($service.Name)</td>
<td>$($service.Description)</td>
<td><span style="color: $color">$dot $status</span></td>
</tr>
"@

    if ($service.State -ne "Running") {
        Write-Host "Service $($service.Name) ($($service.Description)) is not running. Current state: $($service.State)"
        $allRunning = $false
    } else {
        Write-Host "Service $($service.Name) ($($service.Description)) is running."
    }
}
# Close the HTML tags
$emailBody += @"
</table>
"@
# Add different message and subject based on the status
if ($allRunning) {
    $emailBody += "<p>All services are running smoothly.</p>"
    $subject = "Success! Services of XYZ Pipeline"
} else {
    $emailBody += "<p><b style='background-color: #FFFF00;'>Note: One or more services are not running, please check with team.</b></p>"
    $subject = "Alert! Services of XYZ Pipeline"
}

# Close the HTML tags
$emailBody += @"
</table>
<br>
<br>
<p>Best Regards,</p>
<p style='font-size: 16.0pt; font-family: "Georgia", serif; color: #470054;'>XYZ TEAM</p>
<p>Email id: xyz@email.com</p>
</body>
</html>
"@

# Send an email with the service status
$msg1 = New-Object Net.Mail.MailMessage
$smtp1 = New-Object Net.Mail.SmtpClient("smtpclient@server.com")
$msg1.From = "XYZ@gmail.com"
$msg1.To.Add("XYZ@gmail.com")
$msg1.CC.Add($requesterName)
$msg1.Subject = $subject
$msg1.IsBodyHtml = $true
$msg1.Body = $emailBody
$smtp1.Send($msg1)

# If not all services are running, raise an error
if (-not $allRunning) {
    Write-Error "One or more services are not running. Failing the pipeline."
    exit 1
}
