<#
.Synopsis
   Gets the BACKUP Data from a .psproj file.
.DESCRIPTION
   Returns a hash table of backup data.

.EXAMPLE
PS> $backupData = Get-PowershellProjectBackupData -ProjectFile ISEPSProject.psproj
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
function Get-PowershellProjectBackupData
{
    [CmdletBinding()]
    Param
    (
        <#PINC:ProjectFile#>
        ,
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
            Write-Warning "Must specify the -ProjectFile, or use Set-PowershellProjectDefaults command to set a default ProjectFile"
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
<#
.Synopsis
   Save a .psproj file.
.DESCRIPTION
   This process saves, and optionally stores backups within the NTFS streams of the file.

.EXAMPLE
PS> $projectData = Get-PowershellProject -ProjectFile ISEPSProject.psproj 
PS> Save-PowershellProject -ProjectFile ISEPSProject.psproj -ProjectData $projectData

#>
function Save-PowershellProject
{
    [CmdletBinding()]
    Param
    (
        <#PINC:ProjectFile#>
        ,
        #backup data gathered from the Get-PowershellProjectBackupData command.
        [Parameter(Mandatory=$false,
                   Position=1)]
        [Hashtable]
        $ProjectData
        ,
        #Skip backing up the current file data, just write the $ProjectData values.
        [Parameter(Mandatory=$false,
                   Position=2)]
        [switch]
        $SkipBackup = $false
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
            if ( $SkipBackup -eq $false )
            {
                $bakProjectData = Get-Content -Path $ProjectFile
                $backupData = Get-PowershellProjectBackupData $ProjectFile
            } else {
                $backupData = Get-PowershellProjectBackupData $ProjectFile -AllBackups
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
        } #continue processing
    }
    End
    {
        if ( $continueProcessing -eq $true )
        {
        }
    }
}
