Function New-PspIsePsZipInstallDetails
{
<#
.Synopsis
    Extract Zip File information.
.DESCRIPTION
   
.EXAMPLE    
#>
    [CmdletBinding()]
    Param
    (  
        # Zip File to expand during deploy
        [Parameter(Mandatory=$true,
                   Position=0)]
        [string]
        $ZipFile
        ,
        # Relative Path to Extract ZIP to
        [Parameter(Mandatory=$true,
                   Position=1)]
        [string]
        $RelativeInstallPath              
    )

    Begin
    {  
        $item = "" | Select-Object ZipFile,RelativeInstallPath
        $item.ZipFile = $ZipFile
        $item.RelativeInstallPath = $RelativeInstallPath              
    }
    Process
    {
        
    }
    End
    {
        Write-Output $item
    }
}

