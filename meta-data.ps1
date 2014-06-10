$Host.UI.RawUI.WindowTitle = "Setup Host"
$dataUrl = "http://169.254.169.254/latest/meta-data"
$hostName = Invoke-WebRequest "https://gist.githubusercontent.com/noma4i/573198ec8246607aa10a/raw/1da130cec1aa0718cf442d02b6a66a880aa7c072/gistfile1.txt" | foreach {$_.Content.split(".")[0].substring(0,10).toUpper()}

if ((${env:computerName} -ne $hostName) -and ($hostName -ne $null)){
  Rename-Computer $hostName

  Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name AutoLogonCount
  Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -name AutoAdminLogon -value 0

  Restart-Computer -Force
}