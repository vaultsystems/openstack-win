$ErrorActionPreference = "Stop"
# enable TLS 1.2 support as pypa.io requires it
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

try
{
  $admFolder = "C:\Users\Administrator\Documents"
  if (${env:computername} -ne "dummy"){
      # Disable IPv6
      # Disable-NetAdapterBinding -InterfaceAlias Ethernet -ComponentID ms_tcpip6
      # Disable DnsClient
      Set-Service -name Dnscache -startupType Disabled

      # Setup Proxy
      # Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" -Name ProxyEnable -Value 1
      # iex "cmd.exe /c netsh winhttp set proxy 10.2.0.2:3128"

      # Install Features
      Install-WindowsFeature -Name "NET-Framework-Core" -Source D:\sources\sxs
      Install-WindowsFeature -Name "NFS-Client"
      Install-WindowsFeature -Name "Telnet-Client"
      Install-WindowsFeature -Name "Telnet-Server"
      Install-WindowsFeature -Name "Windows-Identity-Foundation"
      Install-WindowsFeature -Name "RDS-RD-Server"
      Install-WindowsFeature -Name "RDS-Licensing"
      Install-WindowsFeature -Name "RDS-Licensing-UI"

      # Download and apply updates
      $psWindowsUpdateUrl = "https://raw.githubusercontent.com/vaultsystems/openstack-win/master/PSWindowsUpdate.zip"
      $psWindowsUpdateFile = "$admFolder\PSWindowsUpdate.zip"

      Invoke-WebRequest $psWindowsUpdateUrl -OutFile $psWindowsUpdateFile
      foreach($item in (New-Object -com shell.application).NameSpace($psWindowsUpdateFile).Items())
      {
        $yesToAll = 16
        (New-Object -com shell.application).NameSpace("$ENV:SystemRoot\System32\WindowsPowerShell\v1.0\Modules").copyhere($item, $yesToAll)
      }
      Import-Module PSWindowsUpdate
      Get-WUInstall -AcceptAll -IgnoreReboot -IgnoreUserInput -NotCategory "Language packs"

      # Set Computername
      Rename-Computer "dummy"
      Restart-Computer -Force

  } else {
      # Install Software
      # Setup RAMdisk
      $imDiskUrl = "https://raw.githubusercontent.com/vaultsystems/openstack-win/master/imdisk.zip"
      $imDiskFile = "$admFolder\imdisk.zip"

      Invoke-WebRequest $imDiskUrl -OutFile $imDiskFile
      foreach($item in (New-Object -com shell.application).NameSpace($imDiskFile).Items())
      {
        $yesToAll = 16
        (New-Object -com shell.application).NameSpace("C:\").copyhere($item, $yesToAll)
      }

      & rundll32 setupapi.dll,InstallHinfSection DefaultInstall 128 C:\imdisk\imdisk.inf

      #Setup Python
      $pythonUrl = "https://www.python.org/ftp/python/2.7.11/python-2.7.11.amd64.msi"
      $pythonFile = "$admFolder\python2.7.msi"
      $pipUrl = "https://bootstrap.pypa.io/get-pip.py"
      $pipFile = "$admFolder\pip.py"

      Invoke-WebRequest $pythonUrl -OutFile $pythonFile
      Invoke-WebRequest $pipUrl -OutFile $pipFile

      Start-Process "$pythonFile" /qn -Wait
      Start-Sleep -s 20 #ensure it was done

      [Environment]::SetEnvironmentVariable("Path", "$env:Path;C:\Python27\;C:\Python27\Scripts\", "Machine")
      [Environment]::SetEnvironmentVariable("PATHEXT", "$env:PATHEXT;.PY", "Machine")

      $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine")
      $env:PATHEXT = [System.Environment]::GetEnvironmentVariable("PATHEXT","Machine")

      # Install PIP
      & python $pipFile
      & pip install python-keystoneclient python-swiftclient

      # Downloading PuppetAgent and pointing to server
      $puppetUrl = "http://downloads.puppetlabs.com/windows/puppet-3.6.2.msi"
      $puppetFile = "$admFolder\puppet-agent.msi"
      $masterServer = "puppet"
      Invoke-WebRequest $puppetUrl -OutFile $puppetFile

      # Install Puppet
      Start-Process -FilePath msiexec -ArgumentList /i, "$puppetFile PUPPET_MASTER_SERVER=$masterServer", /qn -Wait

      # Download and Install Cloud-Init
      $cloudinitUrl="https://www.cloudbase.it/downloads/CloudbaseInitSetup_Stable_x64.msi"
      $cloudinitInstaller = "$admFolder\CloudbaseInitSetup.msi"
      Invoke-WebRequest $cloudinitUrl -OutFile $cloudinitInstaller
      Start-Process -FilePath msiexec -ArgumentList " /i $admFolder\CloudbaseInitSetup.msi /qn /l*v $admFolder\Cloudinit_Install.log" -Wait
      & sc.exe config cloudbase-init start=delayed-auto
      (Get-Content "C:\Program Files\Cloudbase Solutions\Cloudbase-Init\conf\cloudbase-init.conf") -replace('^username=Admin$','username=Administrator') | Set-Content "C:\Program Files\Cloudbase Solutions\Cloudbase-Init\conf\cloudbase-init.conf"
      (Get-Content "C:\Program Files\Cloudbase Solutions\Cloudbase-Init\conf\cloudbase-init-unattend.conf") -replace('^username=Admin$','username=Administrator') | Set-Content "C:\Program Files\Cloudbase Solutions\Cloudbase-Init\conf\cloudbase-init-unattend.conf"

      # Install Git
      $gitUrl="https://github.com/git-for-windows/git/releases/download/v2.6.3.windows.1/Git-2.6.3-64-bit.exe"
      $gitInstaller = "$admFolder\GitInstall.exe"
      $gitInfUrl="https://raw.githubusercontent.com/vaultsystems/openstack-win/master/git_setup.inf"
      $gitInfFile="$admFolder\git_setup.inf"
      Invoke-WebRequest $gitUrl -OutFile $gitInstaller
      Invoke-WebRequest $gitInfUrl -OutFile $gitInfFile
      Start-Process -FilePath $gitInstaller -ArgumentList /SILENT, /LOADINF=$gitInfFile -Wait

      # Install Ossec
      $ossecUrl = "https://bintray.com/artifact/download/ossec/ossec-hids/ossec-agent-win32-2.8.3.exe"
      $ossecFile = "$admFolder\ossec.exe"
      Invoke-WebRequest $ossecUrl -OutFile $ossecFile
      Start-Process -FilePath $ossecFile -ArgumentList /S -Wait

      # Install EMET
      $emetUrl = "https://download.microsoft.com/download/8/E/E/8EEFD9FC-46B1-4A8B-9B5D-13B4365F8CA0/EMET%20Setup.msi"
      $emetFile = "$admFolder\EMET-Setup.msi"
      Invoke-WebRequest $emetUrl -OutFile $emetFile
      Start-Process -FilePath msiexec -ArgumentList "/i $emetFile /qn /norestart" -Wait
      Set-Location -Path "C:\Program Files (x86)\EMET 5.5"
      $ErrorActionPreference = "Continue"
      & .\EMET_Conf.exe --import 'C:\Program Files (x86)\EMET 5.5\Deployment\Protection Profiles\Popular Software.xml'
      & .\EMET_Conf.exe --import 'C:\Program Files (x86)\EMET 5.5\Deployment\Protection Profiles\Recommended Software.xml'
      & .\EMET_Conf.exe --system pinning=enabled
      $ErrorActionPreference = "Stop"

      # Proxy
      # iex "cmd.exe /c netsh winhttp reset proxy"

      # RDP rearm
      $rdpRearmUrl = "https://raw.githubusercontent.com/vaultsystems/openstack-win/master/rdp-rearm.xml"
      $rdpRearmFile = "$admFolder\rdp-rearm.xml"
      Invoke-WebRequest $rdpRearmUrl -OutFile $rdpRearmFile
      Register-ScheduledTask -Xml (get-content $rdpRearmFile | out-string) -TaskName 'RDP Rearm' -Force

      # Finalize and cleanup
      Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name Unattend*
      Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name AutoLogonCount
      Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -name AutoAdminLogon -value 0

      # Download Sysprep Config
      $sysprepUrl = "https://raw.githubusercontent.com/vaultsystems/openstack-win/master/sysprep.xml"
      $sysprepFile = "$admFolder\sysprep.xml"
      Invoke-WebRequest $sysprepUrl -OutFile $sysprepFile

      & ipconfig /release
      & "$ENV:SystemRoot\System32\Sysprep\Sysprep.exe" `/generalize `/oobe `/shutdown `/unattend:"$sysprepFile"
      Write-Host -NoNewLine 'Press any key to close this window';
      $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
  }
}
catch
{
    $Host.ui.WriteErrorLine($_.Exception.ToString())
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
    throw
}
