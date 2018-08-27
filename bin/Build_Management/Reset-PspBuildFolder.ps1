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
        # Specify the project file to open.  Default project can be specified via the Set-PspPowershellProjectDefaults command.
        [Parameter(Mandatory=$false,
                   Position=0)]
        [Alias('File','FilePath')]
        #[ValidateScript({ Test-Path $_ })]
        [string]       
        $ProjectFile = (Get-PspPowershellProjectDefaultProjectFile)
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

