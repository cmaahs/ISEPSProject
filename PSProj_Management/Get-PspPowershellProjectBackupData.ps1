function Get-PspPowershellProjectBackupData
{
<#
.Synopsis
   Gets the BACKUP Data from a .psproj file.
.DESCRIPTION
   Returns a hash table of backup data.

.EXAMPLE
PS> $backupData = Get-PspPowershellProjectBackupData -ProjectFile ISEPSProject.psproj
PS> $backupData
Name                           Value                                                                                                                                             
----                           -----                                                                                                                                             
2017-08-29_112937              {<Objs Version="1.1.0.1" xmlns="http://schemas.microsoft.com/powershell/2004/04">,   <Obj ...
2017-08-29_112834              {<Objs Version="1.1.0.1" xmlns="http://schemas.microsoft.com/powershell/2004/04">,   <Obj ...
2017-08-29_113448              {<Objs Version="1.1.0.1" xmlns="http://schemas.microsoft.com/powershell/2004/04">,   <Obj ...
2017-08-28_141817              {<Objs Version="1.1.0.1" xmlns="http://schemas.microsoft.com/powershell/2004/04">,   <Obj ...
2017-08-29_113355              {<Objs Version="1.1.0.1" xmlns="http://schemas.microsoft.com/powershell/2004/04">,   <Obj ...
2017-08-29_112646              {<Objs Version="1.1.0.1" xmlns="http://schemas.microsoft.com/powershell/2004/04">,   <Obj ...
2017-08-29_080326              {<Objs Version="1.1.0.1" xmlns="http://schemas.microsoft.com/powershell/2004/04">,   <Obj ...
2017-08-28_141113              {<Objs Version="1.1.0.1" xmlns="http://schemas.microsoft.com/powershell/2004/04">,   <Obj ...
2017-08-28_144227              {<Objs Version="1.1.0.1" xmlns="http://schemas.microsoft.com/powershell/2004/04">,   <Obj ...

#>
    [CmdletBinding()]
    Param
    (
        <#PINC:ProjectFile#>
        <#PINC:PARAMCOMMA#>
        # Switch to return ALL backups, instead of the previous 9.
        [Parameter(Mandatory=$false,
                   Position=1)]
        [switch]
        $AllBackups
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
            $bakProjectData = Get-Content -Path $ProjectFile

            $backupList =  Get-Item -Path $ProjectFile -Stream * | Where-Object { $_.Stream -ne ':$DATA' }  | Sort-Object -Property Stream -Descending
            if ( $backupList )
            {
                if ( $backupList.Count -gt 99 ) 
                {
                    if ( $AllBackups -eq $true )
                    {
                        $backupCount = ($backupList.Count)-1
                    } else {
                        $backupCount = 99 
                    }
                } else {
                    $backupCount = ($backupList.Count)-1 
                }
                $backupData = @{}
                for ( $x = 0; $x -le $backupCount; $x++ )
                {
                    $backData = Get-Content -Path $ProjectFile -Stream $backupList[$x].Stream
                    $backupData.Add($backupList[$x].Stream, $backData)
                }
            }
            Write-Output $backupData
        } #continue processing
    }
    End
    {
        if ( $continueProcessing -eq $true )
        {
        }
    }
}
