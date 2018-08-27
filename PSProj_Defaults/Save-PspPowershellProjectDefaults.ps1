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
