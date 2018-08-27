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
