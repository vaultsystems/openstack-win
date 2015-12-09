$ErrorActionPreference = "Stop"

try
{
    # Enable ping (ICMP Echo Request on IPv4 and IPv6)
    netsh advfirewall firewall add rule name="ICMP Allow incoming V4 echo request" protocol=icmpv4:8,any dir=in action=allow

    $Host.UI.RawUI.WindowTitle = "Downloading FirstLogon script..."
    $temp = "$ENV:SystemRoot\Temp"
    $baseUrl = "https://raw.githubusercontent.com/vaultsystems/openstack-win/master"
    (new-object System.Net.WebClient).DownloadFile("$baseUrl/FirstLogon.ps1", "$temp\FirstLogon.ps1")
}
catch
{
    $host.ui.WriteErrorLine($_.Exception.ToString())
    $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    throw
}
