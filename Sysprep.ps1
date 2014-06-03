# Finalize and cleanup
Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name Unattend*
Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name AutoLogonCount
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -name AutoAdminLogon -value 0

# Download Sysprep Config
$sysprepUrl = "https://raw.githubusercontent.com/jnsolutions/openstack-win/master/sysprep.xml"
$sysprepFile = "$ENV:Temp\sysprep.xml"
Invoke-WebRequest $sysprepUrl -OutFile $sysprepFile

Expire Administrator password
$user = [ADSI]'WinNT://localhost/Administrator'
$user.passwordExpired = 1
$user.setinfo()

iex "cmd.exe /c netsh winhttp reset proxy"

& "$ENV:SystemRoot\System32\Sysprep\Sysprep.exe" `/generalize `/oobe `/shutdown `/unattend:"$sysprepFile"
