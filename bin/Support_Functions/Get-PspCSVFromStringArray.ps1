function Get-PspCSVFromStringArray
{
<#
.Synopsis
   Given a [string[]] array, convert it to a CSV formatted string.
.DESCRIPTION
   Used by the Start-PspBuildPowershellProject command to output the FunctionsToExport = line for inclusion in the psd1 file.

.EXAMPLE
PS> $functionInfo = (Get-PspPowershellProjectFunctions -ProjectFile .\ISEPSProject.psproj -IncludedInBuildOnly | Sort-Object -Property SourceFile,FunctionName).FunctionName
PS> Get-PspCSVFromStringArray -StringArray $functionInfo -SingleQuotes
'Add-PspSourceToPowershellProject','Start-PspBuildPowershellProject','Repair-PspPowershellProject','Close-PspPowershellProject','New-PspPowershellProject','Get-PspPowershellProject','Open-PowershellP
roject','Remove-PspSourceFromPowershellProject','Set-PspIncludeInBuildFlagForSource','Set-PspPowershellProjectDefaults','Get-PspCSVFromStringArray','Get-PspPowershellProjectBackupData','Get-Pow
ershellProjectCurrentVersion','Get-PspPowershellProjectDefaultIncludeInBuild','Get-PspPowershellProjectDefaultProjectFile','Get-PspPowershellProjectFunctions','Get-PspPowershellProjectVersio
n','Save-PspPowershellProject','Save-PspPowershellProjectDefaults','Update-PspPowershellProjectVersion'
#>
    [CmdletBinding()]
    Param
    (
        # String Array to convert to CSV Line
        [Parameter(Mandatory=$false,
                   Position=0)]
        [string[]]
        $StringArray
        ,
        # Add single quotes around each element
        [Parameter(Mandatory=$false,
                   Position=1)]
        [switch]
        $SingleQuotes
    )

    Begin
    {   
        $csvLine = ""
    }
    Process
    {
        foreach ( $string in $StringArray )
        {
            if ( $SingleQuotes -eq $true )
            {
                $csvLine += "'$($string)',"
            } else {
                $csvLine += "$($string),"
            }
        }
    }
    End
    {
        $csvLine = $csvLine.Substring(0, $csvLine.Length-1)        
        Write-Output $csvLine
    }
}

