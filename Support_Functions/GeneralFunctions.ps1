<#
These functions remain in the Support_Functions Tab, though they have been saved as individual entries.
#>

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
        <#PINC:PARAMCOMMA#>
        <#PINC:ProjectFile#>
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
        <#PINC:PARAMCOMMA#>
        <#PINC:ProjectFile#>
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

function Get-PspCSVFromStringArray
{
<#
.Synopsis
   Given a [string[]] array, convert it to a CSV formatted string.
.DESCRIPTION
   Used by the Start-PspBuildPowershellProject command to output the FunctionsToExport = line for inclusion in the psd1 file.

.EXAMPLE
PS> $functionInfo = (Get-PspPowershellProjectFunctions -ProjectFile .\ISEPSProject.psproj -IncludedInBuildOnly | Sort-Object -Property SourceFile,FunctionName).FunctionName
PS> Get-PspCSVFromStringArray -StringArray $functionInfo -SingleQuotes
'Add-PspSourceToPowershellProject','Start-PspBuildPowershellProject','Repair-PspPowershellProject','Close-PspPowershellProject','New-PspPowershellProject','Get-PspPowershellProject','Open-PowershellP
roject','Remove-PspSourceFromPowershellProject','Set-PspIncludeInBuildFlagForSource','Set-PspPowershellProjectDefaults','Get-PspCSVFromStringArray','Get-PspPowershellProjectBackupData','Get-Pow
ershellProjectCurrentVersion','Get-PspPowershellProjectDefaultIncludeInBuild','Get-PspPowershellProjectDefaultProjectFile','Get-PspPowershellProjectFunctions','Get-PspPowershellProjectVersio
n','Save-PspPowershellProject','Save-PspPowershellProjectDefaults','Update-PspPowershellProjectVersion'
#>
    [CmdletBinding()]
    Param
    (
        # String Array to convert to CSV Line
        [Parameter(Mandatory=$false,
                   Position=0)]
        [string[]]
        $StringArray
        ,
        # Add single quotes around each element
        [Parameter(Mandatory=$false,
                   Position=1)]
        [switch]
        $SingleQuotes
    )

    Begin
    {   
        $csvLine = ""
    }
    Process
    {
        foreach ( $string in $StringArray )
        {
            if ( $SingleQuotes -eq $true )
            {
                $csvLine += "'$($string)',"
            } else {
                $csvLine += "$($string),"
            }
        }
    }
    End
    {
        $csvLine = $csvLine.Substring(0, $csvLine.Length-1)        
        Write-Output $csvLine
    }
}

#this doesn't work.
function ConvertFrom-PspCliXml {
    param(
        [parameter(position=0,mandatory=$true,valuefrompipeline=$true)]
        [validatenotnull()]
        [string]$string
    )
    begin
    {
        $inputstring = ""
    }
    process
    {
        $inputstring += $string
    }
    end
    {
        $type = [type]::gettype("System.Management.Automation.Deserializer")
        $ctor = $type.getconstructor("instance,nonpublic", $null, @([xml.xmlreader]), $null)
        $sr = new-object io.stringreader $inputstring
        $xr = new-object xml.xmltextreader $sr
        $deserializer = $ctor.invoke($xr)
        $method = @($type.getmethods("nonpublic,instance") | where-object {$_.name -like "Deserialize"})[1]
        $done = $type.getmethod("Done", [reflection.bindingflags]"nonpublic,instance")
        while (!$done.invoke($deserializer, @()))
        {
            try {
                $method.invoke($deserializer, "")
            } catch {
                write-warning "Could not deserialize object: $_"
            }
        }
    }
}

Function Start-IsePsPublishToEvcNuGet
{
    cd C:\users\Christopher.Maahs\Documents\Projects\ISEPSProject
    Start-PspBuildPowershellProject -Verbose -Force 
    cd ..\.. 
    Uninstall-Module -Name ISEPSProject 
    cd .\Projects\ISEPSProject
    New-Item -ItemType Directory -Path 'C:\Program Files\WindowsPowerShell\Modules\' -Name ISEPSProject
    Start-PspDeployPowershellProject -Verbose -Force 
    cd ..\..
    Publish-Module -Name ISEPSProject -NuGetApiKey (Get-VaultNuGetKey) -Repository EvcNuGet 
    Remove-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\ISEPSProject' -Recurse -Force  
    Write-Verbose "Sleeping for 3 minutes for replication to happen..." -Verbose
    Start-Sleep -Seconds 180
    Install-Module -Name ISEPSProject -Repository EvcNuGet
    cd .\Projects\ISEPSProject
}