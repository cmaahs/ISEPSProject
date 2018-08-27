function New-PspIncludeBasedModuleFile
{
<#
.Synopsis
   Returns the PATH part of the SourceFile removing the ROOT path of the .psproj file.
.DESCRIPTION
   This is used to auto-determine the TAB name that the files will be placed upon.

.EXAMPLE
PS>Get-PspISETabNameFromPath -ProjectFileItem ".\ISE_Project_Backup\Compare-PspPowershellProjectBackup.ps1 -ProjectFile ".\ISEPSProject.psproj"
ISE_Project_Backup


    $Account  = @( Get-ChildItem -Path $PSScriptRoot\Account\*.ps1 -ErrorAction SilentlyContinue )
    $Calculations = @( Get-ChildItem -Path $PSScriptRoot\Calculations\*.ps1 -ErrorAction SilentlyContinue )
    $Encryption = @( Get-ChildItem -Path $PSScriptRoot\Encryption\*.ps1 -ErrorAction SilentlyContinue )
    $Interface = @( Get-ChildItem -Path $PSScriptRoot\Interface\*.ps1 -ErrorAction SilentlyContinue )
    $Market = @( Get-ChildItem -Path $PSScriptRoot\Market\*.ps1 -ErrorAction SilentlyContinue )
    $Public = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue )

    Foreach($import in @($Account + $Calculations + $Encryption + $Interface + $Market + $Public))
    {
        Try
        {
            . $import.fullname
        }
        Catch
        {
            Write-Error -Message "Failed to import function $($import.fullname): $_"
        }
    }

#>
    [CmdletBinding()]
    Param
    (        
        <#PINC:ProjectFile#>
    )

    Begin
    {      
        $successfullyCreated = $false
        $psmContent = ""
        $psmInclude = ""
        if ( Test-Path $ProjectFile )
        {            
            $rootPath = (Get-ChildItem ($ProjectFile)).Directory.FullName
            $buildPath = "$($rootPath)\bin"
            if ( Test-Path $buildPath )
            {                
                $dirList = Get-ChildItem -Path $buildPath -Recurse -Directory

                Write-Verbose "Dir Count: $($dirList.Count)"
                foreach ( $d in $dirList )
                {
                    if ( $d.FullName.ToString().Contains("\bin\") ) 
                    {
                        #TODO: Complete this section
                        Write-Verbose "Adding $($d.Name)"
                        $psmContent += "`$$($d.Name) = @(Get-ChildItem -Path `$PSScriptRoot\bin\$($d.Name)\*.ps1 -ErrorAction SilentlyContinue)`r`n"
                        $psmInclude += "`$$($d.Name) + "
                    }
                }
                $psmInclude = $psmInclude.Substring(0,$psmInclude.Length - 3)
                $psmContent += @"
    Foreach(`$import in @($($psmInclude)))
    {
        Try
        {
            . `$import.fullname
        }
        Catch
        {
            Write-Error -Message "Failed to import function `$(`$import.fullname): `$_"
        }
    }
"@
            } else {
                $successfullyCreated = $false
            }        
        } else {
            $successfullyCreated = $false
        }
    }
    Process
    {
    }
    End
    {
        Write-Output $psmContent
    }
}
