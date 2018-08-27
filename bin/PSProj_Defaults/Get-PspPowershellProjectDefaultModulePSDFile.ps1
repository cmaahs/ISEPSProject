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

