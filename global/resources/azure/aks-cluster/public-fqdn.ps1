$fqdn = az aks show --resource-group $args[0] --name $args[1] --query addonProfiles.httpApplicationRouting.config.HTTPApplicationRoutingZoneName -o tsv
Write-Output "{ ""hostname"": ""$fqdn"" }" 
