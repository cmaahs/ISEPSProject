<#
.Synopsis
   Gets a list of the commands (function) inside of the source files contained in the .psproj file.
.DESCRIPTION
   Generate a list of commands (function) with their containing source file information.

.EXAMPLE
PS> Get-PowershellProjectFunctions -ProjectFile .\ISEPSProject.psproj | Sort-Object -Property SourceFile,FunctionName

Name                                       SourceFile                            
------------                               ----------                            
Add-SourceToPowershellProject              Add-SourceToPowershellProject.ps1     
Build-PowershellProject                    Build-PowershellProject.ps1           
Clean-PowershellProject                    Clean-PowershellProject.ps1           
Close-PowershellProject                    Close-PowershellProject.ps1           
Compare-PowershellProjectBackup            Compare-PowershellProjectBackup.ps1   
Create-PowershellProject                   Create-PowershellProject.ps1          
Get-PowershellProject                      Get-PowershellProject.ps1             
Get-PowershellProjectBackup                Get-PowershellProjectBackup.ps1       
Open-PowershellProject                     Open-PowershellProject.ps1            
Remove-SourceFromPowershellProject         Remove-SourceFromPowershellProject.ps1
Set-IncludeInBuildFlagForSource            Set-IncludeInBuildFlagForSource.ps1   
Set-PowershellProjectDefaults              Set-PowershellProjectDefaults.ps1     
Get-CSVFromStringArray                     UtilityFunctions.ps1                  
Get-PowershellProjectBackupData            UtilityFunctions.ps1                  
Get-PowershellProjectCurrentVersion        UtilityFunctions.ps1                  
Get-PowershellProjectDefaultIncludeInBuild UtilityFunctions.ps1                  
Get-PowershellProjectDefaultProjectFile    UtilityFunctions.ps1                  
Get-PowershellProjectFunctions             UtilityFunctions.ps1                  
Get-PowershellProjectVersion               UtilityFunctions.ps1                  
Save-PowershellProject                     UtilityFunctions.ps1                  
Save-PowershellProjectDefaults             UtilityFunctions.ps1                  
Update-PowershellProjectVersion            UtilityFunctions.ps1               

.EXAMPLE
PS> Get-PowershellProjectFunctions -ProjectFile .\ISEPSProject.psproj -IncludedInBuildOnly | Sort-Object -Property SourceFile,FunctionName

Name                                       SourceFile                            
------------                               ----------                            
Add-SourceToPowershellProject              Add-SourceToPowershellProject.ps1     
Build-PowershellProject                    Build-PowershellProject.ps1           
Clean-PowershellProject                    Clean-PowershellProject.ps1           
Close-PowershellProject                    Close-PowershellProject.ps1           
Create-PowershellProject                   Create-PowershellProject.ps1          
Get-PowershellProject                      Get-PowershellProject.ps1             
Open-PowershellProject                     Open-PowershellProject.ps1            
Remove-SourceFromPowershellProject         Remove-SourceFromPowershellProject.ps1
Set-IncludeInBuildFlagForSource            Set-IncludeInBuildFlagForSource.ps1   
Set-PowershellProjectDefaults              Set-PowershellProjectDefaults.ps1     
Get-CSVFromStringArray                     UtilityFunctions.ps1                  
Get-PowershellProjectBackupData            UtilityFunctions.ps1                  
Get-PowershellProjectCurrentVersion        UtilityFunctions.ps1                  
Get-PowershellProjectDefaultIncludeInBuild UtilityFunctions.ps1                  
Get-PowershellProjectDefaultProjectFile    UtilityFunctions.ps1                  
Get-PowershellProjectFunctions             UtilityFunctions.ps1                  
Get-PowershellProjectVersion               UtilityFunctions.ps1                  
Save-PowershellProject                     UtilityFunctions.ps1                  
Save-PowershellProjectDefaults             UtilityFunctions.ps1                  
Update-PowershellProjectVersion            UtilityFunctions.ps1                  

#>
Function Get-PowershellProjectFunctions
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
        ,
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
            Write-Warning "Must specify the -ProjectFile, or use Set-PowershellProjectDefaults command to set a default ProjectFile"
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

