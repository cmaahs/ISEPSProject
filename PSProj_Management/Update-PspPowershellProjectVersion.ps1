function Update-PspPowershellProjectVersion
{
<#
.Synopsis
   Process to upgrade from a previous version to current.
.DESCRIPTION
   When the existing .psproj file is not at the current version, calling this command will upgrade all previous version to the current version.

.EXAMPLE
PS> Update-PspPowershellProjectVersion -ProjectFile ISEPSProject.psproj

UpgradeNeeded UpgradeStatus    
------------- -------------    
         True Updated to latest

#>
    [CmdletBinding()]
    Param
    (
        <#PINC:ProjectFile#>
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
            $projectData = Import-Clixml -Path $ProjectFile

            $dataVersion = Get-PspPowershellProjectVersion -ProjectFile $ProjectFile
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


                if ( ( $dataVersion.Version -eq "1.3" ) -and ( $continueProcessing -eq $true ) )
                {
                    #current version
                    $item.UpgradeNeeded = $false
                    $item.UpgradeStatus = "Current"
                    $continueProcessing = $false
                }

                if ( ( $dataVersion.Version -eq "1.2" ) -and ( $continueProcessing -eq $true ) )
                {
                    <#
                      - upgrade from 1.2
                      
                          test for .psproj\files\ path, create if needed
                          loop through keys
                          write JSON files to .psproj\files\
                          split the $key into directory/filename parts.
                          test for .psproj\files\directorypart and create if neeed
                          write output of the ConvertTo-Json to the .psproj\files\directorypart\filename.json
                          $projectData[$key] | ConvertTo-Json 
                            {
                                "FileName":  "Build_Management\\Reset-PspBuildFolder.ps1",
                                "ProjectTab":  "Build_Management",
                                "IncludeInBuild":  {
                                                       "IsPresent":  true
                                                   },
                                "ReadMeOrder":  999
                            }

                            $keyParts = $key.Split("\")
                            $ProjectData[$key] | ConvertTo-Json | Out-File -FilePath .\$($keyParts[0])\$($keyParts[1]).json -Encoding ascii
                    #>
                    Write-Verbose "Update from 1.2"
                    $projectData["ISEPSProjectDataVersion"] = "1.3"

                    if ( $ProjectFile.StartsWith(".\") )
                    {
                        $projectFileKey = $ProjectFile.SubString(2)
                    }    
                    $newProjectData = @{}
                    $controlDirectory = Get-PspControlDirectory
                    if ( $controlDirectory -ne "" )
                    {
                        foreach ( $key in $projectData.Keys )
                        {
                            if ( ( $key -ne $projectFileKey ) -and ( $key -ne "ISEPSProjectDataVersion" ) ) 
                            {
                                $keyParts = $key.Split("\")
                                # get the base path for .psproj and create the files directory
                                $controlDirectory = Get-PspControlDirectory
                                if ( -not ( Test-Path "$($controlDirectory)\.psproj\files" ) )
                                {
                                    $newDir = New-Item -ItemType Directory -Path "$($controlDirectory)\.psproj\files"
                                }

                                # create the {tabname} directory
                                if ( -not ( Test-Path "$($controlDirectory)\.psproj\files\$($keyParts[0])" ) )
                                {
                                    $newDir = New-Item -ItemType Directory -Path "$($controlDirectory)\.psproj\files\$($keyParts[0])"
                                }


                                # create the new .psproj\files\{tabname}\{sourcefile}.json file
                                $ProjectData[$key] | ConvertTo-Json | Out-File -FilePath "$($controlDirectory)\.psproj\files\$($keyParts[0])\$($keyParts[1]).json" -Encoding ascii
                                
                                # just propagate all the existing data the way it was in the .psproj file.
                                $newProjectData.Add($key, $projectData[$key])
                            } else {
                                $newProjectData.Add($key, $projectData[$key])
                            }
                        }
                        $item.UpgradeNeeded = $true
                        $item.UpgradeStatus = "Updated to latest"
                        $continueProcessing = $true

                    } else {
                        $continueProcessing = $false
                    }                         

                    
                }


                if ( ( $dataVersion.Version -eq "1.1" ) -and ( $continueProcessing -eq $true ) )
                {
                    #upgrade from 1.1
                    Write-Verbose "Update from 1.1"
                    $projectData["ISEPSProjectDataVersion"] = "1.2"

                    if ( $ProjectFile.StartsWith(".\") )
                    {
                        $projectFileKey = $ProjectFile.SubString(2)
                    }    
                    $newProjectData = @{}
                    foreach ( $key in $projectData.Keys )
                    {
                        if ( ( $key -ne $projectFileKey ) -and ( $key -ne "ISEPSProjectDataVersion" ) ) 
                        {
                            $newStruct = "" | Select-Object FileName,ProjectTab,IncludeInBuild,ReadMeOrder
                            $newStruct.FileName = $projectData[$key].FileName
                            $newStruct.ProjectTab = $projectData[$key].ProjectTab
                            $newStruct.IncludeInBuild = $projectData[$key].IncludeInBuild
                            $newStruct.ReadMeOrder = "99"
                            $newProjectData.Add($key, $newStruct)
                        } else {
                            $newProjectData.Add($key, $projectData[$key])
                        }
                    }
                    $item.UpgradeNeeded = $true
                    $item.UpgradeStatus = "Updated to latest"
                    $continueProcessing = $true
                    
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
