<#
These functions have been moved to the PSProj_Management Tab.
#>

Function Get-PspPowershellProjectFunctions
{
<#
.Synopsis
   Gets a list of the commands (function) inside of the source files contained in the .psproj file.
.DESCRIPTION
   Generate a list of commands (function) with their containing source file information.

.EXAMPLE
PS> Get-PspPowershellProjectFunctions -ProjectFile .\ISEPSProject.psproj | Sort-Object -Property SourceFile,FunctionName

Name                                       SourceFile                            
------------                               ----------                            
Add-PspSourceToPowershellProject              Add-PspSourceToPowershellProject.ps1     
Start-PspBuildPowershellProject                    Start-PspBuildPowershellProject.ps1           
Repair-PspPowershellProject                    Repair-PspPowershellProject.ps1           
Close-PspPowershellProject                    Close-PspPowershellProject.ps1           
Compare-PspPowershellProjectBackup            Compare-PspPowershellProjectBackup.ps1   
New-PspPowershellProject                   New-PspPowershellProject.ps1          
Get-PspPowershellProject                      Get-PspPowershellProject.ps1             
Get-PspPowershellProjectBackup                Get-PspPowershellProjectBackup.ps1       
Open-PspPowershellProject                     Open-PspPowershellProject.ps1            
Remove-PspSourceFromPowershellProject         Remove-PspSourceFromPowershellProject.ps1
Set-PspIncludeInBuildFlagForSource            Set-PspIncludeInBuildFlagForSource.ps1   
Set-PspPowershellProjectDefaults              Set-PspPowershellProjectDefaults.ps1     
Get-PspCSVFromStringArray                     UtilityFunctions.ps1                  
Get-PspPowershellProjectBackupData            UtilityFunctions.ps1                  
Get-PspPowershellProjectCurrentVersion        UtilityFunctions.ps1                  
Get-PspPowershellProjectDefaultIncludeInBuild UtilityFunctions.ps1                  
Get-PspPowershellProjectDefaultProjectFile    UtilityFunctions.ps1                  
Get-PspPowershellProjectFunctions             UtilityFunctions.ps1                  
Get-PspPowershellProjectVersion               UtilityFunctions.ps1                  
Save-PspPowershellProject                     UtilityFunctions.ps1                  
Save-PspPowershellProjectDefaults             UtilityFunctions.ps1                  
Update-PspPowershellProjectVersion            UtilityFunctions.ps1               

.EXAMPLE
PS> Get-PspPowershellProjectFunctions -ProjectFile .\ISEPSProject.psproj -IncludedInBuildOnly | Sort-Object -Property SourceFile,FunctionName

Name                                       SourceFile                            
------------                               ----------                            
Add-PspSourceToPowershellProject              Add-PspSourceToPowershellProject.ps1     
Start-PspBuildPowershellProject                    Start-PspBuildPowershellProject.ps1           
Repair-PspPowershellProject                    Repair-PspPowershellProject.ps1           
Close-PspPowershellProject                    Close-PspPowershellProject.ps1           
New-PspPowershellProject                   New-PspPowershellProject.ps1          
Get-PspPowershellProject                      Get-PspPowershellProject.ps1             
Open-PspPowershellProject                     Open-PspPowershellProject.ps1            
Remove-PspSourceFromPowershellProject         Remove-PspSourceFromPowershellProject.ps1
Set-PspIncludeInBuildFlagForSource            Set-PspIncludeInBuildFlagForSource.ps1   
Set-PspPowershellProjectDefaults              Set-PspPowershellProjectDefaults.ps1     
Get-PspCSVFromStringArray                     UtilityFunctions.ps1                  
Get-PspPowershellProjectBackupData            UtilityFunctions.ps1                  
Get-PspPowershellProjectCurrentVersion        UtilityFunctions.ps1                  
Get-PspPowershellProjectDefaultIncludeInBuild UtilityFunctions.ps1                  
Get-PspPowershellProjectDefaultProjectFile    UtilityFunctions.ps1                  
Get-PspPowershellProjectFunctions             UtilityFunctions.ps1                  
Get-PspPowershellProjectVersion               UtilityFunctions.ps1                  
Save-PspPowershellProject                     UtilityFunctions.ps1                  
Save-PspPowershellProjectDefaults             UtilityFunctions.ps1                  
Update-PspPowershellProjectVersion            UtilityFunctions.ps1                  

#>
    [CmdletBinding()]
    Param
    (
        <#PINC:ProjectFile#>
        <#PINC:PARAMCOMMA#>
        # Switch to only include those source files that have the IncludeInBuild flag set.
        [Parameter(Mandatory=$false,
                   Position=1)]
        [switch]
        $IncludedInBuildOnly = $false
        ,
        # Switch to only include PUBLIC exported functions
        [Parameter(Mandatory=$false,
                   Position=2)]
        [switch]
        $IncludeOnlyPublic = $false

    )

    Begin
    {
        $functionList = @()
        $continueProcessing = $true
        if ( $ProjectFile -ne "" ) 
        {            
            if ( -not ( Test-Path $ProjectFile ) ) 
            {
                Write-Warning "Cannot locate the specified ProjectFile"
                $continueProcessing = $false
            }        
        } else {
            Write-Warning "Must specify the -ProjectFile, or use Set-PspPowershellProjectDefaults command to set a default ProjectFile"
            $continueProcessing = $false
        }
    }
    Process
    {
        if ( $continueProcessing -eq $true ) 
        {
            $projectData = Import-Clixml -Path $ProjectFile
            if ( $ProjectFile.StartsWith(".\") )
            {
                $projectFileKey = $ProjectFile.SubString(2)
            }        
            if ( $projectData.ContainsKey($projectFileKey) )
            {
                $projectData.Remove($projectFileKey)
            }
            if ( $projectData.ContainsKey("ISEPSProjectDataVersion") )
            {
                $projectData.Remove("ISEPSProjectDataVersion")
            }

            if ( $IncludedInBuildOnly -eq $true ) 
            {                
                $includedSources = ($projectData.Values | Where-Object { $_.IncludeInBuild -eq $true } | Select-Object -Property FileName | Sort-Object -Property FileName).FileName
            } else {
                $includedSources = ($projectData.Values | Select-Object -Property FileName | Sort-Object -Property FileName).FileName
            }

            foreach ( $key in $includedSources )
            {
                Write-Verbose "Key: $($key)"
                $content = Get-Content -Path $key
                foreach ( $line in $content )
                {
                    if ( $IncludeOnlyPublic -eq $true )
                    {
                        if ( $line.Trim().StartsWith("Function") )
                        {
                            $item = "" | Select-Object FunctionName,SourceFile
                            $item.FunctionName = $line.Trim().Split(" ")[1]
                            $item.SourceFile = $key
                            $functionList += $item   
                        }
                    } else {
                        if ( $line.Trim().StartsWith("function") )
                        {
                            $item = "" | Select-Object FunctionName,SourceFile
                            $item.FunctionName = $line.Trim().Split(" ")[1]
                            $item.SourceFile = $key
                            $functionList += $item   
                        }
                    }
                }
            }
            Write-Output $functionList
        } #continue processing
   }
    End
    {
        if ( $continueProcessing -eq $true )
        {
        }
    }
}

function Get-PspPowershellProjectKeys
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
        $continueProcessing = $true
        if ( $ProjectFile -ne "" ) 
        {            
            if ( -not ( Test-Path $ProjectFile ) ) 
            {
                Write-Warning "Cannot locate the specified ProjectFile"
                $continueProcessing = $false
            }        
        } else {
            Write-Warning "Must specify the -ProjectFile, or use Set-PspPowershellProjectDefaults command to set a default ProjectFile"
            $continueProcessing = $false
        }
    }
    Process
    {
        if ( $continueProcessing -eq $true ) 
        {
            $projectData = Import-Clixml -Path $ProjectFile

            if ( $ProjectFile.StartsWith(".\") )
            {
                $projectFileKey = $ProjectFile.SubString(2)
            } else {
                $projectFileKey = $ProjectFile
            }
            if ( $projectData.ContainsKey($projectFileKey) )
            {
                $projectData.Remove($projectFileKey)
            }
            if ( $projectData.ContainsKey("ISEPSProjectDataVersion") )
            {
                $projectData.Remove("ISEPSProjectDataVersion")
            }
            Write-Output $projectData.Keys
        } #continue processing
    }
    End
    {
    }
}

Function Get-PspPowershellProjectFilesNotIncludedInProject
{
<#
.Synopsis
    Display the files in the PROJECT directory that haven't been added as a source.   
.DESCRIPTION
   
.EXAMPLE
    
#>
    $projectFiles = @{}

    $psFiles = Get-ChildItem -Filter *.ps1 -Recurse
    $pspKeys = Get-PspPowershellProjectKeys | Sort-Object
    foreach ( $p in $pspKeys )
    {
        $f = Get-ChildItem $p
        $projectFiles.Add($f.FullName,$p)
    }
    
    foreach ( $p in $psFiles ) 
    { 
        if ( -not ( $p.FullName.Contains("\bin\") ) )
        {
            #Write-Verbose $p.FullName -Verbose
            #Write-Verbose $projectFiles.ContainsKey($p.FullName) -Verbose
            if ( -Not ( $projectFiles.ContainsKey($p.FullName) ) ) 
            {
                Write-Output "Missing: $($p.FullName)" 
            }
        }
    }
}
