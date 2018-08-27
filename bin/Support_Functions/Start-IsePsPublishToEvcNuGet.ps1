Function Start-IsePsPublishToEvcNuGet
{
    cd C:\users\Christopher.Maahs\Documents\Projects\ISEPSProject
    Start-PspBuildPowershellProject -Verbose -Force 
    cd ..\.. 
    Uninstall-Module -Name ISEPSProject 
    cd .\Projects\ISEPSProject
    New-Item -ItemType Directory -Path 'C:\Program Files\WindowsPowerShell\Modules\' -Name ISEPSProject
    Start-PspDeployPowershellProject -Verbose -Force 
    cd ..\..
    Publish-Module -Name ISEPSProject -NuGetApiKey (Get-VaultNuGetKey) -Repository EvcNuGet 
    Remove-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\ISEPSProject' -Recurse -Force  
    Write-Verbose "Sleeping for 3 minutes for replication to happen..." -Verbose
    Start-Sleep -Seconds 180
    Install-Module -Name ISEPSProject -Repository EvcNuGet
    cd .\Projects\ISEPSProject
}

