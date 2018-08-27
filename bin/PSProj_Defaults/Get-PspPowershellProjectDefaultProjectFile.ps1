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

