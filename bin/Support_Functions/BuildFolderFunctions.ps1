<#
.Synopsis
   Returns the PATH part of the SourceFile removing the ROOT path of the .psproj file.
.DESCRIPTION
   This is used to auto-determine the TAB name that the files will be placed upon.

.EXAMPLE
PS>Get-ISETabNameFromPath -ProjectFileItem ".\ISE_Project_Backup\Compare-PowershellProjectBackup.ps1 -ProjectFile ".\ISEPSProject.psproj"
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
function New-IncludeBasedModuleFile
{
    [CmdletBinding()]
    Param
    (        
        # Specify the project file to open.  Default project can be specified via the Set-PowershellProjectDefaults command.
        [Parameter(Mandatory=$false,
                   Position=0)]
        [Alias('File','FilePath')]
        #[ValidateScript({ Test-Path $_ })]
        [string]       
        $ProjectFile = (Get-PowershellProjectDefaultProjectFile)
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


<#
.Synopsis
   Returns the PATH part of the SourceFile removing the ROOT path of the .psproj file.
.DESCRIPTION
   This is used to auto-determine the TAB name that the files will be placed upon.

.EXAMPLE
PS>Get-ISETabNameFromPath -ProjectFileItem ".\ISE_Project_Backup\Compare-PowershellProjectBackup.ps1 -ProjectFile ".\ISEPSProject.psproj"
ISE_Project_Backup

#>
function Save-SourceToBuildFolder
{
    [CmdletBinding()]
    Param
    (        
        # File Item from .psproj file.
        [Parameter(Mandatory=$true,
                   Position=0)]
        [string]
        $ProjectFileItem
        ,
        # Build file contents
        [Parameter(Mandatory=$true,
                   Position=1)]
        [string]
        $BuildContents
    )

    Begin
    {    
        if ( -not ( Test-Path "bin" ) )
        {
            New-Item -Path "./" -Name "bin" -ItemType Directory
        }    
        $writtenOK = $false
        $fileTargetDir = $ProjectFileItem.Split("\")[0]
        $fileTarget = "bin\$($ProjectFileItem)"
        if ( -not ( Test-Path "bin\$($fileTargetDir)" ) )
        {
            New-Item -Path "bin" -Name $fileTargetDir -ItemType Directory
        }

        $BuildContents | Out-File -FilePath $fileTarget -Force -Encoding ascii

        if ( Test-Path $fileTarget )
        {
            $writtenOK = $true
        }
    }
    Process
    {
    }
    End
    {
        Write-Output $writtenOK
    }
}
<#
.Synopsis
   Returns the PATH part of the SourceFile removing the ROOT path of the .psproj file.
.DESCRIPTION
   This is used to auto-determine the TAB name that the files will be placed upon.

.EXAMPLE
PS>Get-ISETabNameFromPath -ProjectFileItem ".\ISE_Project_Backup\Compare-PowershellProjectBackup.ps1 -ProjectFile ".\ISEPSProject.psproj"
ISE_Project_Backup

#>
function Reset-BuildFolder
{
    [CmdletBinding()]
    Param
    (        
        # Specify the project file to open.  Default project can be specified via the Set-PowershellProjectDefaults command.
        [Parameter(Mandatory=$false,
                   Position=3)]
        [Alias('File','FilePath')]
        #[ValidateScript({ Test-Path $_ })]
        [string]       
        $ProjectFile = (Get-PowershellProjectDefaultProjectFile)
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
                $fileList = Get-ChildItem -Path $buildPath -Recurse -File
                $dirList = Get-ChildItem -Path $buildPath -Recurse -Directory

                Write-Verbose "File Count: $($fileList.Count)"
                Write-Verbose "Dir Count: $($dirList.Count)"
                foreach ( $f in $fileList )
                {
                    if ( $f.FullName.ToString().Contains("\bin\") )
                    {
                        Write-Verbose "Removing $($f.FullName)"
                        $f.Delete()
                    }
                }
                foreach ( $d in $dirList )
                {
                    if ( $d.FullName.ToString().Contains("\bin\") ) 
                    {
                        Write-Verbose "Removing $($d.FullName)"
                        $d.Delete()
                    }
                }
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

<#
.Synopsis
   Returns the PATH part of the SourceFile removing the ROOT path of the .psproj file.
.DESCRIPTION
   This is used to auto-determine the TAB name that the files will be placed upon.

.EXAMPLE
PS>Get-ISETabNameFromPath -ProjectFileItem ".\ISE_Project_Backup\Compare-PowershellProjectBackup.ps1 -ProjectFile ".\ISEPSProject.psproj"
ISE_Project_Backup

#>
function Get-BuildFolder
{
    [CmdletBinding()]
    Param
    (        
        # Specify the project file to open.  Default project can be specified via the Set-PowershellProjectDefaults command.
        [Parameter(Mandatory=$false,
                   Position=4)]
        [Alias('File','FilePath')]
        #[ValidateScript({ Test-Path $_ })]
        [string]       
        $ProjectFile = (Get-PowershellProjectDefaultProjectFile)
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

