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
