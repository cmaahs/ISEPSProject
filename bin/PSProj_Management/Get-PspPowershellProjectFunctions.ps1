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
        # Specify the project file to open.  Default project can be specified via the Set-PspPowershellProjectDefaults command.
        [Parameter(Mandatory=$false,
                   Position=0)]
        [Alias('File','FilePath')]
        #[ValidateScript({ Test-Path $_ })]
        [string]       
        $ProjectFile = (Get-PspPowershellProjectDefaultProjectFile)
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
            Write-Warning "Must specify the -ProjectFile, or use Set-PspPowershellProjectDefaults command to set a default ProjectFile"
            $continueProcessing = $false
        }
    }
    Process
    {
        if ( $continueProcessing -eq $true ) 
        {

            if ( (Get-PspPowershellProjectVersion -ProjectFile $ProjectFile).IsLatest -eq $true )
            {                
                # version 1.3 and later.
                $projectData = Get-PspProjectData # Import-Clixml -Path $ProjectFile

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
                            if ( ( $line.Trim().StartsWith("Function") ) -and ( -not ( $line.Contains("FunctionsToExport") ) ) )
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
            } else {
                # versions pre 1.3
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
            } # end version 1.3 check
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

