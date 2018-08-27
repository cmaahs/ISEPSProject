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

