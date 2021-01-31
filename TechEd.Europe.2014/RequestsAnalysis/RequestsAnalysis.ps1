#=============================
$colorQuery = "Gray" 
$colorWarning = "Yellow"
$colorStatus = "Green"
$colorError = "Red"

#=============================
Write-Host "Setting variables" -ForegroundColor $colorStatus
$currentScriptName = $MyInvocation.MyCommand.Name
$currentScriptConfiguration = $currentScriptName + ".config"
[xml]$config = Get-Content $currentScriptConfiguration
$subscriptionName = $config.Configuration.SubscriptionName
$clusterName = $config.Configuration.ClusterName
$clusterStorageAccountName = $config.Configuration.ClusterStorageAccountName
$clusterBinariesContainer = $config.Configuration.ClusterBinariesContainer
$mapperBinary = $config.Configuration.MapperBinary
$reducerBinary = $config.Configuration.ReducerBinary
$clusterOutputContainer = $config.Configuration.ClusterOutputContainer
$clusterStatusContainer = $config.Configuration.ClusterStatusContainer
$inputStorageAccountName = $config.Configuration.InputStorageAccountName
$inputStorageAccountKey = $config.Configuration.InputStorageAccountKey
$inputContainer = $config.Configuration.InputContainer
$deployBinaries = $config.Configuration.DeployBinaries 
$deployFlavor = $config.Configuration.DeployFlavor
$jobTimeOut = $config.Configuration.JobTimeOut
$jobTimePath = Get-Date -UFormat "%Y-%m-%d.%H-%M-%S"
$jobName = "jobRequestsAnalysis." + $jobTimePath
$PSScriptRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition

#=============================
if($deployBinaries -eq $true)
{
    Write-Host "Deploying binaries" -ForegroundColor $colorWarning
	$localMapperProject = [System.IO.Path]::GetFileNameWithoutExtension($mapperBinary)
	$localReducerProject = [System.IO.Path]::GetFileNameWithoutExtension($reducerBinary)
	$localMapperBinary = "$PSScriptRoot\$localMapperProject\bin\$deployFlavor\$mapperBinary"
	$localReducerBinary = "$PSScriptRoot\$localReducerProject\bin\$deployFlavor\$reducerBinary"
	Select-AzureSubscription -SubscriptionName $subscriptionName
	$clusterStorageAccountKey = Get-AzureStorageKey $clusterStorageAccountName | %{ $_.Primary }
	$clusterStorageContext = New-AzureStorageContext –StorageAccountName $clusterStorageAccountName –StorageAccountKey $clusterStorageAccountKey 
	Set-AzureStorageBlobContent -File $localMapperBinary -Container $clusterBinariesContainer -Context $clusterStorageContext -Force
	Set-AzureStorageBlobContent -File $localreducerBinary -Container $clusterBinariesContainer -Context $clusterStorageContext -Force
	Get-AzureStorageBlob -Container $clusterBinariesContainer -Context $clusterStorageContext
}

#=============================
$mrMapperFile = "wasb://$clusterBinariesContainer@$clusterStorageAccountName.blob.core.windows.net/$mapperBinary"
$mrReducerFile = "wasb://$clusterBinariesContainer@$clusterStorageAccountName.blob.core.windows.net/$reducerBinary"
$mrInput = "wasb://$inputContainer@$inputStorageAccountName.blob.core.windows.net/"
$mrOutput = "wasb://$clusterOutputContainer@$clusterStorageAccountName.blob.core.windows.net/$jobTimePath/"
$mrStatus = "wasb://$clusterStatusContainer@$clusterStorageAccountName.blob.core.windows.net/$jobTimePath/"
$defines = @{}
if ([string]::Compare($clusterStorageAccountName, $inputStorageAccountName) -ne 0)
{
    Write-Host "Adding account key for '$inputStorageAccountName'" -ForegroundColor $colorStatus
    $defines.Add("fs.azure.account.key.$inputStorageAccountName.blob.core.windows.net", $inputStorageAccountKey)
}

#=============================
Write-Host "Selecting subscription and cluster" -ForegroundColor $colorStatus
Select-AzureSubscription -SubscriptionName $subscriptionName
Use-AzureHDInsightCluster -Name $clusterName

#=============================
Write-Host "Creating streaming MapReduce job definition" -ForegroundColor $colorStatus
$mrJobDef = New-AzureHDInsightStreamingMapReduceJobDefinition -JobName $jobName -Defines $defines -Mapper $mapperBinary -Reducer $reducerBinary -InputPath $mrInput -OutputPath $mrOutput -StatusFolder $mrStatus -Verbose
$mrJobDef.Files.Add($mrMapperFile)
$mrJobDef.Files.Add($mrReducerFile)

#=============================
Write-Host "Start streaming MapReduce job" -ForegroundColor $colorStatus
$mrJob = Start-AzureHDInsightJob -Cluster $clusterName -JobDefinition $mrJobDef -Verbose
Write-Host "Wait streaming MapReduce job" -ForegroundColor $colorStatus
Wait-AzureHDInsightJob -Job $mrJob -WaitTimeoutInSeconds $jobTimeOut -Verbose

Write-Host "Output at $mrOutput" -ForegroundColor $colorStatus