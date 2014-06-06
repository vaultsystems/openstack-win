try
{
   $Host.UI.RawUI.WindowTitle = "Setup Host"
  $dataUrl = "http://169.254.169.254/latest/meta-data"
  $hostName = Invoke-WebRequest "$dataUrl/local-hostname" | foreach {$_.Content}

  if (${env:computerName} -ne $hostName){
    Rename-Computer $hostName
    Restart-Computer -Force
  }
}
catch
{
    $log = Get-EventLog -List | Where-Object { $_.Log -eq "Application" }
    $log.Source = "OpenStack"
    $log.WriteEntry("TRAPPED: $_.Exception.ToString()", [system.Diagnostics.EventLogEntryType]::Error,1234)
}
