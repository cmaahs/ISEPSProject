function Get-PspPowershellProjectCurrentVersion
{
<#
.Synopsis
   Returns the most current version of .psproj files.
.DESCRIPTION
   Returns the lastest version of the .psproj files supported by the code.

.EXAMPLE
   Get-PspPowershellProjectCurrentVersion
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
        $item = "" | Select-Object CurrentVersion
        $item.CurrentVersion = "1.3"
        Write-Output $item
   }
    End
    {
    }
}

