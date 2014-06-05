$dataUrl = "http://169.254.169.254/latest/meta-data"
$hostName = Invoke-WebRequest "$dataUrl/local-hostname" | foreach {$_.Content}

if (${env:computerName} -ne $hostName){
  Rename-Computer $hostName
  Restart-Computer -Force
}