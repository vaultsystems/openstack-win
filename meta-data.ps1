$Host.UI.RawUI.WindowTitle = "Setup Host"
$dataUrl = "http://169.254.169.254/latest/meta-data"
$hostName = Invoke-WebRequest "$dataUrl/local-hostname" | foreach {$_.Content.split(".")[0].substring(0,10).toUpper()}

if (${env:computerName} -ne $hostName){
  Rename-Computer $hostName

  Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name AutoLogonCount
  Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -name AutoAdminLogon -value 0

  Restart-Computer -Force
}