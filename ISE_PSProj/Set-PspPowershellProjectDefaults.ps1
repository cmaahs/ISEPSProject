Function Set-PspPowershellProjectDefaults
{
<#
.Synopsis
   Set some default values for common parameters (-ProjectFile and -IncludeInBuild)
.DESCRIPTION
   To avoid having to constantly call out the -ProjectFile and -IncludeInBuild parameters we will store some default values in .\.psproj\defaults.clixml file.
   All commands that have these parameters will attempt to read the defaults.clixml data if the parameter is excluded from the command.
.EXAMPLE
    Set-PspPowershellProjectDefaults -ProjectFile .\ISEPSProject.psproj

    Set-PspPowershellProjectDefaults -IncludeInBuild No

    Get-PspPowershellProjectDefaultProjectFile

.\ISEPSProject.psproj

    Get-PspPowershellProjectDefaultIncludeInBuild
False

.EXAMPLE
    Get-PspPowershellProjectDefaults

ProjectFile          : .\ISEPSProject.psproj
IncludeInBuild       : False
BuildStyle           : IncludeStyle
LocalDeployDirectory : C:\Program Files\WindowsPowerShell\Modules\ISEPSProject
ModuleInitFile       : .\ISE_PSProj\Module_Init.ps1
ModulePSDFile        : .\ISE_PSProj\ISEPSProject.psd1
ModuleREADMEFile     : .\ISE_PSProj\README.md
PreBuildCommand      : Add-PSAddin SwisAddIn; Get-Help Connect-Swis -Full

.EXAMPLE
Set the Build Style of the project.  Single PSM1 file, or an Include PSM1 file that imports single PS1 files.

    Set-PspPowershellProjectDefaults -BuildStyle IncludeStyle

.EXAMPLE
Set the Local Deploy directory.  The Start-PspDeployPowershellProject function uses this setting.

    Set-PspPowershellProjectDefaults -LocalDeployDirectory C:\Program Files\WindowsPowerShell\Modules\ISEPSProject

.EXAMPLE
Set the PSD file for the project.  Do NOT reference this file in the ROOT of the project.  This "source" version will be used as a template to build the module psd1 file in the ROOT of the project.  
The reason for this is so we can simply check out from Git into a Modules directory and have the module function correctly.

    Set-PspPowershellProjectDefaults -ModulePSDFile .\ISE_PSProj\ISEPSProject.psd1

.EXAMPLE
Set the Module Init file.  This is a PS1 file that will be RUN upon loading (Import-Module) the module into your session.

    Set-PspPowershellProjectDefaults -ModuleInitFile .\ISE_PSProj\Module_Init.ps1

#>
    [CmdletBinding()]
    Param
    (
        <#PINC:ProjectFile#>
        <#PINC:PARAMCOMMA#>
        # Specify Yes/No to set the default IncludeInBuild to be used when running the Add-PspSourceToPowershellProject command.
        [Parameter(Mandatory=$false,
                   Position=1)]
        [ValidateSet("Don't Modify","Yes","No")]
        [string]
        $IncludeInBuild = "Don't Modify"
        ,
        # Specify IncludeStyle/SingleFileStyle to set the default BuildStyle to be used when running the Start-PspBuildPowershellProject command.
        [Parameter(Mandatory=$false,
                   Position=2)]
        [ValidateSet("Don't Modify","IncludeStyle","SingleFileStyle")]
        [string]
        $BuildStyle = "Don't Modify"
        ,
        # Specify Local Deploy Directory to set the default directory to be used when running the Start-PspDeployPowershellProject command.
        [Parameter(Mandatory=$false,
                   Position=3)]
        [ValidateScript( { Test-Path $_ } )]
        [string]
        $LocalDeployDirectory = ("$($HOME)\Documents\WindowsPowerShell\Modules\$((Get-ChildItem $ProjectFile).BaseName)\")
        ,
        # Specify the Module INIT file (file to be loaded LAST) when running Start-PspBuildPowershellProject command.  Use "-" to remove.
        [Parameter(Mandatory=$false,
                   Position=4)]
        [ValidateScript( { ( ( $_ -eq "" ) -or (Test-Path $_) ) } )]
        [string]
        $ModuleInitFile
        ,
        # Specify the location of the PSD1 file.  Use "-" to remove.
        [Parameter(Mandatory=$false,
                   Position=5)]
        [ValidateScript( { ( ( $_ -eq "" ) -or (Test-Path $_) ) } )]
        [string]
        $ModulePSDFile
        ,
        # Specify the location of the README.md file.  Use "-" to remove.
        [Parameter(Mandatory=$false,
                   Position=6)]
        [ValidateScript( { ( ( $_ -eq "" ) -or (Test-Path $_) ) } )]
        [string]
        $ModuleREADMEFile
        ,
        # Add a ZIP file
        [Parameter(Mandatory=$false,
                   Position=6)]
        [ValidateScript( { ( ( $_.ZipFile -eq "-" ) -or ( Test-Path $_.ZipFile ) ) } )]        
        $ModuleAdditionalZipFile
        ,
        # Add a command to run prior to starting a build.
        [Parameter(Mandatory=$false,
                   Position=7)]
        $PreBuildCommand
    )

    Begin
    {
        $continueProcessing = $true
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
            if ( -not ( Test-Path ".\.psproj" ) )
            {
                New-Item -Path ".\.psproj" -ItemType Directory
                #create new
                $defaults = "" | Select-Object ProjectFile,IncludeInBuild,BuildStyle,LocalDeployDirectory,ModuleInitFile,ModuleREADMEFile,ModuleAdditionalZipFile,PreBuildCommand
                if ( ( $ProjectFile -ne "" ) -and ( Test-Path $ProjectFile ) ) 
                {
                    $defaults.ProjectFile = $ProjectFile
                }
                if ( $IncludeInBuild -eq "Yes" )
                {
                    $defaults.IncludeInBuild = $true 
                } else {
                    $defaults.IncludeInBuild = $false
                }   
                if ( $BuildStyle -eq "SingleFileStyle" )
                {
                    $defaults.BuildStyle = "SingleFileStyle"
                } else {
                    $defaults.BuildStyle = "IncludeStyle"
                } 
                if ( ( $LocalDeployDirectory -ne "" ) -and ( Test-Path $LocalDeployDirectory ) )
                {
                    $defaults.LocalDeployDirectory = $LocalDeployDirectory
                }
                if ( ( $ModuleInitFile -ne "" ) -and ( Test-Path $ModuleInitiFile ) )
                {
                    $defaults.ModuleInitFile = $ModuleInitFile
                }
                if ( ( $ModulePSDFile -ne "" ) -and ( Test-Path $ModulePSDFile ) )
                {
                    $defaults.ModulePSDFile = $ModulePSDFile
                }
                if ( ( $ModuleREADMEFile -ne "" ) -and ( Test-Path $ModuleREADMEFile ) )
                {
                    $defaults.ModuleREADMEFile = $ModuleREADMEFile
                } 
                if ( $ModuleAdditionalZipFile ) 
                {
                    $defaults.ModuleAdditionalZipFile = "$($ModuleAdditionalZipFile.ZipFile)|$($ModuleAdditionalZipFile.RelativeInstallPath)"
                }     
                if ( $PreBuildCommand.Length -gt 0 )
                {
                    $defaults.PreBuildCommand = $PreBuildCommand
                }                  
            } else {
                if ( Test-Path ".\.psproj\defaults.clixml" )
                {
                    #read and update
                    $defaults = Import-Clixml -Path ".\.psproj\defaults.clixml"
                    if ( ( $ProjectFile -ne "" ) -and ( Test-Path $ProjectFile ) ) 
                    {
                        if ([bool]($defaults.PSobject.Properties.Name -match "ProjectFile")) 
                        {
                            $defaults.ProjectFile = $ProjectFile
                        } else {
                            Add-Member -InputObject $defaults -MemberType NoteProperty -Name ProjectFile -Value "$($ProjectFile)"
                        }
                    }
                    if ( $IncludeInBuild -ne "Don't Modify" ) 
                    {
                        if ([bool]($defaults.PSobject.Properties.Name -match "IncludeInBuild")) 
                        {
                            if ( $IncludeInBuild -eq "Yes" )
                            {
                                $defaults.IncludeInBuild = $true 
                            } else {
                                $defaults.IncludeInBuild = $false
                            }
                        } else {
                            if ( $IncludeInBuild -eq "Yes" )
                            {
                                Add-Member -InputObject $defaults -MemberType NoteProperty -Name IncludeInBuild -Value $true
                            } else {
                                Add-Member -InputObject $defaults -MemberType NoteProperty -Name IncludeInBuild -Value $false
                            }
                        }
                    }
                    if ( $BuildStyle -ne "Don't Modify" )
                    {
                        if ([bool]($defaults.PSobject.Properties.Name -match "BuildStyle")) 
                        {
                            $defaults.BuildStyle = $BuildStyle
                        } else {                       
                            Add-Member -InputObject $defaults -MemberType NoteProperty -Name BuildStyle -Value "$($BuildStyle)"
                        }                       
                    }
                    if ( ( $LocalDeployDirectory -eq "-" ) -or ( $LocalDeployDirectory -ne "" ) -and ( Test-Path $LocalDeployDirectory ) )
                    {
                        if ([bool]($defaults.PSobject.Properties.Name -match "LocalDeployDirectory")) 
                        {
                            if ( $LocalDeployDirectory -eq "-" ) 
                            {
                                $defaults.LocalDeployDirectory = ""
                            } else {
                                $defaults.LocalDeployDirectory = $LocalDeployDirectory
                            }
                        } else {                       
                            if ( -not ( $LocalDeployDirectory -eq "-" ) )
                            {
                                Add-Member -InputObject $defaults -MemberType NoteProperty -Name LocalDeployDirectory -Value "$($LocalDeployDirectory)"
                            }
                        }                                               
                    }
                    if ( ( $ModuleInitFile -eq "-" ) -or ( ( $ModuleInitFile -ne "" ) -and ( Test-Path $ModuleInitFile ) ) )
                    {
                        if ([bool]($defaults.PSobject.Properties.Name -match "ModuleInitFile")) 
                        {
                            if ( $ModuleInitFile -eq "-" ) 
                            {
                                $defaults.ModuleInitFile = ""
                            } else {
                                $defaults.ModuleInitFile = $ModuleInitFile
                            }
                        } else {                       
                            if ( -not ( $ModuleInitFile -eq "-" ) )
                            {
                                Add-Member -InputObject $defaults -MemberType NoteProperty -Name ModuleInitFile -Value "$($ModuleInitFile)"
                            }
                        }                                               
                    }
                    if ( ( $ModulePSDFile -eq "-" ) -or ( ( $ModulePSDFile -ne "" ) -and ( Test-Path $ModulePSDFile ) ) )
                    {
                        if ([bool]($defaults.PSobject.Properties.Name -match "ModulePSDFile")) 
                        {
                            if ( $ModulePSDFile -eq "-" )
                            {
                                $defaults.ModulePSDFile = ""
                            } else {
                                $defaults.ModulePSDFile = $ModulePSDFile
                            }
                        } else {                       
                            if ( -not ( $ModulePSDFile -eq "-" ) ) 
                            {
                                Add-Member -InputObject $defaults -MemberType NoteProperty -Name ModulePSDFile -Value "$($ModulePSDFile)"
                            }
                        }                                               
                    }
                    if ( ( $ModuleREADMEFile -eq "-" ) -or ( ( $ModuleREADMEFile -ne "" ) -and ( Test-Path $ModuleREADMEFile ) ) )
                    {
                        if ([bool]($defaults.PSobject.Properties.Name -match "ModuleREADMEFile")) 
                        {
                            if ( $ModuleREADMEFile -eq "-" )
                            {
                                $defaults.ModuleREADMEFile = ""
                            } else {
                                $defaults.ModuleREADMEFile = $ModuleREADMEFile
                            }
                        } else {                       
                            if ( -not ( $ModuleREADMEFile -eq "-" ) ) 
                            {
                                Add-Member -InputObject $defaults -MemberType NoteProperty -Name ModuleREADMEFile -Value "$($ModuleREADMEFile)"
                            }
                        }                                               
                    }
                    if ( $ModuleAdditionalZipFile )
                    {
                        if ([bool]($defaults.PSobject.Properties.Name -match "ModuleAdditionalZipFile")) 
                        {
                            if ( $ModuleAdditionalZipFile.ZipFile -eq "-" )
                            {
                                $defaults.ModuleAdditionalZipFile = ""
                            } else {
                                $defaults.ModuleAdditionalZipFile = "$($ModuleAdditionalZipFile.ZipFile)|$($ModuleAdditionalZipFile.RelativeInstallPath)"
                            }
                        } else {                       
                            if ( -not ( $ModuleAdditionalZipFile.ZipFile -eq "-" ) ) 
                            {
                                Add-Member -InputObject $defaults -MemberType NoteProperty  -Name ModuleAdditionalZipFile -Value "$($ModuleAdditionalZipFile.ZipFile)|$($ModuleAdditionalZipFile.RelativeInstallPath)"
                            }
                        }                                               
                    }
                    if ( ( $PreBuildCommand -eq "-" ) -or ( $PreBuildCommand.Length -gt 0 ) )
                    {
                        if ([bool]($defaults.PSobject.Properties.Name -match "PreBuildCommand")) 
                        {
                            if ( $PreBuildCommand -eq "-" )
                            {
                                $defaults.PreBuildCommand = ""
                            } else {
                                $defaults.PreBuildCommand = $PreBuildCommand
                            }
                        } else {                       
                            if ( -not ( $PreBuildCommand -eq "-" ) ) 
                            {
                                Add-Member -InputObject $defaults -MemberType NoteProperty -Name PreBuildCommand -Value "$($PreBuildCommand)"
                            }
                        }                                               
                    }

                    
                } else {
                    #create new
                    $defaults = "" | Select-Object ProjectFile,IncludeInBuild,BuildStyle,LocalDeployDirectory,ModuleInitFile,ModuleREADMEFile,ModuleAdditionalZipFile,PreBuildCommand
                    if ( ( $ProjectFile -ne "" ) -and ( Test-Path $ProjectFile ) ) 
                    {
                        $defaults.ProjectFile = $ProjectFile
                    }
                    if ( $IncludeInBuild -eq "Yes" )
                    {
                        $defaults.IncludeInBuild = $true 
                    } else {
                        $defaults.IncludeInBuild = $false
                    }
                    if ( $BuildStyle -eq "SingleFileStyle" )
                    {
                        $defaults.BuildStyle = "SingleFileStyle"
                    } else {
                        $defaults.BuildStyle = "IncludeStyle"
                    }
                    if ( ( $LocalDeployDirectory -ne "" ) -and ( Test-Path $LocalDeployDirectory ) )
                    {
                        $defaults.LocalDeployDirectory = $LocalDeployDirectory
                    }
                    if ( ( $ModuleInitFile -ne "" ) -and ( Test-Path $ModuleInitFile ) )
                    {
                        $defaults.ModuleInitFile = $ModuleInitFile
                    }
                    if ( ( $ModulePSDFile -ne "" ) -and ( Test-Path $ModulePSDFile ) )
                    {
                        $defaults.ModulePSDFile = $ModulePSDFile
                    }
                    if ( ( $ModuleREADMEFile -ne "" ) -and ( Test-Path $ModuleREADMEFile ) )
                    {
                        $defaults.ModuleREADMEFile = $ModuleREADMEFile
                    }
                    if ( $ModuleAdditionalZipFile )
                    {
                        $defaults.ModuleAdditionalZipFile = "$($ModuleAdditionalZipFile.ZipFile)|$($ModuleAdditionalZipFile.RelativeInstallPath)"
                    }
                    if ( $PreBuildCommand.Length -gt - 0 )
                    {
                        $defaults.PreBuildCommand = $PreBuildCommand
                    }
                }
            }
            Save-PspPowershellProjectDefaults -DefaultData $defaults
        }
    }
}
