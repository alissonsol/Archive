# Write the localhost IP back for further processing
$ip_address=([System.Net.DNS]::GetHostAddresses($null) | Where-Object {$_.AddressFamily -eq "InterNetwork"} | select-object IPAddressToString)[0].IPAddressToString
Write-Output "{ ""ip_address"": ""$ip_address"" }"