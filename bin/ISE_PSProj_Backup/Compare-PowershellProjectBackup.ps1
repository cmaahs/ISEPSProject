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
Function Compare-PowershellProjectBackup
{
    [CmdletBinding()]
    Param
    (
        # Specify the project file to open.  Default project can be specified via the Set-PowershellProjectDefaults command.
        [Parameter(Mandatory=$false,
                   Position=0)]
        [Alias('File','FilePath')]
        #[ValidateScript({ Test-Path $_ })]
        [string]       
        $ProjectFile = (Get-PowershellProjectDefaultProjectFile)
        ,
        # Use the Get-PowershellProjectBackup command to get a list of backup numbers, provide 0-9 for the LEFT side compare.
        [Parameter(Mandatory=$true,
                   Position=1)]
        [ValidateRange(0,9)]
        [int]
        $LeftFile
        ,
        # Use the Get-PowershellProjectBackup command to get a list of backup numbers, provide 0-9 for the RIGHT side compare.
        [Parameter(Mandatory=$true,
                   Position=2)]
        [ValidateRange(0,9)]
        [int]
        $RightFile
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
            $x = 0;
            foreach ( $item_backupList in $backupList ) 
            {
                if ( $x -eq $LeftFile ) 
                {       
                    Write-Verbose "Attempting to open $($item_backupList.Stream) as Left File"
                    $leftData = Get-Content -Path $ProjectFile -Stream $item_backupList.Stream
                }
                if ( $x -eq $RightFile ) 
                {
                    Write-Verbose "Attempting to open $($item_backupList.Stream) as Right File"
                    $rightData = Get-Content -Path $ProjectFile -Stream $item_backupList.Stream
                }
                $x++
            }

            Compare-Object -ReferenceObject $leftData -DifferenceObject $rightData
        } #continue processing
    }
    End
    {
        if ( $continueProcessing -eq $true )
        {
        }
    }
}

