Function Get-PspPowershellProjectDefaults
{
<#
.Synopsis
   Save a .psproj\defaults.clixml file.  This will allow you to skip the -ProjectFile parameter and sets the default IncludeInBuild option for adding items to the project.
.DESCRIPTION
   This is simply a file that will be read by each of the commands in order to pre-populate the -ProjectFile and -IncludeInBuild parameters.

.EXAMPLE
    $default = "" | Select-Object ProjectFile,IncludeInBuild,BuildStyle
    $defualt.ProjectFile = ".\ISEPSProject.psproj"
    $default.IncludeInBuild = $true
    $default.BuildStyle = "IncludeStyle"
    Save-PspPowershellProjectDefaults -DefaultData $default
#>
    [CmdletBinding()]
    Param
    (       
    )

    Begin
    {     
        if ( Test-Path ".\.psproj\defaults.clixml" )
        {
            $DefaultData = Import-Clixml -Path ".\.psproj\defaults.clixml"
        }
               
    }
    Process
    {
        
    }
    End
    {
        Write-Output $DefaultData | Format-List
    }
}

function Save-PspPowershellProjectDefaults
{
<#
.Synopsis
   Save a .psproj\defaults.clixml file.  This will allow you to skip the -ProjectFile parameter and sets the default IncludeInBuild option for adding items to the project.
.DESCRIPTION
   This is simply a file that will be read by each of the commands in order to pre-populate the -ProjectFile and -IncludeInBuild parameters.

.EXAMPLE
    $default = "" | Select-Object ProjectFile,IncludeInBuild,BuildStyle
    $defualt.ProjectFile = ".\ISEPSProject.psproj"
    $default.IncludeInBuild = $true
    $default.BuildStyle = "IncludeStyle"
    Save-PspPowershellProjectDefaults -DefaultData $default
#>
    [CmdletBinding()]
    Param
    (
        # Default data in the form of $default = "" | Select-Object ProjectFile,IncludeInBuild,BuildStyle
        [Parameter(Mandatory=$true,
                   Position=0)]
        [PSObject]
        $DefaultData
    )

    Begin
    {        
    }
    Process
    {
        $DefaultData | Export-Clixml -Path ".\.psproj\defaults.clixml" -Force
    }
    End
    {
    }
}

function Get-PspPowershellProjectDefaultProjectFile
{
<#
.Synopsis
   Extract the ProjectFile default from .psproj\defaults.clixml file.
.DESCRIPTION
   Called by the commands to fetch the default value for ProjectFile.

.EXAMPLE
For Use in [Parameters]
   $ProjectFile = (Get-PspPowershellProjectDefaultProjectFile)
#>
    [CmdletBinding()]
    Param
    (       
    )

    Begin
    {        
    }
    Process
    {
        if ( Test-Path ".\.psproj\defaults.clixml" ) 
        {
            $defaults = Import-Clixml -Path ".\.psproj\defaults.clixml"
            if ( Test-Path $defaults.ProjectFile ) 
            {
                Write-Output $defaults.ProjectFile
            } else {
                Write-Output ""
            }
        } else {
            Write-Output ""
        }
    }
    End
    {
    }
}

function Get-PspPowershellProjectDefaultIncludeInBuild
{
<#
.Synopsis
   Extract the IncludeInBuild default from .psproj\defaults.clixml file.
.DESCRIPTION
   Called by the commands to fetch the default value for IncludeInBuild.

.EXAMPLE
For Use in [Parameters]
   $IncludeInBuild = (Get-PspPowershellProjectDefaultIncludeInBuild)
#>
    [CmdletBinding()]
    Param
    (    
    )

    Begin
    {        
    }
    Process
    {
        if ( Test-Path ".\.psproj\defaults.clixml" ) 
        {
            $defaults = Import-Clixml -Path ".\.psproj\defaults.clixml"
            Write-Output $defaults.IncludeInBuild
        } else {
            Write-Output $false
        }
    }
    End
    {
    }
}

function Get-PspCommonParameters
{
<#
.Synopsis
   Get the Common Parameters
.DESCRIPTION
   Read the Common Parameters from the .psproj directory, commonParameters.clixml file.

.EXAMPLE
   $commonParameters = Get-PspCommonParameters
#>
    [CmdletBinding()]
    Param
    (    
    )

    Begin
    {        
    }
    Process
    {
        if ( Test-Path ".\.psproj\commonParameters.clixml" ) 
        {
            $commonParams = Import-Clixml -Path ".\.psproj\commonParameters.clixml"
            Write-Output $commonParams
        } else {
            Write-Output $false
        }
    }
    End
    {
    }
}

function Get-PspPowershellProjectDefaultBuildStyle
{
<#
.Synopsis
   Extract the BuildStyle default from .psproj\defaults.clixml file.
.DESCRIPTION
   Called by the commands to fetch the default value for BuildStyle.

.EXAMPLE
For Use in [Parameters]
   $BuildStyle = (Get-PspPowershellProjectDefaultBuildStyle)
#>
    [CmdletBinding()]
    Param
    (    
    )

    Begin
    {        
    }
    Process
    {
        if ( Test-Path ".\.psproj\defaults.clixml" ) 
        {
            $defaults = Import-Clixml -Path ".\.psproj\defaults.clixml"
            if ( $defaults.BuildStyle )
            {
                Write-Output $defaults.BuildStyle
            } else {
                Write-Output "SingleFileStyle"
            }
        } else {
            Write-Output "SingleFileStyle"
        }
    }
    End
    {
    }
}

function Get-PspPowershellProjectDefaultLocalDeployDirectory
{
<#
.Synopsis
   Extract the BuildStyle default from .psproj\defaults.clixml file.
.DESCRIPTION
   Called by the commands to fetch the default value for BuildStyle.

.EXAMPLE
For Use in [Parameters]
   $BuildStyle = (Get-PspPowershellProjectDefaultBuildStyle)
#>
    [CmdletBinding()]
    Param
    (    
    )

    Begin
    {   
        if ( Test-Path ".\.psproj\defaults.clixml" ) 
        {
            $defaults = Import-Clixml -Path ".\.psproj\defaults.clixml"
        }     
    }
    Process
    {
    }
    End
    {
        Write-Output $defaults.LocalDeployDirectory
    }
}

function Get-PspPowershellProjectDefaultModuleInitFile
{
<#
.Synopsis
   Extract the BuildStyle default from .psproj\defaults.clixml file.
.DESCRIPTION
   Called by the commands to fetch the default value for BuildStyle.

.EXAMPLE
For Use in [Parameters]
   $BuildStyle = (Get-PspPowershellProjectDefaultBuildStyle)
#>
    [CmdletBinding()]
    Param
    (    
    )

    Begin
    {        
    }
    Process
    {
        if ( Test-Path ".\.psproj\defaults.clixml" ) 
        {
            $defaults = Import-Clixml -Path ".\.psproj\defaults.clixml"
        }
    }
    End
    {
        Write-Output $defaults.ModuleInitFile
    }
}

function Get-PspPowershellProjectDefaultModulePSDFile
{
<#
.Synopsis
   Extract the ModulePSDFile default from .psproj\defaults.clixml file.
.DESCRIPTION
   Called by the commands to fetch the default value for ModulePSDFile.

.EXAMPLE
For Use in [Parameters]
   $modulePSDFile = (Get-PspPowershellProjectDefaultModulePSDFile)
#>
    [CmdletBinding()]
    Param
    (    
    )

    Begin
    {        
    }
    Process
    {
        if ( Test-Path ".\.psproj\defaults.clixml" ) 
        {
            $defaults = Import-Clixml -Path ".\.psproj\defaults.clixml"
        }
    }
    End
    {
        Write-Output $defaults.ModulePSDFile
    }
}

function Get-PspPowershellProjectDefaultModuleREADMEFile
{
<#
.Synopsis
   Extract the README.md default from .psproj\defaults.clixml file.
.DESCRIPTION
   Called by the commands to fetch the default value for README.

.EXAMPLE
For Use in [Parameters]
   $readmeFile = (Get-PspPowershellProjectDefaultREADMEFile)
#>
    [CmdletBinding()]
    Param
    (    
    )

    Begin
    {        
    }
    Process
    {
        if ( Test-Path ".\.psproj\defaults.clixml" ) 
        {
            $defaults = Import-Clixml -Path ".\.psproj\defaults.clixml"
        }
    }
    End
    {
        Write-Output $defaults.ModuleREADMEFile
    }
}

function Get-PspPowershellProjectDefaultPreBuildCommand
{
<#
.Synopsis
   Extract the PreBuildCommand default from .psproj\defaults.clixml file.
.DESCRIPTION
   Called by the commands to fetch the default value for PreBuildCommand.

.EXAMPLE
For Use in [Parameters]
   $preBuildCommand = (Get-PspPowershellProjectDefaultPreBuildCommand)
#>
    [CmdletBinding()]
    Param
    (    
    )

    Begin
    {        
    }
    Process
    {
        if ( Test-Path ".\.psproj\defaults.clixml" ) 
        {
            $defaults = Import-Clixml -Path ".\.psproj\defaults.clixml"
        }
    }
    End
    {
        Write-Output $defaults.PreBuildCommand
    }
}


Function New-PspIsePsZipInstallDetails 
{
<#
.Synopsis
    Extract Zip File information.
.DESCRIPTION
   
.EXAMPLE    
#>
    [CmdletBinding()]
    Param
    (  
        # Zip File to expand during deploy
        [Parameter(Mandatory=$true,
                   Position=0)]
        [string]
        $ZipFile
        ,
        # Relative Path to Extract ZIP to
        [Parameter(Mandatory=$true,
                   Position=1)]
        [string]
        $RelativeInstallPath              
    )

    Begin
    {  
        $item = "" | Select-Object ZipFile,RelativeInstallPath
        $item.ZipFile = $ZipFile
        $item.RelativeInstallPath = $RelativeInstallPath              
    }
    Process
    {
        
    }
    End
    {
        Write-Output $item
    }
}

function Get-PspPowershellProjectDefaultModuleAdditionalZipFile
{
<#
.Synopsis
    Get the associated ZIP file from the Defaults.
.DESCRIPTION
    Used to UNZIP the installation ZIP file during the Build process.
.EXAMPLE
    $zf = Get-PspPowershellProjectDefaultModuleAdditionalZipFile
#>
    [CmdletBinding()]
    Param
    (    
    )

    Begin
    {        
    }
    Process
    {
        if ( Test-Path ".\.psproj\defaults.clixml" ) 
        {
            $defaults = Import-Clixml -Path ".\.psproj\defaults.clixml"
        }
    }
    End
    {
        if ( $defaults.ModuleAdditionalZipFile.Length -gt 0 )
        {
            $splitData = $defaults.ModuleAdditionalZipFile.Split("|")
            $item = "" | Select-Object ZipFile,RelativeInstallPath
            $item.ZipFile = $splitData[0]
            $item.RelativeInstallPath = $splitData[1]      
            Write-Output $item
        }
    }
}


