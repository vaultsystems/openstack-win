$ErrorActionPreference = "Stop"

try
{
    # Setup Proxy
    Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" -Name ProxyEnable -Value 1
    iex "cmd.exe /c netsh winhttp set proxy HERE_GOES_PROXY"

    #SetComputername
    $nameNumber = Test-Connection -ComputerName ${env:computername} -Count 1 | foreach{ $_.IPV4Address.IPAddressToString.split('.')[-1] }
    Rename-Computer "troop$nameNumber"

    # Adding all Roles
    Add-WindowsFeature -Name "NET-Framework-Core" -Source D:\sources\sxs
    Add-WindowsFeature -Name "NFS-Client"
    Add-WindowsFeature -Name "Telnet-Client"
    Add-WindowsFeature -Name "Telnet-Server"
    Add-WindowsFeature -Name "Windows-Identity-Foundation"
    Add-WindowsFeature -Name "RDS-RD-Server"
    Add-WindowsFeature -Name "RDS-Licensing"

    # Download and apply updates
    $psWindowsUpdateUrl = "https://raw.githubusercontent.com/jnsolutions/openstack-win/master/PSWindowsUpdate.zip"
    $psWindowsUpdateFile = "$ENV:Temp\PSWindowsUpdate.zip"

    Invoke-WebRequest $psWindowsUpdateUrl -OutFile $psWindowsUpdateFile
    foreach($item in (New-Object -com shell.application).NameSpace($psWindowsUpdateFile).Items())
    {
        $yesToAll = 16
        (New-Object -com shell.application).NameSpace("$ENV:SystemRoot\System32\WindowsPowerShell\v1.0\Modules").copyhere($item, $yesToAll)
    }
    Import-Module PSWindowsUpdate
    Get-WUInstall -AcceptAll -IgnoreReboot -IgnoreUserInput -NotCategory "Language packs"

    # Settup Hosts to see things
    Set-Content -Path "$ENV:SystemRoot\System32\drivers\etc\hosts" -Value "192.168.240.162 puppet"

    # Downloading PuppetAgent and pointing to server
    $puppetUrl = "http://downloads.puppetlabs.com/windows/puppet-3.6.0-rc1.msi"
    $puppetFile = "$ENV:Temp\puppet-agent.msi"
    $masterServer = "puppet"

    Invoke-WebRequest $puppetUrl -OutFile $puppetFile
    Start-Process -FilePath msiexec -ArgumentList /i, "$puppetFile PUPPET_MASTER_SERVER=$masterServer", /qn

    # Finalize and cleanup
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name Unattend*
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name AutoLogonCount
    Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -name AutoAdminLogon -value 0

    # Expire Administrator password
    $user = [ADSI]'WinNT://localhost/Administrator'
    $user.passwordExpired = 1
    $user.setinfo()

    del $psWindowsUpdateFile

    & "netsh winhttp reset proxy"

    shutdown /s /t 90
}
catch
{
    $host.ui.WriteErrorLine($_.Exception.ToString())
    $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    throw
}