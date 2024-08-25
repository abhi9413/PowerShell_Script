try {
    # Define variables
    $date = Get-Date -Format "yyyyMMdd"
    $subjectExists = "Success! XYZ_$date"
    $subjectNotGenerated = "Alert! XYZ_$date"
    $runPath = "C:\Users\Abhijit\Documents\File Alert"
    $fileName1 = "fileName1_$date.csv"
    $fileName2 = "fileName2_$date.csv"

    # Logging start of script
    Write-Host "Script execution started: $(Get-Date)"

    # Combine run path with file names
    $filePath1 = Join-Path $runPath $fileName1
    $filePath2 = Join-Path $runPath $fileName2

    # Logging file paths
    Write-Host "File path 1: $filePath1"
    Write-Host "File path 2: $filePath2"

    # Check if both files exist
    if ((Test-Path $filePath1) -and (Test-Path $filePath2)) {
        # Files exist, send confirmation email with modified subject and body
        $body = "<font color='blue-gray'>"
        $body += "Hi All,<br>Greetings of the day!<br><br>"
        $body += "New file has been placed in the desired location for last week.<br>"
        $body += "If an issue has been encountered, please raise a call with Logik for the attention of the respective team.<br><br>"
        $body += "File Path: $runPath<br><br>"
        $body += "<table border='3'>"
        $body += "<tr><th>File Name</th></tr>"
        $body += "<tr><td>$fileName1</td></tr>"
        $body += "<tr><td>$fileName2</td></tr>"
        $body += "</table><br><br>"
        $body += "Best Regards,<br>"
        $body += "<font size='4'>XYZ</font>"
        $body += "</font>"
        $subject = "$subjectExists"
    } else {
        $body = "<font color='blue-gray'>"
        $body += "Hi All,<br>Greetings of the day!<br><br>"
        $body += "New file has <strong>NOT</strong> been generated for last week.<br>"
        $body += "Please raise a call with Logik for the attention of the respective team.<br><br>"
        $body += "File Path: $runPath<br><br>"
        $body += "<table border='3'>"
        $body += "<tr><th>Missing File Name</th></tr>"
        $body += "<tr><td>$fileName1</td></tr>"
        $body += "<tr><td>$fileName2</td></tr>"
        $body += "</table><br><br>"
        $body += "Best Regards,<br>"
        $body += "<font size='4'>XYZ</font>"
        $body += "</font>"
        $subject = "$subjectNotGenerated"
    }

    # Logging email details
    Write-Host "Email subject: $subject"
    Write-Host "Email body: $body"

    # Send email
    $msg1 = New-Object Net.Mail.MailMessage
    $smtp1 = New-Object Net.Mail.SmtpClient("smtpclient@server.com")
    $msg1.From = "XYZ@gmail.com"
    $msg1.To.Add("xyz@gmail.com")
    $msg1.Subject = $subject
    $msg1.IsBodyHtml = $true
    $msg1.Body = $body
    $smtp1.Send($msg1)

    # Logging email sent
    Write-Host "Email sent successfully."

    # Logging end of script
    Write-Host "Script execution completed: $(Get-Date)"
} catch {
    # Error occurred, log error message
    Write-Host "Error occurred: $_"
}
