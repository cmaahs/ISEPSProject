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

