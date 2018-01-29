<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
Function Restore-PowershellProjectBackup
{
    [CmdletBinding()]
    Param
    (
        <#PINC:ProjectFile#>
        ,
        # Use the Get-PowershellProjectBackup command to get a list of backup numbers, provide 0-9 for the LEFT side compare.
        [Parameter(Mandatory=$true,
                   Position=1)]
        [ValidateRange(0,9)]
        [int]
        $BackupNumberToRestore
    )

    Begin
    {
        $continueProcessing = $true
        if ( $ProjectFile -ne "" ) 
        {            
            if ( -not ( Test-Path $ProjectFile ) ) 
            {
                Write-Warning "Cannot locate the specified ProjectFile"
                $continueProcessing = $false
            }        
        } else {
            Write-Warning "Must specify the -ProjectFile, or use Set-PowershellProjectDefaults command to set a default ProjectFile"
            $continueProcessing = $false
        }
    }
    Process
    {
        if ( $continueProcessing -eq $true )
        {
            $backupList =  Get-Item -Path $ProjectFile -Stream * | Where-Object { $_.Stream -ne ':$DATA' }  | Sort-Object -Property Stream -Descending

            foreach ( $item_backupList in $backupList ) 
            {
                if ( $x -eq $BackupNumberToRestore ) 
                {       
                    Write-Verbose "Attempting to open $($item_backupList.Stream) as Restore File"
                    $backupProjectData = Get-Content -Path $ProjectFile -Stream $item_backupList.Stream
                    $tempFile = New-TemporaryFile
                    $backupProjectData | Out-File -FilePath $tempFile -Encoding ASCII -Force
                    $restoreProject = Import-Clixml -Path $tempFile
                    Remove-Item $tempFile -Force
                    Save-PowershellProject -ProjectFile $ProjectFile -ProjectData $restoreProject
                }               
                $x++
            }

            
        } #continue processing
    }
    End
    {
        if ( $continueProcessing -eq $true )
        {
        }
    }
}