$Host.UI.RawUI.WindowTitle = "Setup Host"
$dataUrl = "http://169.254.169.254/latest/meta-data"
$hostNameRaw = Invoke-WebRequest "$dataUrl/local-hostname" | foreach {$_.Content.split(".")[0]}

$hostName = $hostNameRaw.substring(0,$hostNameRaw.Length).toUpper()

if ((${env:computerName} -ne $hostName) -and ($hostName -ne $null)){
  Rename-Computer $hostName

  Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name AutoLogonCount
  Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -name AutoAdminLogon -value 0

  # Expire Administrator password
  $user = [ADSI]'WinNT://localhost/Administrator'
  $user.passwordExpired = 1
  $user.setinfo()


  Restart-Computer -Force
}