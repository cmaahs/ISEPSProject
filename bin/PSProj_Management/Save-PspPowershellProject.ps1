function Save-PspPowershellProject
{
<#
.Synopsis
   Save a .psproj file.
.DESCRIPTION
   This process saves, and optionally stores backups within the NTFS streams of the file.

.EXAMPLE
PS> $projectData = Get-PspPowershellProject -ProjectFile ISEPSProject.psproj 
PS> Save-PspPowershellProject -ProjectFile ISEPSProject.psproj -ProjectData $projectData

#>
    [CmdletBinding()]
    Param
    (
        # Specify the project file to open.  Default project can be specified via the Set-PspPowershellProjectDefaults command.
        [Parameter(Mandatory=$false,
                   Position=0)]
        [Alias('File','FilePath')]
        #[ValidateScript({ Test-Path $_ })]
        [string]       
        $ProjectFile = (Get-PspPowershellProjectDefaultProjectFile)
        ,
        [Parameter(Mandatory=$false,
                   Position=1)]
        [Hashtable]
        $ProjectData
    )

    Begin
    {
        $continueProcessing = $true
        # as of version 1.3 we are doing away with the backup concept
        $SkipBackup = $true
        if ( $ProjectFile -ne "" ) 
        {            
            if ( -not ( Test-Path $ProjectFile ) ) 
            {
                Write-Warning "Cannot locate the specified ProjectFile"
                $continueProcessing = $false
            }        
        } else {
            Write-Warning "Must specify the -ProjectFile, or use Set-PspPowershellProjectDefaults command to set a default ProjectFile"
            $continueProcessing = $false
        }
    }
    Process
    {
        if ( $continueProcessing -eq $true )
        {
        } #continue processing
    }
    End
    {
        if ( $continueProcessing -eq $true )
        {

            if ( (Get-PspPowershellProjectVersion -ProjectFile $ProjectFile).IsLatest -eq $true )
            {                
                # version 1.3 and later.
                Save-PspProjectData -ProjectData $ProjectData
            } else {
                # version pre 1.3            
                if ( $SkipBackup -eq $false )
                {
                    $bakProjectData = Get-Content -Path $ProjectFile
                    $backupData = Get-PspPowershellProjectBackupData $ProjectFile
                } else {
                    $backupData = Get-PspPowershellProjectBackupData $ProjectFile -AllBackups
                }

                $projectData | Export-Clixml -Path $ProjectFile -Force

                if ( $SkipBackup -eq $false )
                {
                    $backupName = (Get-Date).ToString('yyyy-MM-dd_HHmmss')
                    Add-Content -Path $ProjectFile -Value $bakProjectData -Stream $backupName

                    foreach ( $key in $backupData.Keys )
                    {
                        Add-Content -Path $ProjectFile -Value $backupData.Get_Item($key) -Stream $key
                    }
                } else {
                    foreach ( $key in $backupData.Keys )
                    {
                        Add-Content -Path $ProjectFile -Value $backupData.Get_Item($key) -Stream $key
                    }
                }
            } # version 1.3 check
        } #continue processing
    }
}

