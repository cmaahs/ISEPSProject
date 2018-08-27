Function New-PspZipFileDetail
{
<#
.Synopsis
   Given a ZipFile and Relative Path, return an object to pass into the Set-PspPowershellProjectDefaults -ModuleAdditionalZipFile
.DESCRIPTION

.EXAMPLE
TODO: Example
#>
    [CmdletBinding()]
    Param
    (
        # Path to a ZIP File.
        [Parameter(Mandatory=$true,
                   Position=0)]
        [ValidateScript( { ( ( $_ -eq "-" ) -or ( Test-Path $_ ) ) } )]  
        [string]
        $ZipFile
        ,
        # Relative Install Path
        [Parameter(Mandatory=$true,
                   Position=1)]
        [string]
        $RelativeInstallPath
    )

    Begin
    {   
        
    }
    Process
    {
    }
    End
    {
        $item = "" | Select-Object ZipFile,RelativeInstallPath
        $item.ZipFile = $ZipFile
        $item.RelativeInstallPath = $RelativeInstallPath
        Write-Output $item
    }
}
