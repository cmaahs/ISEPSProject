Function Start-PspBuildPowershellProject
{
<#
.Synopsis
   Create a single PSM1 file from the PS1 files included in the .psproj file.  Because the ISE editor doesn't yet have great code navigation tools, it is easier to have smaller source files opened separately.
.DESCRIPTION
   This process will loop through the Source files and check for the IncludeInBuild flag.  Any source file with the include flag will be copied into the {projectname}.psm1 file. 
.EXAMPLE
   Start-PspBuildPowershellProject -ProjectFile ISEPSProject.psproj -Force

Build Created.
All functions export: FunctionsToExport = @('Add-PspSourceToPowershellProject','Start-PspBuildPowershellProject','Repair-PspPowershellProject','Close-PspPowershellProject','Create-PowershellProjec
t','Get-PspPowershellProject','Open-PspPowershellProject','Remove-PspSourceFromPowershellProject','Set-PspIncludeInBuildFlagForSource','Set-PspPowershellProjectDefaults','Get-PspCSVFromStringArray
','Get-PspPowershellProjectBackupData','Get-PspPowershellProjectCurrentVersion','Get-PspPowershellProjectDefaultIncludeInBuild','Get-PspPowershellProjectDefaultProjectFile','Get-PowershellPr
ojectFunctions','Get-PspPowershellProjectVersion','Save-PspPowershellProject','Save-PspPowershellProjectDefaults','Update-PspPowershellProjectVersion')
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
        $commonParameters = Get-PspCommonParameters
        $buildStyle = (Get-PspPowershellProjectDefaultBuildStyle)
        if ( $ProjectFile -ne "" ) 
        {            
            if ( -not ( Test-Path $ProjectFile ) ) 
            {
                Write-Warning "Cannot locate the specified ProjectFile"
                Write-Warning "The Start-PspBuildPowershellProject command must be run from the project ROOT (containing the .psproj file)"
                $continueProcessing = $false
            }        
        } else {
            Write-Warning "Must specify the -ProjectFile, or use Set-PspPowershellProjectDefaults command to set a default ProjectFile"
            Write-Warning "The Start-PspBuildPowershellProject command must be run from the project ROOT (containing the .psproj file)"
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
            if ( (Get-PspPowershellProjectVersion -ProjectFile $ProjectFile).IsLatest -eq $false )
            {
                Update-PspPowershellProjectVersion -ProjectFile $ProjectFile
            }
            $projectData = Import-Clixml -Path $ProjectFile
            
            $newModule = @()

            $projectFileKey = $ProjectFile
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
                $readmeData = @{}
                $functionListByFile = @{}
                foreach ( $key in $projectData.Keys )
                {
                    $functionName = ""
                    $functionList = @()                    
                    if ( $continueProcessing -eq $true )
                    {
                        if ( $projectData[$key].IncludeInBuild -eq $true ) 
                        {
                            Write-Verbose "Processing $($key)..."
                            $psData = Get-Content -Path $key
                            $documentation = ""
                            #$gatheringDocumentation = $false
                            #grab all the function names in the file.
                            foreach ( $line in $psData )
                            {
                                if ( $line.Trim().StartsWith("Function ") ) #note, only document the Uppercase Function, not function
                                {
                                    $functionList += $line.Trim().Replace("Function ", "")
                                }                                
                            } #foreach line

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
                                    #Write File to .build folder
                                    $buildWrite = Save-PspSourceToBuildFolder -ProjectFileItem $key -BuildContents $newData
                                } else {
                                    Write-Error "There is a <#PINC:#> include reference, yet no .\.psproj\commonParameters.clixml exists."
                                    $continueProcessing = $false
                                }
                            } else {
                                $newModule += $psData
                                #Write File to .build folder
                                $newData = ""
                                foreach ( $line in $psData ) 
                                {
                                    $newData += "$($line)`r`n"
                                }
                                $buildWrite = Save-PspSourceToBuildFolder -ProjectFileItem $key -BuildContents $newData
                            }
                            $orderedKey = "$($projectData[$key].ReadmeOrder)~$($key)"
                            $functionListByFile.Add($orderedKey,$functionList)                    
                        } #include in build                                                
                    } #continue processing
                } #foreach key (file)
                #build the documentation      
                $sortedDocKey = $functionListByFile.Keys | Sort-Object      
                foreach ( $docKey in $sortedDocKey )
                {
                    $sortOrder = $docKey.Split("~")[0]
                    $buildPath = Get-PspBuildFolderPathForSource -ProjectFileItem $docKey.Split("~")[1]
                    if ( Test-Path -Path $buildPath )
                    {
                        if ( $buildPath.EndsWith("ps1") )
                        {
                            . $buildPath
                            foreach ( $exportedFunction in $functionListByFile[$docKey] )
                            {
                                $documentation = Get-Help $exportedFunction -Full | Out-String
                                $readmeData.Add("$($sortOrder)~$($exportedFunction)", $documentation)
                            }
                        }
                    }
                } #foreach docKey
            } #SingleFileStyle

            if ( $buildStyle -eq "IncludeStyle" )
            {
                $buildFolder = Get-PspBuildFolder -ProjectFile $ProjectFile
                Write-Verbose "Build Folder: $($buildFolder)"
                if ( Test-Path $buildFolder )
                {
                    Write-Verbose "Clearing Build Folder..."
                    Reset-PspBuildFolder -ProjectFile $ProjectFile
                }
                $buildFolder = Get-PspBuildFolder -ProjectFile $ProjectFile
                if ( -not ( Test-Path $buildFolder ) ) 
                {
                    $continueProcessing = $false
                }
                $readmeData = @{}                
                $functionListByFile = @{}
                foreach ( $key in $projectData.Keys )
                {
                    $functionName = ""
                    $functionList = @()
                    if ( $continueProcessing -eq $true )
                    {
                        if ( $projectData[$key].IncludeInBuild -eq $true ) 
                        {
                            Write-Verbose "Processing $($key)..."
                            $psData = Get-Content -Path $key

                            $documentation = ""
                            #grab all the function names in the file.
                            foreach ( $line in $psData )
                            {
                                if ( $line.Trim().StartsWith("Function ") ) #note, only document the Uppercase Function, not function
                                {
                                    $functionList += $line.Trim().Replace("Function ", "")
                                }                                
                            } #foreach line

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
                                    Save-PspSourceToBuildFolder -ProjectFileItem $key -BuildContents $newData
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
                                Save-PspSourceToBuildFolder -ProjectFileItem $key -BuildContents $newData
                            }
                            $orderedKey = "$($projectData[$key].ReadmeOrder)~$($key)"
                            $functionListByFile.Add($orderedKey,$functionList)                                    
                        } #include in build                        
                    } #continue processing
                } #foreach key (file)
                #build the documentation  
                $sortedDocKey = $functionListByFile.Keys | Sort-Object           
                foreach ( $docKey in $sortedDocKey )
                {          
                    $sortOrder = $docKey.Split("~")[0]
                    $buildPath = Get-PspBuildFolderPathForSource -ProjectFileItem $docKey.Split("~")[1]
                    if ( Test-Path -Path $buildPath )
                    {
                        if ( $buildPath.EndsWith("ps1") )
                        {
                            . $buildPath
                            foreach ( $exportedFunction in $functionListByFile[$docKey] )
                            {            
                                Write-Verbose "Calling Help for Exported Function: $($exportedFunction)"                    
                                $documentation = Get-Help $exportedFunction -Full | Out-String
                                $readmeData.Add("$($sortOrder)~$($exportedFunction)", $documentation)
                            }
                        }
                    }
                } #foreach docKey                               
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
                        $initFile = (Get-PspPowershellProjectDefaultModuleInitFile)
                        if ( $initFile.Length -gt 0 )
                        {
                            if ( Test-Path $initFile )
                            {
                                $newModule += (Get-Content -Path $initFile)
                            }
                        }
                        $newModule | Out-File -FilePath $moduleFile -Force -Encoding ascii
                        if ( ( $PerformBackup -eq $true ) -and ( $backupModule.Length -gt 0 ) )
                        {
                            $backupName = (Get-Date).ToString('yyyy-MM-dd_HHmmss')
                            Add-Content -Path $moduleFile -Value $backupModule -Stream $backupName                    
                        }
                        $functionList = (Get-PspPowershellProjectFunctions -ProjectFile $ProjectFile -IncludedInBuildOnly -IncludeOnlyPublic | Sort-Object -Property SourceFile,FunctionName).FunctionName
                        $functionsToExport = "FunctionsToExport = @($(Get-PspCSVFromStringArray -StringArray $functionList -SingleQuotes))"
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
                        $psmContent = New-PspIncludeBasedModuleFile -ProjectFile $ProjectFile
                        $initFile = (Get-PspPowershellProjectDefaultModuleInitFile)
                        if ( $initFile.Length -gt 0 )
                        {
                            if ( Test-Path $initFile )
                            {
                                $psmContent += "`r`n"
                                $initLines = Get-Content -Path $initFile
                                foreach ( $il in $initLines )
                                {
                                    $psmContent += "$($il)`r`n"
                                }
                            }
                        }
                        $psmContent | Out-File -FilePath $moduleFile -Force -Encoding ascii

                        if ( ( $PerformBackup -eq $true ) -and ( $backupModule.Length -gt 0 ) )
                        {
                            $backupName = (Get-Date).ToString('yyyy-MM-dd_HHmmss')
                            Add-Content -Path $moduleFile -Value $backupModule -Stream $backupName                    
                        }
                        $functionList = (Get-PspPowershellProjectFunctions -ProjectFile $ProjectFile -IncludedInBuildOnly -IncludeOnlyPublic | Sort-Object -Property SourceFile,FunctionName).FunctionName
                        $functionsToExport = "FunctionsToExport = @($(Get-PspCSVFromStringArray -StringArray $functionList -SingleQuotes))"
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
                $psdSource = Get-PspPowershellProjectDefaultModulePSDFile

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
            # README.md file creation
            if ( $continueProcessing -eq $true )
            {
                #$readmeData | Export-Clixml C:\users\Christopher.Maahs\readmeData.clixml
                $readmeSource = Get-PspPowershellProjectDefaultModuleREADMEFile
                
                if ( $readmeSource -ne $null )
                {
                    if ( ( $readmeSource -ne "" ) -and ( Test-Path $readmeSource ) )
                    {
                        $readmeSourceContent = Get-Content $readmeSource
                        $readmeList = @()
                        foreach ( $mdKey in $readmeData.Keys )
                        {
                            $item = "" | Select-Object ReadMeOrder,FunctionName,KeyName
                            $item.ReadMeOrder = [int]$mdKey.Split("~")[0]
                            $item.FunctionName = $mdKey.Split("~")[1]
                            $item.KeyName = $mdKey
                            $readmeList += $item
                        }
                        foreach ( $mdKey in ($readmeList | Sort-Object -Property ReadMeOrder) )
                        {
                            $readmeSourceContent += "#### $($mdKey.FunctionName)`r`n"
                            $readmeSourceContent += "``````powershell"
                            $readmeSourceContent += "$($readmeData[$mdKey.Keyname])" | Out-String
                            $readmeSourceContent += "``````"
                        }
                        $readmeBuildFile = "README.md"
                        $readmeSourceContent | Out-File -FilePath $readmeBuildFile -Force -Encoding ascii
                    }
                }
            } #continue processing    
            # ZIP File Processing 
            if ( $continueProcessing -eq $true )
            {
                $zf = Get-PspPowershellProjectDefaultModuleAdditionalZipFile
                if ( $zf ) 
                {
                    $rootPath = (Get-ChildItem ($ProjectFile)).Directory.FullName
                    if ( -not ( Test-Path $buildFolder ) ) 
                    {
                        $continueProcessing = $false
                    }
                    $sourceFile = $zf.ZipFile
                    if ( $zf.RelativeInstallPath.StartsWith(".") )
                    {
                        $destPath = "$($rootPath)$($zf.RelativeInstallPath.Substring(1))"
                    } else {
                        $destPath = "$($rootPath)$($zf.RelativeInstallPath)"
                    }
                    Expand-Archive -Path $sourceFile -DestinationPath $destPath
                }                           
            } #continue processing    
        } #continue processing
    }
}

