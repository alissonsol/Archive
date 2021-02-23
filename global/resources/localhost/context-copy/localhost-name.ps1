# Write the localhost name back for further processing
$hostname=[System.Net.Dns]::GetHostByName($env:computerName).HostName
Write-Output "{ ""hostname"": ""$hostname"" }" 
