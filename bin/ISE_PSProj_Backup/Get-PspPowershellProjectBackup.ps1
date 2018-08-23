Function Get-PspPowershellProjectBackup
{
<#
.Synopsis
    EXPERIMENTAL: List the STREAMS backups stored for the .psproj file.
.DESCRIPTION
    The list contains a numbered slot and the file can contain 0-9 numbered slots.
    The names reference the date and time the backup was made.
    
.EXAMPLE
   Get-PspPowershellProjectBackup

0. 2018-06-04_011755
1. 2018-06-04_011742
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
        # Use the Get-PspPowershellProjectBackup command to get a list of backup numbers, provide 0-9 for the LEFT side compare.
        [Parameter(Mandatory=$true,
                   Position=1)]
        #[ValidateRange(0,9)]
        [int]
        $StartAt = 0
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
            $backupList =  Get-Item -Path $ProjectFile -Stream * | Where-Object { $_.Stream -ne ':$DATA' }  | Sort-Object -Property Stream -Descending
        
            $x = $StartAt;
            foreach ( $item_backupList in $backupList ) 
            {
                if ( $x -ge $StartAt )
                {
                    Write-Output "$($x). $($item_backupList.Stream)"
                }
                $x++
                if ( $x -gt 9 ) 
                {
                    break
                }
            }
        }
    }
}

