<#
.Synopsis
   Create a single PSM1 file from the PS1 files included in the .psproj file.  Because the ISE editor doesn't yet have great code navigation tools, it is easier to have smaller source files opened separately.
.DESCRIPTION
   This process will loop through the Source files and check for the IncludeInBuild flag.  Any source file with the include flag will be copied into the {projectname}.psm1 file. 
.EXAMPLE
   PS> Build-PowershellProject -ProjectFile ISEPSProject.psproj -Force

Build Created.
All functions export: FunctionsToExport = @('Add-SourceToPowershellProject','Build-PowershellProject','Clean-PowershellProject','Close-PowershellProject','Create-PowershellProjec
t','Get-PowershellProject','Open-PowershellProject','Remove-SourceFromPowershellProject','Set-IncludeInBuildFlagForSource','Set-PowershellProjectDefaults','Get-CSVFromStringArray
','Get-PowershellProjectBackupData','Get-PowershellProjectCurrentVersion','Get-PowershellProjectDefaultIncludeInBuild','Get-PowershellProjectDefaultProjectFile','Get-PowershellPr
ojectFunctions','Get-PowershellProjectVersion','Save-PowershellProject','Save-PowershellProjectDefaults','Update-PowershellProjectVersion')
#>
Function Build-PowershellProject
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
        # Force overwrite of the existing psm1 file.
        [Parameter(Mandatory=$false,
                   Position=1)]
        [switch]
        $Force = $false
        ,
        # Add an NTFS streams version of the existing module content to the newly created psm1 file.
        [Parameter(Mandatory=$false,
                   Position=2)]
        [switch]
        $PerformBackup = $false
    )

    Begin
    {
        $continueProcessing = $true
        $commonParameters = Get-CommonParameters
        $buildStyle = (Get-PowershellProjectDefaultBuildStyle)
        if ( $ProjectFile -ne "" ) 
        {            
            if ( -not ( Test-Path $ProjectFile ) ) 
            {
                Write-Warning "Cannot locate the specified ProjectFile"
                Write-Warning "The Build-PowershellProject command must be run from the project ROOT (containing the .psproj file)"
                $continueProcessing = $false
            }        
        } else {
            Write-Warning "Must specify the -ProjectFile, or use Set-PowershellProjectDefaults command to set a default ProjectFile"
            Write-Warning "The Build-PowershellProject command must be run from the project ROOT (containing the .psproj file)"
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
            if ( (Get-PowershellProjectVersion -ProjectFile $ProjectFile).IsLatest -eq $false )
            {
                Update-PowershellProjectVersion -ProjectFile $ProjectFile
            }
            $projectData = Import-Clixml -Path $ProjectFile
            
            $newModule = @()

            if ( $ProjectFile.StartsWith(".\") )
            {
                $projectFileKey = $ProjectFile.SubString(2)
            }        
            if ( $projectData.ContainsKey($projectFileKey) )
            {
                $projectData.Remove($projectFileKey)
            }
            if ( $projectData.ContainsKey("ISEPSProjectDataVersion") )
            {
                $projectData.Remove("ISEPSProjectDataVersion")
            }
           
            if ( $buildStyle -eq "SingleFileStyle" )
            {
                foreach ( $key in $projectData.Keys )
                {
                    if ( $continueProcessing -eq $true )
                    {
                        if ( $projectData[$key].IncludeInBuild -eq $true ) 
                        {
                            Write-Verbose "Processing $($key)..."
                            $psData = Get-Content -Path $key
                            if ( ($psData | Where-Object { $_.Trim().StartsWith("<#PINC:") }).Count -gt 0 ) 
                            {
                                if ( $commonParameters ) 
                                {
                                    $pCount = 0
                                    $newData = ""
                                    foreach ( $line in $psData ) 
                                    {
                                        if ( $line.Trim().StartsWith("<#PINC:") )
                                        {
                                            $incfile = ($line.Split(":")[1]).Replace("#>","")
                                            Write-Verbose "Include File: $($incfile)"
                                            if ( $commonParameters[$incfile].Contains("~x~") ) 
                                            {
                                                $newData += ($commonParameters[$incfile]).Replace("~x~", $pCount)
                                                $pCount++
                                            } else {
                                                $newData += $commonParameters[$incfile]
                                            }
                                            $newData += "`r`n"                                        
                                        } else {
                                            $newData += "$($line)`r`n"
                                        }
                                        if ( $line.Trim().StartsWith("[Parameter") )
                                        {
                                            $pCount++
                                        }
                                    }
                                    $newModule += $newData
                                } else {
                                    Write-Error "There is a <#PINC:#> include reference, yet no .\.psproj\commonParameters.clixml exists."
                                    $continueProcessing = $false
                                }
                            } else {
                                $newModule += $psData
                            }                    
                        } #include in build
                    } #continue processing
                }
            } #SingleFileStyle

            if ( $buildStyle -eq "IncludeStyle" )
            {
                $buildFolder = Get-BuildFolder -ProjectFile $ProjectFile
                Write-Verbose "Build Folder: $($buildFolder)"
                if ( Test-Path $buildFolder )
                {
                    Write-Verbose "Clearing Build Folder..."
                    Reset-BuildFolder -ProjectFile $ProjectFile
                }
                $buildFolder = Get-BuildFolder -ProjectFile $ProjectFile
                if ( -not ( Test-Path $buildFolder ) ) 
                {
                    $continueProcessing = $false
                }
                foreach ( $key in $projectData.Keys )
                {
                    if ( $continueProcessing -eq $true )
                    {
                        if ( $projectData[$key].IncludeInBuild -eq $true ) 
                        {
                            Write-Verbose "Processing $($key)..."
                            $psData = Get-Content -Path $key
                            if ( ($psData | Where-Object { $_.Trim().StartsWith("<#PINC:") }).Count -gt 0 ) 
                            {
                                if ( $commonParameters ) 
                                {
                                    $pCount = 0
                                    $newData = ""
                                    foreach ( $line in $psData ) 
                                    {
                                        if ( $line.Trim().StartsWith("<#PINC:") )
                                        {
                                            $incfile = ($line.Split(":")[1]).Replace("#>","")
                                            Write-Verbose "Include File: $($incfile)"
                                            if ( $commonParameters[$incfile].Contains("~x~") ) 
                                            {
                                                $newData += ($commonParameters[$incfile]).Replace("~x~", $pCount)
                                                $pCount++
                                            } else {
                                                $newData += $commonParameters[$incfile]
                                            }
                                            $newData += "`r`n"                                        
                                        } else {
                                            $newData += "$($line)`r`n"
                                        }
                                        if ( $line.Trim().StartsWith("[Parameter") )
                                        {
                                            $pCount++
                                        }
                                    }
                                    #Write File to .build folder
                                    Save-SourceToBuildFolder -ProjectFileItem $key -BuildContents $newData
                                } else {
                                    Write-Error "There is a <#PINC:#> include reference, yet no .\.psproj\commonParameters.clixml exists."
                                    $continueProcessing = $false
                                }
                            } else { #no <#PINC:" includes
                                #Write File to .build folder
                                $newData = ""
                                foreach ( $line in $psData ) 
                                {
                                    $newData += "$($line)`r`n"
                                }
                                Save-SourceToBuildFolder -ProjectFileItem $key -BuildContents $newData
                            }                    
                        } #include in build
                    } #continue processing
                }                
            } #IncludeStyle

            if ( $continueProcessing -eq $true )
            {
                if ( $buildStyle -eq "SingleFileStyle" )
                {
                    $moduleFile = "$((Get-ChildItem $ProjectFile).BaseName).psm1"
                    Write-Verbose "Module File Name: $($moduleFile)"
                    if ( Test-Path $moduleFile )
                    {
                        $backupModule = Get-Content $moduleFile
                    }

                    if ( ( ( Test-Path $moduleFile ) -and ( $Force -eq $true ) ) -or ( -Not ( Test-Path $moduleFile ) ) )
                    {
                        $initFile = (Get-PowershellProjectDefaultModuleInitFile)
                        if ( Test-Path $initFile )
                        {
                            $newModule += (Get-Content -Path $initFile)
                        }
                        $newModule | Out-File -FilePath $moduleFile -Force -Encoding ascii
                        if ( ( $PerformBackup -eq $true ) -and ( $backupModule.Length -gt 0 ) )
                        {
                            $backupName = (Get-Date).ToString('yyyy-MM-dd_HHmmss')
                            Add-Content -Path $moduleFile -Value $backupModule -Stream $backupName                    
                        }
                        $functionList = (Get-PowershellProjectFunctions -ProjectFile $ProjectFile -IncludedInBuildOnly -IncludeOnlyPublic | Sort-Object -Property SourceFile,FunctionName).FunctionName
                        $functionsToExport = "FunctionsToExport = @($(Get-CSVFromStringArray -StringArray $functionList -SingleQuotes))"
                        Write-Output "Build Created."
                        Write-Output "All functions export: $($functionsToExport)"
                    } else {
                        Write-Warning "You must specify the -Force switch in order to over-write the existing psm1 file."
                    }
                } #singlefilestyle
                if ( $buildStyle -eq "IncludeStyle" )
                {
                    $moduleFile = "$((Get-ChildItem $ProjectFile).BaseName).psm1"
                    Write-Verbose "Module File Name: $($moduleFile)"
                    if ( Test-Path $moduleFile )
                    {
                        $backupModule = Get-Content $moduleFile
                    }
                    if ( ( ( Test-Path $moduleFile ) -and ( $Force -eq $true ) ) -or ( -Not ( Test-Path $moduleFile ) ) )
                    {
                        $psmContent = New-IncludeBasedModuleFile -ProjectFile $ProjectFile
                        $initFile = (Get-PowershellProjectDefaultModuleInitFile)
                        if ( Test-Path $initFile )
                        {
                            $psmContent += (Get-Content -Path $initFile)
                        }
                        $psmContent | Out-File -FilePath $moduleFile -Force -Encoding ascii

                        if ( ( $PerformBackup -eq $true ) -and ( $backupModule.Length -gt 0 ) )
                        {
                            $backupName = (Get-Date).ToString('yyyy-MM-dd_HHmmss')
                            Add-Content -Path $moduleFile -Value $backupModule -Stream $backupName                    
                        }
                        $functionList = (Get-PowershellProjectFunctions -ProjectFile $ProjectFile -IncludedInBuildOnly -IncludeOnlyPublic | Sort-Object -Property SourceFile,FunctionName).FunctionName
                        $functionsToExport = "FunctionsToExport = @($(Get-CSVFromStringArray -StringArray $functionList -SingleQuotes))"
                        Write-Output "Build Created."
                        Write-Verbose "All functions export: $($functionsToExport)"
                    } else {
                        Write-Warning "You must specify the -Force switch in order to over-write the existing psm1 file."
                    }
                } #includestyle
            } #continue processing

            # PSD file creation
            if ( $continueProcessing -eq $true )
            {
                $psdSource = Get-PowershellProjectDefaultModulePSDFile

                if ( ( $psdSource -ne "" ) -and ( Test-Path $psdSource ) )
                {
                    $psdSourceContent = Get-Content $psdSource
                    $psdBuildContent = ""
                    foreach ( $psdLine in $psdSourceContent )
                    {
                        if ( $psdLine.Trim().StartsWith("FunctionsToExport") )
                        {
                            $psdBuildContent += "$($functionsToExport)`r`n"
                        } else {
                            $psdBuildContent += "$($psdLine)`r`n"
                        }
                    }
                    $psdBuild = "$((Get-ChildItem $ProjectFile).BaseName).psd1"
                    $psdBuildContent | Out-File -FilePath $psdBuild -Force -Encoding ascii
                }
            } #continue processing
        
        } #continue processing
    }
}

