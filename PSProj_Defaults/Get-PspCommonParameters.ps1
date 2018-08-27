function Get-PspCommonParameters
{
<#
.Synopsis
   Get the Common Parameters
.DESCRIPTION
   Read the Common Parameters from the .psproj directory, commonParameters.clixml file.

.EXAMPLE
   $commonParameters = Get-PspCommonParameters
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
