# yuruna helper: copy context
# This code is hacky, and creates temporary file with keys in the .yuruna folder
# Why?
# Because it was indeed simple to "copy the context".
# For that, one could just extract the cluster and the auth info and
#   kubectl config set-context $destinationContext --cluster=$cluster --user=$authInfo
# However, if you do that, when you later delete that "reference context", the YAML entries for the cluster and user are gone.
# As a result, this code creates copies of those entries with the same name of the destinationContext

function Publish-DecodedBase64Data {
    param (
        $filename,
        $dataBase64
    )

    $dataFile = Join-Path -Path $PSScriptRoot -ChildPath $filename
    Remove-Item -Path $dataFile -Force -Recurse -ErrorAction SilentlyContinue
    $decodedData = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($dataBase64))
    Set-Content -Path $dataFile -Value $decodedData

    return $dataFile
}

$yuruna_root = ${env:yuruna_root}
Write-Debug "yuruna_root: $yuruna_root"
$sourceContext = ${env:SOURCE_CONTEXT}
Write-Debug "sourceContext: $sourceContext"
$destinationContext = ${env:DESTINATION_CONTEXT}
Write-Debug "destinationContext: $destinationContext"

$modulePath = Join-Path -Path $yuruna_root -ChildPath "automation/import-yaml"
Import-Module -Name $modulePath

# Save originalContext and confirm sourceContext exists
$originalContext = kubectl config current-context
kubectl config use-context $sourceContext *>&1 | Write-Verbose
$currentContext = kubectl config current-context
if ($currentContext -ne $sourceContext) { Write-Information "K8S source context not found: $sourceContext`n"; return $false; }

# Copy sourceContext to destinationContext
Write-Debug "`n==== ********* Copying context '$sourceContext' to '$destinationContext' ************** =======";
$yamlContent = $(kubectl config view --minify --raw=true -o yaml)
$yaml = ConvertFrom-Content $yamlContent
$userClientCertificateData = $yaml.users.user.'client-certificate-data'
$userClientKeyData = $yaml.users.user.'client-key-data'

$clusterServer = $yaml.clusters.cluster.server
$clusterCertificateAuthorityData = $yaml.clusters.cluster.'certificate-authority-data'

# New artifacts
$filename = $destinationContext + ".certificate-authority"
$clusterCertificateAuthorityFile = Publish-DecodedBase64Data $filename $clusterCertificateAuthorityData
$result = $(kubectl config set-cluster $destinationContext --server=$clusterServer --certificate-authority=$clusterCertificateAuthorityFile)
Write-Debug "**** Cluster: $result";

$filename = $destinationContext + ".client-certificate"
$userClientCertificateFile = Publish-DecodedBase64Data $filename $userClientCertificateData
$filename = $destinationContext + ".client-key"
$userClientKeyFile = Publish-DecodedBase64Data $filename $userClientKeyData
$result = $(kubectl config set-credentials $destinationContext --client-certificate=$userClientCertificateFile --client-key=$userClientKeyFile)
Write-Debug "**** User: $result";

$result = $(kubectl config set-context $destinationContext --cluster=$destinationContext --user=$destinationContext)
Write-Debug "**** Context: $result";

# Back to originalContext
kubectl config use-context $originalContext *>&1 | Write-Verbose