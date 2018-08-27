function Get-PspPowershellProjectDefaultModuleAdditionalZipFile
{
<#
.Synopsis
    Get the associated ZIP file from the Defaults.
.DESCRIPTION
    Used to UNZIP the installation ZIP file during the Build process.
.EXAMPLE
    $zf = Get-PspPowershellProjectDefaultModuleAdditionalZipFile
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
        if ( $defaults.ModuleAdditionalZipFile.Length -gt 0 )
        {
            $splitData = $defaults.ModuleAdditionalZipFile.Split("|")
            $item = "" | Select-Object ZipFile,RelativeInstallPath
            $item.ZipFile = $splitData[0]
            $item.RelativeInstallPath = $splitData[1]      
            Write-Output $item
        }
    }
}
