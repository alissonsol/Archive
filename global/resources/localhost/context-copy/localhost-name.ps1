# Write the localhost name back for further processing
$hostname=[System.Net.Dns]::GetHostByName($env:computerName).HostName
$ip_address=([System.Net.DNS]::GetHostAddresses($env:computername) | Where-Object {$_.AddressFamily -eq "InterNetwork"} | select-object IPAddressToString)[0].IPAddressToString
# Using IP address in Windows because K8S in the Docker for Windows won't resolve the hostname from inside the container (works in macOS, Linux)
if ($IsWindows) { $hostname = $ip_address; }
Write-Output "{ ""hostname"": ""$hostname"" }" 
