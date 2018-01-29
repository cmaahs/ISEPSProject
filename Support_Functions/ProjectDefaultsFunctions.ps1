<#
.Synopsis
   Save a .psproj\defaults.clixml file.  This will allow you to skip the -ProjectFile parameter and sets the default IncludeInBuild option for adding items to the project.
.DESCRIPTION
   This is simply a file that will be read by each of the commands in order to pre-populate the -ProjectFile and -IncludeInBuild parameters.

.EXAMPLE
PS> $default = "" | Select-Object ProjectFile,IncludeInBuild,BuildStyle
PS> $defualt.ProjectFile = ".\ISEPSProject.psproj"
PS> $default.IncludeInBuild = $true
PS> $default.BuildStyle = "IncludeStyle"
PS> Save-PowershellProjectDefaults -DefaultData $default
#>
Function Get-PowershellProjectDefaults
{
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
<#
.Synopsis
   Save a .psproj\defaults.clixml file.  This will allow you to skip the -ProjectFile parameter and sets the default IncludeInBuild option for adding items to the project.
.DESCRIPTION
   This is simply a file that will be read by each of the commands in order to pre-populate the -ProjectFile and -IncludeInBuild parameters.

.EXAMPLE
PS> $default = "" | Select-Object ProjectFile,IncludeInBuild,BuildStyle
PS> $defualt.ProjectFile = ".\ISEPSProject.psproj"
PS> $default.IncludeInBuild = $true
PS> $default.BuildStyle = "IncludeStyle"
PS> Save-PowershellProjectDefaults -DefaultData $default
#>
function Save-PowershellProjectDefaults
{
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
<#
.Synopsis
   Extract the ProjectFile default from .psproj\defaults.clixml file.
.DESCRIPTION
   Called by the commands to fetch the default value for ProjectFile.

.EXAMPLE
For Use in [Parameters]
   $ProjectFile = (Get-PowershellProjectDefaultProjectFile)
#>
function Get-PowershellProjectDefaultProjectFile
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
<#
.Synopsis
   Extract the IncludeInBuild default from .psproj\defaults.clixml file.
.DESCRIPTION
   Called by the commands to fetch the default value for IncludeInBuild.

.EXAMPLE
For Use in [Parameters]
   $IncludeInBuild = (Get-PowershellProjectDefaultIncludeInBuild)
#>
function Get-PowershellProjectDefaultIncludeInBuild
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
<#
.Synopsis
   Get the Common Parameters
.DESCRIPTION
   Read the Common Parameters from the .psproj directory, commonParameters.clixml file.

.EXAMPLE
   $commonParameters = Get-CommonParameters
#>
function Get-CommonParameters
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
<#
.Synopsis
   Extract the BuildStyle default from .psproj\defaults.clixml file.
.DESCRIPTION
   Called by the commands to fetch the default value for BuildStyle.

.EXAMPLE
For Use in [Parameters]
   $BuildStyle = (Get-PowershellProjectDefaultBuildStyle)
#>
function Get-PowershellProjectDefaultBuildStyle
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

<#
.Synopsis
   Extract the BuildStyle default from .psproj\defaults.clixml file.
.DESCRIPTION
   Called by the commands to fetch the default value for BuildStyle.

.EXAMPLE
For Use in [Parameters]
   $BuildStyle = (Get-PowershellProjectDefaultBuildStyle)
#>
function Get-PowershellProjectDefaultLocalDeployDirectory
{
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

<#
.Synopsis
   Extract the BuildStyle default from .psproj\defaults.clixml file.
.DESCRIPTION
   Called by the commands to fetch the default value for BuildStyle.

.EXAMPLE
For Use in [Parameters]
   $BuildStyle = (Get-PowershellProjectDefaultBuildStyle)
#>
function Get-PowershellProjectDefaultModuleInitFile
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

<#
.Synopsis
   Extract the BuildStyle default from .psproj\defaults.clixml file.
.DESCRIPTION
   Called by the commands to fetch the default value for BuildStyle.

.EXAMPLE
For Use in [Parameters]
   $BuildStyle = (Get-PowershellProjectDefaultBuildStyle)
#>
function Get-PowershellProjectDefaultModulePSDFile
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
