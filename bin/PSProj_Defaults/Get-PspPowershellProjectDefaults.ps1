Function Get-PspPowershellProjectDefaults
{
<#
.Synopsis
   We are saving some build/project defaults in .psproj\defaults.clixml.  This function will display those settings.

.EXAMPLE
    PS> Get-PspPowershellProjectDefaults

ProjectFile             : ISEPSProject.psproj
IncludeInBuild          : True
BuildStyle              : IncludeStyle
LocalDeployDirectory    : 
ModuleInitFile          : 
ModuleREADMEFile        : .\Deploy\README.md
ModuleAdditionalZipFile : 
PreBuildCommand         : 
ModulePSDFile           : .\Deploy\ISEPSProject.psd1
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

