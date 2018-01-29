<#
.Synopsis
   Returns the PATH part of the SourceFile removing the ROOT path of the .psproj file.
.DESCRIPTION
   This is used to auto-determine the TAB name that the files will be placed upon.

.EXAMPLE
PS>Get-ISETabNameFromPath -ProjectFileItem ".\ISE_Project_Backup\Compare-PowershellProjectBackup.ps1 -ProjectFile ".\ISEPSProject.psproj"
ISE_Project_Backup

#>
function Get-ISETabNameFromPath
{
    [CmdletBinding()]
    Param
    (
        # File Item from .psproj file.
        [Parameter(Mandatory=$false,
                   Position=0)]
        [string]
        $ProjectFileItem
        ,
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

<#
.Synopsis
   Given a [string[]] array, convert it to a CSV formatted string.
.DESCRIPTION
   Used by the Build-PowershellProject command to output the FunctionsToExport = line for inclusion in the psd1 file.

.EXAMPLE
PS> $functionInfo = (Get-PowershellProjectFunctions -ProjectFile .\ISEPSProject.psproj -IncludedInBuildOnly | Sort-Object -Property SourceFile,FunctionName).FunctionName
PS> Get-CSVFromStringArray -StringArray $functionInfo -SingleQuotes
'Add-SourceToPowershellProject','Build-PowershellProject','Clean-PowershellProject','Close-PowershellProject','Create-PowershellProject','Get-PowershellProject','Open-PowershellP
roject','Remove-SourceFromPowershellProject','Set-IncludeInBuildFlagForSource','Set-PowershellProjectDefaults','Get-CSVFromStringArray','Get-PowershellProjectBackupData','Get-Pow
ershellProjectCurrentVersion','Get-PowershellProjectDefaultIncludeInBuild','Get-PowershellProjectDefaultProjectFile','Get-PowershellProjectFunctions','Get-PowershellProjectVersio
n','Save-PowershellProject','Save-PowershellProjectDefaults','Update-PowershellProjectVersion'
#>
function Get-CSVFromStringArray
{
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
function ConvertFrom-CliXml {
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
