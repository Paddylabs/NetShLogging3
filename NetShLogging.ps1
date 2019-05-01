<#
  .SYNOPSIS
  
  .DESCRIPTION
  
  .PARAMETER
  None

  .EXAMPLE
  NetshLogging.ps1

  .INPUTS
  None

  .OUTPUTS
  A TXT file C:\NetshLogs\$date"_NetSHConnections.txt
  An Email to the Authors

  .NOTES
  Author:        Patrick Horne, David Innes
  Creation Date: 01/05/19
  Requires:      

  Change Log:
  V1.0:         Initial Development
  V1.1:         Added Email Notification and disk space percentage
  
#>

$date = Get-Date -Format "yyyy-MM-dd-HH-mm-ss"
$disk = Get-WmiObject Win32_LogicalDisk  -Filter "DeviceID='C:'"
$PercFree = ($disk.FreeSpace/$disk.Size*100)

DO

{
If ($PercFree -lt 20) {break}

$NetLogging = Netsh Interface IPv4 Show tcpConnections
$NetLogging | Select-String "Established" | Out-File C:\NetshLogs\$date"_NetSHConnections.txt" -Append

Start-Sleep -Milliseconds 250

$disk = Get-WmiObject Win32_LogicalDisk  -Filter "DeviceID='C:'"
$PercFree = ($disk.FreeSpace/$disk.Size*100)

If ($PercFree -lt 20) {break}

} While ($PercFree -gt 20)

$DiskSpace = [Math]::round($PercFree,2)

$EmailSplat = @{
    To         = "user1@emailaddress.com","user2@emailaddress.com"
    Subject    = "Free Disk Space on $env:computername is below minimum. Logging Stopped."
    Body       = "Free Disk Space on $env:computername is $DiskSpace. Logging Stopped."
    SmtpServer = "relay.smtpserver.com"
    From       = "NoReply@smtpserver.com"

}

Send-MailMessage @EmailSplat
