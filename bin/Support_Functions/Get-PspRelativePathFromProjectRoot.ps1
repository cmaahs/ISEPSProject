Function Get-PspRelativePathFromProjectRoot
{
<#
.Synopsis
   Returns the PATH part of the SourceFile removing the ROOT path of the .psproj file.
.DESCRIPTION
   Used to feed other Powershell Project commands.

.EXAMPLE

#>
    [CmdletBinding()]
    Param
    (
        # File Item from .psproj file.
        [Parameter(Mandatory=$false,
                   Position=0)]        
        $FullName
        ,
        # Specify the project file to open.  Default project can be specified via the Set-PspPowershellProjectDefaults command.
        [Parameter(Mandatory=$false,
                   Position=1)]
        [Alias('File','FilePath')]
        #[ValidateScript({ Test-Path $_ })]
        [string]       
        $ProjectFile = (Get-PspPowershellProjectDefaultProjectFile)
    )

    Begin
    {        
    }
    Process
    {
        if ( Test-Path $ProjectFile )
        {
            if ( Test-Path $FullName )
            {
                $rootPath = (Get-ChildItem ($ProjectFile)).Directory.FullName
                if ( $FullName.StartsWith($rootPath) )
                {
                    $fileFullPath = (Get-ChildItem "$($FullName)").FullName
                } else {        
                    $fileFullPath = (Get-ChildItem "$($rootPath)$($FullName)").FullName
                }
                $relativeName = $fileFullPath.Substring($rootPath.Length+1)       
                Write-Output ".\$($relativeName)"
            } else {
                Write-Output ""
            }
        } else {
            Write-Output ""
        }
    }
    End
    {
    }
}

