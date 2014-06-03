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
