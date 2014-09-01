$ErrorActionPreference = "Stop"

try
{
    # Enable ping (ICMP Echo Request on IPv4 and IPv6)
    # TODO: replace with with a netsh advfirewall command
    # possibly avoiding duplicates with "File and printer sharing (Echo Request - ICMPv[4,6]-In)"
    netsh firewall set icmpsetting 8


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
