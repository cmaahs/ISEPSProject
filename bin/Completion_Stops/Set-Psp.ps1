<#
.Synopsis
This is a stub function that STOPS TAB completion at Set-Psp, allowing you to type an additional character.

.EXAMPLE

PS> Get-E{TAB} will expan to Get-Evc, allow you to type the first letter or a few of the next match.
#>
Function Set-Psp
{
    [CmdletBinding()]
    Param
    (
    )
    
    Begin
    {
        $continueProcessing = $true
    }
    Process
    {
        if ( $continueProcessing -eq $true )
        {

        } #continue processing
    }
    End
    {
        if ( $continueProcessing -eq $true ) 
        {
            Get-Command -Module ISEPSProject | Where-Object { $_.Name.StartsWith("Set-Psp") }
        }
    }
}

