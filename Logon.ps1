$ErrorActionPreference = "Stop"

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

      # Adding all Roles
      Add-WindowsFeature -Name "NET-Framework-Core" -Source D:\sources\sxs
      Add-WindowsFeature -Name "NFS-Client"
      Add-WindowsFeature -Name "Telnet-Client"
      Add-WindowsFeature -Name "Telnet-Server"
      Add-WindowsFeature -Name "Windows-Identity-Foundation"
      Add-WindowsFeature -Name "RDS-RD-Server"
      Add-WindowsFeature -Name "RDS-Licensing"

      # Download and apply updates
      $psWindowsUpdateUrl = "https://raw.githubusercontent.com/vaultsystems/openstack-win/master/PSWindowsUpdate.zip"
      $psWindowsUpdateFile = "$admFolder\PSWindowsUpdate.zip"

      Invoke-WebRequest $psWindowsUpdateUrl -OutFile $psWindowsUpdateFile
      foreach($item in (New-Object -com shell.application).NameSpace($psWindowsUpdateFile).Items())
      {
        $yesToAll = 16
        (New-Object -com shell.application).NameSpace("$ENV:SystemRoot\System32\WindowsPowerShell\v1.0\Modules").copyhere($item, $yesToAll)
      }
      # Import-Module PSWindowsUpdate
      # Get-WUInstall -AcceptAll -IgnoreReboot -IgnoreUserInput -NotCategory "Language packs"

      #SetComputername
      Rename-Computer "dummy"
      Restart-Computer -Force

  } else {
      # Install Software
      #Setup RAM
      $imDiskUrl = "https://raw.githubusercontent.com/vaultsystems/openstack-win/master/imdisk.zip"
      $imDiskFile = "$admFolder\imdisk.zip"

      Invoke-WebRequest $imDiskUrl -OutFile $imDiskFile
      foreach($item in (New-Object -com shell.application).NameSpace($imDiskFile).Items())
      {
        $yesToAll = 16
        (New-Object -com shell.application).NameSpace("C:\").copyhere($item, $yesToAll)
      }

      iex "cmd.exe /c rundll32 setupapi.dll,InstallHinfSection DefaultInstall 128 C:\imdisk\imdisk.inf"

      #Setup Python
      $pythonUrl = "https://www.python.org/ftp/python/2.7.10/python-2.7.10.amd64.msi"
      $pythonFile = "$admFolder\python2.7.msi"

      $pipUrl = "https://raw.githubusercontent.com/pypa/pip/master/contrib/get-pip.py"
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
      iex "cmd.exe /c python $pipFile"
      # netifaces wants to have MSVC installed when using easy_install. Using pip as workaround.
      iex "cmd.exe /c pip install netifaces"
      iex "cmd.exe /c easy_install -Z six python-keystoneclient python-swiftclient"
      Copy-Item C:\Python27\Scripts\swift-script.py C:\Python27\Scripts\swift.py

      # Downloading PuppetAgent and pointing to server
      $puppetUrl = "http://downloads.puppetlabs.com/windows/puppet-3.6.2.msi"
      $puppetFile = "$admFolder\puppet-agent.msi"
      $masterServer = "puppet"

      Invoke-WebRequest $puppetUrl -OutFile $puppetFile

      # Install Puppet
      Start-Process -FilePath msiexec -ArgumentList /i, "$puppetFile PUPPET_MASTER_SERVER=$masterServer", /qn

      Start-Sleep -s 60 #ensure it was done

      # Download and Install Cloud-Init
      $cloudinitUrl="https://www.cloudbase.it/downloads/CloudbaseInitSetup_Stable_x64.msi"
      $cloudinitInstaller = "$admFolder\CloudbaseInitSetup.msi"
      Invoke-WebRequest $cloudinitUrl -OutFile $cloudinitInstaller
      Start-Process -FilePath msiexec -ArgumentList " /i $admFolder\CloudbaseInitSetup.msi /qn /l*v $admFolder\Cloudinit_Install.log" -Wait

      (Get-Content "C:\Program Files\Cloudbase Solutions\Cloudbase-Init\conf\cloudbase-init.conf") -replace('^username=Admin$','username=Administrator') | Set-Content "C:\Program Files\Cloudbase Solutions\Cloudbase-Init\conf\cloudbase-init.conf"

      Add-Content "C:\Program Files\Cloudbase Solutions\Cloudbase-Init\LocalScripts\resize.ps1" "`$drive_c = (Get-Partition -DriveLetter C)"
      Add-Content "C:\Program Files\Cloudbase Solutions\Cloudbase-Init\LocalScripts\resize.ps1" "`$size = Get-PartitionSupportedSize -DiskNumber `$drive_c.DiskNumber -PartitionNumber `$drive_c.PartitionNumber"
      Add-Content "C:\Program Files\Cloudbase Solutions\Cloudbase-Init\LocalScripts\resize.ps1" "Resize-Partition -DiskNumber `$drive_c.DiskNumber -PartitionNumber `$drive_c.PartitionNumber -Size `$size.SizeMax"

      # Install Git
      $gitUrl="https://github.com/git-for-windows/git/releases/download/v2.6.3.windows.1/Git-2.6.3-64-bit.exe"
      $gitInstaller = "$admFolder\GitInstall.exe"
      $gitInfUrl="https://raw.githubusercontent.com/vaultsystems/openstack-win/master/git_setup.inf"
      $gitInfFile="$admFolder\git_setup.inf"

      Invoke-WebRequest $gitUrl -OutFile $gitInstaller
      Invoke-WebRequest $gitInfUrl -OutFile $gitInfFile
      Start-Process -FilePath $gitInstaller -ArgumentList /SILENT, /LOADINF=$gitInfFile -Wait

      # Download Sysprep Config
      $sysprepUrl = "https://raw.githubusercontent.com/vaultsystems/openstack-win/master/sysprep.xml"
      $sysprepFile = "$admFolder\sysprep.xml"
      Invoke-WebRequest $sysprepUrl -OutFile $sysprepFile

      # iex "cmd.exe /c netsh winhttp reset proxy"

      # Finalize and cleanup
      Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name Unattend*
      Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name AutoLogonCount
      Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -name AutoAdminLogon -value 0

      & "$ENV:SystemRoot\System32\Sysprep\Sysprep.exe" `/generalize `/oobe `/shutdown `/unattend:"$sysprepFile"
  }
}
catch
{
    $host.ui.WriteErrorLine($_.Exception.ToString())
    $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    throw
}
