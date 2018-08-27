function Reset-PspBuildFolder
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
            Write-Verbose "Build Path: $($buildPath)"
            if ( Test-Path $buildPath )
            {
                Remove-Item -Path $buildPath -Recurse -Force
            }
            $buildPath = ""
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
