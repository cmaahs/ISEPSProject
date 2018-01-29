<#
.Synopsis
   Set some default values for common parameters (-ProjectFile and -IncludeInBuild)
.DESCRIPTION
   To avoid having to constantly call out the -ProjectFile and -IncludeInBuild parameters we will store some default values in .\.psproj\defaults.clixml file.
   All commands that have these parameters will attempt to read the defaults.clixml data if the parameter is excluded from the command.
.EXAMPLE
PS> Set-PowershellProjectDefaults -ProjectFile .\ISEPSProject.psproj

PS> Set-PowershellProjectDefaults -IncludeInBuild No

PS> Get-PowershellProjectDefaultProjectFile
.\ISEPSProject.psproj

PS> Get-PowershellProjectDefaultIncludeInBuild
False

#>
Function Set-PowershellProjectDefaults
{
    [CmdletBinding()]
    Param
    (
        <#PINC:ProjectFile#>
        ,
        # Specify Yes/No to set the default IncludeInBuild to be used when running the Add-SourceToPowershellProject command.
        [Parameter(Mandatory=$false,
                   Position=1)]
        [ValidateSet("Don't Modify","Yes","No")]
        [string]
        $IncludeInBuild = "Don't Modify"
        ,
        # Specify IncludeStyle/SingleFileStyle to set the default BuildStyle to be used when running the Build-PowershellProject command.
        [Parameter(Mandatory=$false,
                   Position=2)]
        [ValidateSet("Don't Modify","IncludeStyle","SingleFileStyle")]
        [string]
        $BuildStyle = "Don't Modify"
        ,
        # Specify Local Deploy Directory to set the default directory to be used when running the Deploy-PowershellProject command.
        [Parameter(Mandatory=$false,
                   Position=3)]
        [ValidateScript( { Test-Path $_ } )]
        [string]
        $LocalDeployDirectory = ("$($HOME)\Documents\WindowsPowerShell\Modules\$((Get-ChildItem $ProjectFile).BaseName)\")
        ,
        # Specify the Module INIT file (file to be loaded LAST) when running Build-PowershellProject command.  Use "-" to remove.
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
                $defaults = "" | Select-Object ProjectFile,IncludeInBuild,BuildStyle,LocalDeployDirectory,ModuleInitFile
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
                    
                } else {
                    #create new
                    $defaults = "" | Select-Object ProjectFile,IncludeInBuild,BuildStyle,LocalDeployDirectory,ModuleInitFile
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
                }
            }
            Save-PowershellProjectDefaults -DefaultData $defaults
        }
    }
}
