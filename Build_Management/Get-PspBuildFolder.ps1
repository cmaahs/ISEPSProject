function Get-PspBuildFolder
{
<#
.Synopsis
   
.DESCRIPTION   

.EXAMPLE

#>
    [CmdletBinding()]
    Param
    (        
        <#PINC:ProjectFile#>
    )

    Begin
    {        
        if ( Test-Path $ProjectFile )
        {            
            $rootPath = (Get-ChildItem ($ProjectFile)).Directory.FullName
            $buildPath = "$($rootPath)\bin"
            if ( -not ( Test-Path $buildPath ) )
            {
                Write-Verbose "Creating new bin folder..."
                New-Item -Path $rootPath -Name "bin" -ItemType Directory
            }
        } else {
            $buildPath = ""
        }
    }
    Process
    {
    }
    End
    {
        Write-Output $buildPath
    }
}
