<#
.Synopsis
   Returns the most current version of .psproj files.
.DESCRIPTION
   Returns the lastest version of the .psproj files supported by the code.

.EXAMPLE
   Get-PowershellProjectCurrentVersion
#>
function Get-PowershellProjectCurrentVersion
{
    [CmdletBinding()]
    Param
    (        
    )

    Begin
    {        
    }
    Process
    {        
        $item = "" | Select-Object CurrentVersion
        $item.CurrentVersion = "1.1"
        Write-Output $item
   }
    End
    {
    }
}

<#
.Synopsis
   Get the .psproj data version
.DESCRIPTION
   Returns the version of the .psproj data

.EXAMPLE
PS> Get-PowershellProjectVersion -ProjectFile ISEPSProject.psproj

Version CurrentVersion IsLatest
------- -------------- --------
1.1     1.1                True

#>
function Get-PowershellProjectVersion
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
            $projectData = Import-Clixml -Path $ProjectFile
            $item = "" | Select-Object Version,CurrentVersion,IsLatest
            $item.CurrentVersion = (Get-PowershellProjectCurrentVersion).CurrentVersion
            $item.IsLatest = $false
        
            if ( $projectData.ContainsKey("ISEPSProjectDataVersion") )
            {
                $item.Version = $projectData["ISEPSProjectDataVersion"]
            } else {
                $item.Version = "1.0"
            }
            if ( $item.CurrentVersion -eq $item.Version ) 
            {
                $item.IsLatest = $true
            }
            Write-Output $item
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
   Process to upgrade from a previous version to current.
.DESCRIPTION
   When the existing .psproj file is not at the current version, calling this command will upgrade all previous version to the current version.

.EXAMPLE
PS> Update-PowershellProjectVersion -ProjectFile ISEPSProject.psproj

UpgradeNeeded UpgradeStatus    
------------- -------------    
         True Updated to latest

#>
function Update-PowershellProjectVersion
{
    [CmdletBinding()]
    Param
    (
        # Specify the project file to open.  Default project can be specified via the Set-PowershellProjectDefaults command.
        [Parameter(Mandatory=$false,
                   Position=1)]
        [Alias('File','FilePath')]
        #[ValidateScript({ Test-Path $_ })]
        [string]       
        $ProjectFile = (Get-PowershellProjectDefaultProjectFile)
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
            $projectData = Import-Clixml -Path $ProjectFile

            $dataVersion = Get-PowershellProjectVersion -ProjectFile $ProjectFile
            $item = "" | Select-Object UpgradeNeeded,UpgradeStatus

            if ( $dataVersion.Version -ne $dataVersion.CurrentVersion ) 
            {
                Write-Verbose "Need an update: $($dataVersion.Version) to $($dataVersion.CurrentVersion)"
                $bakProjectData = Get-Content -Path $ProjectFile

                $backupList =  Get-Item -Path $ProjectFile -Stream * | Where-Object { $_.Stream -ne ':$DATA' }  | Sort-Object -Property Stream -Descending
                if ( $backupList )
                {
                    if ( $backupList.Count -gt 8 ) { $backupCount = 8 } else { $backupCount = ($backupList.Count)-1 }
                    $backupData = @{}
                    for ( $x = 0; $x -le $backupCount; $x++ )
                    {
                        $backData = Get-Content -Path $ProjectFile -Stream $backupList[$x].Stream
                        $backupData.Add($backupList[$x].Stream, $backData)
                    }
                }


                if ( ( $dataVersion.Version -eq "1.1" ) -and ( $continueProcessing -eq $true ) )
                {
                    #current version
                    $item.UpgradeNeeded = $false
                    $item.UpgradeStatus = "Current"
                    $continueProcessing = $false
                }
                if ( ( $dataVersion.Version -eq "1.0" ) -and ( $continueProcessing -eq $true ) )
                {
                    #upgrade from 1.0
                    Write-Verbose "Update from 1.0"
                    $projectData.Add("ISEPSProjectDataVersion", "1.1")

                    if ( $ProjectFile.StartsWith(".\") )
                    {
                        $projectFileKey = $ProjectFile.SubString(2)
                    }    
                    $newProjectData = @{}    
                    foreach ( $key in $projectData.Keys )
                    {
                        if ( ( $key -ne $projectFileKey ) -and ( $key -ne "ISEPSProjectDataVersion" ) ) 
                        {
                            $newStruct = "" | Select-Object FileName,ProjectTab,IncludeInBuild
                            $newStruct.FileName = $key
                            $newStruct.ProjectTab = $projectData[$key]
                            $newStruct.IncludeInBuild = $true
                            $newProjectData.Add($key, $newStruct)
                        } else {
                            $newProjectData.Add($key, $projectData[$key])
                        }
                    }
                    $item.UpgradeNeeded = $true
                    $item.UpgradeStatus = "Updated to latest"
                    $continueProcessing = $true
                }

                if ( $continueProcessing -eq $true ) 
                {
                    $newProjectData | Export-Clixml -Path $ProjectFile -Force

                    $backupName = (Get-Date).ToString('yyyy-MM-dd_HHmmss')
                    Add-Content -Path $ProjectFile -Value $bakProjectData -Stream $backupName

                    foreach ( $key in $backupData.Keys )
                    {
                        Add-Content -Path $ProjectFile -Value $backupData.Get_Item($key) -Stream $key
                    }                
                }
            } else {
                $item.UpgradeNeeded = $false
                $item.UpgradeStatus = "Current"
            }
            Write-Output $item
        } #continue processing
    }
    End
    {
        if ( $continueProcessing -eq $true )
        {
        }
    }
}

