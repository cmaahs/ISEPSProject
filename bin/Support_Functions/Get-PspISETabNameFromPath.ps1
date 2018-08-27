function Get-PspISETabNameFromPath
{
<#
.Synopsis
   Returns the PATH part of the SourceFile removing the ROOT path of the .psproj file.
.DESCRIPTION
   This is used to auto-determine the TAB name that the files will be placed upon.

.EXAMPLE
PS>Get-PspISETabNameFromPath -ProjectFileItem ".\ISE_Project_Backup\Compare-PspPowershellProjectBackup.ps1 -ProjectFile ".\ISEPSProject.psproj"
ISE_Project_Backup

#>
    [CmdletBinding()]
    Param
    (
        # File Item from .psproj file.
        [Parameter(Mandatory=$false,
                   Position=0)]
        [string]
        $ProjectFileItem
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
            if ( Test-Path $ProjectFileItem )
            {
                $rootPath = (Get-ChildItem ($ProjectFile)).Directory.FullName
                if ( $ProjectFileItem.StartsWith($rootPath) )
                {
                    $fileFullPath = (Get-ChildItem "$($ProjectFileItem)").Directory.FullName
                } else {        
                    $fileFullPath = (Get-ChildItem "$($rootPath)$($ProjectFileItem)").Directory.FullName
                }
                $tabName = $fileFullPath.Substring($rootPath.Length+1)       
                Write-Output $tabName
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

