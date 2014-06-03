$ErrorActionPreference = "Stop"

try
{
  if (${env:computername} -ne "dummy"){
      # Setup Proxy
      # Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" -Name ProxyEnable -Value 1
      # iex "cmd.exe /c netsh winhttp set proxy 10.2.0.2:3128"

      #SetComputername
      Rename-Computer "dummy"

      # Adding all Roles
      Add-WindowsFeature -Name "NET-Framework-Core" -Source D:\sources\sxs
      Add-WindowsFeature -Name "NFS-Client"
      Add-WindowsFeature -Name "Telnet-Client"
      Add-WindowsFeature -Name "Telnet-Server"
      Add-WindowsFeature -Name "Windows-Identity-Foundation"
      Add-WindowsFeature -Name "RDS-RD-Server"
      Add-WindowsFeature -Name "RDS-Licensing"

      # Download Sysprep Powershell
      $sysprepUrl = "https://raw.githubusercontent.com/jnsolutions/openstack-win/master/Sysprep.ps1"
      $sysprepFile = "$ENV:Temp\Sysprep.ps1"
      Invoke-WebRequest $sysprepUrl -OutFile $sysprepFile

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
      # Get-WUInstall -AcceptAll -IgnoreReboot -IgnoreUserInput -NotCategory "Language packs"

      # Settup Hosts to see things
      Set-Content -Path "$ENV:SystemRoot\System32\drivers\etc\hosts" -Value "192.168.240.162 puppet"

      # Downloading PuppetAgent and pointing to server
      $puppetUrl = "http://downloads.puppetlabs.com/windows/puppet-3.6.0-rc1.msi"
      $puppetFile = "$ENV:Temp\puppet-agent.msi"
      $masterServer = "puppet"

      Invoke-WebRequest $puppetUrl -OutFile $puppetFile
      Start-Process -FilePath msiexec -ArgumentList /i, "$puppetFile PUPPET_MASTER_SERVER=$masterServer", /qn

      del $psWindowsUpdateFile
      Restart-Computer -Force
  } else {
      # Finalize and cleanup
      Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name Unattend*
      Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name AutoLogonCount
      Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -name AutoAdminLogon -value 0

      # Download Sysprep Config
      $sysprepUrl = "https://raw.githubusercontent.com/jnsolutions/openstack-win/master/sysprep.xml"
      $sysprepFile = "$ENV:Temp\sysprep.xml"
      Invoke-WebRequest $sysprepUrl -OutFile $sysprepFile

      # Expire Administrator password
      $user = [ADSI]'WinNT://localhost/Administrator'
      $user.passwordExpired = 1
      $user.setinfo()

      iex "cmd.exe /c netsh winhttp reset proxy"

      & "$ENV:SystemRoot\System32\Sysprep\Sysprep.exe" `/generalize `/oobe `/shutdown `/unattend:"$sysprepFile"
  }
}
catch
{
    $host.ui.WriteErrorLine($_.Exception.ToString())
    $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    throw
}
