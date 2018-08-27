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

