Function Repair-PspPowershellProject
{
<#
.Synopsis
   Removes abandoned files from the .psproj file.
.DESCRIPTION
   Occasionally you will have removed/renamed source files and since we are doing ValidateScripts on passed in source file names these cannot be removed using the Remove-PspSourceFromPowershellProject cmdlet.

   This command will loop through the .psproj file's source files and determine if they exist, and if not, they will be removed.
.EXAMPLE
    Get-ChildItem


    Directory: C:\Powershell\ISEPSProject


Mode                LastWriteTime         Length Name                                                                                                                                                                
----                -------------         ------ ----                                                                                                                                                                
-a----       12/28/2016  10:12 AM          11291 Add-PspSourceToPowershellProject.ps1                                                                                                                                   
-a----       12/28/2016  10:26 AM           2470 Repair-PspPowershellProject.ps1                                                                                                                                         
-a----       12/27/2016   7:46 PM           1715 Compare-PspPowershellProjectBackup.ps1                                                                                                                                 
-a----       12/28/2016   8:06 AM           5637 New-PspPowershellProject.ps1                                                                                                                                        
-a----       12/28/2016  10:22 AM           1688 Get-PspPowershellProject.ps1                                                                                                                                           
-a----       12/27/2016   7:45 PM            916 Get-PspPowershellProjectBackup.ps1                                                                                                                                     
-a----       12/28/2016  10:14 AM           2648 ISEPSProject.psproj                                                                                                                                                 
-a----       12/28/2016   7:23 AM           2035 Open-PspPowershellProject.ps1                                                                                                                                          
-a----       12/28/2016  10:12 AM           5237 Remove-PspSourceFromPowershellProject.ps1                                                                                                                              



    New-Item -Path DoNothing-OnNothing.ps1 -ItemType File


    Directory: C:\Powershell\ISEPSProject


Mode                LastWriteTime         Length Name                                                                                                                                                                
----                -------------         ------ ----                                                                                                                                                                
-a----       12/28/2016  10:27 AM              0 DoNothing-OnNothing.ps1                                                                                                                                             



    Add-PspSourceToPowershellProject -ProjectFile .\ISEPSProject.psproj -SourceFile .\DoNothing-OnNothing.ps1 -ProjectTab "ISE PSProj"

1 file(s) have been added to the project
0 duplicate file(s) have been skipped

    Get-PspPowershellProject -ProjectFile .\ISEPSProject.psproj

Name                                   Value     
----                                   -----     
Add-PspSourceToPowershellProject.ps1      ISE PSProj
Remove-PspSourceFromPowershellProject.ps1 ISE PSProj
New-PspPowershellProject.ps1           ISE PSProj
Open-PspPowershellProject.ps1             ISE PSProj
Repair-PspPowershellProject.ps1            ISE PSProj
Get-PspPowershellProjectBackup.ps1        ISE PSProj
Compare-PspPowershellProjectBackup.ps1    ISE PSProj
DoNothing-OnNothing.ps1                ISE PSProj
Get-PspPowershellProject.ps1              ISE PSProj

    Remove-Item -Path .\DoNothing-OnNothing.ps1

    Get-ChildItem 


    Directory: C:\Powershell\ISEPSProject


Mode                LastWriteTime         Length Name                                                                                                                                                                
----                -------------         ------ ----                                                                                                                                                                
-a----       12/28/2016  10:12 AM          11291 Add-PspSourceToPowershellProject.ps1                                                                                                                                   
-a----       12/28/2016  10:26 AM           2470 Repair-PspPowershellProject.ps1                                                                                                                                         
-a----       12/27/2016   7:46 PM           1715 Compare-PspPowershellProjectBackup.ps1                                                                                                                                 
-a----       12/28/2016   8:06 AM           5637 New-PspPowershellProject.ps1                                                                                                                                        
-a----       12/28/2016  10:22 AM           1688 Get-PspPowershellProject.ps1                                                                                                                                           
-a----       12/27/2016   7:45 PM            916 Get-PspPowershellProjectBackup.ps1                                                                                                                                     
-a----       12/28/2016  10:28 AM           2868 ISEPSProject.psproj                                                                                                                                                 
-a----       12/28/2016   7:23 AM           2035 Open-PspPowershellProject.ps1                                                                                                                                          
-a----       12/28/2016  10:12 AM           5237 Remove-PspSourceFromPowershellProject.ps1                                                                                                                              



    Remove-PspSourceFromPowershellProject -ProjectFile .\ISEPSProject.psproj -SourceFile DoNothing-OnNothing.ps1

Remove-PspSourceFromPowershellProject : Cannot validate argument on parameter 'SourceFile'. The " Test-Path $_ " validation script for the argument with value "DoNothing-OnNothing.ps1" did not return a result of 
True. Determine why the validation script failed, and then try the command again.
At line:1 char:83
+ ... ProjectFile .\ISEPSProject.psproj -SourceFile DoNothing-OnNothing.ps1
+                                                   ~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidData: (:) [Remove-PspSourceFromPowershellProject], ParameterBindingValidationException
    + FullyQualifiedErrorId : ParameterArgumentValidationError,Remove-PspSourceFromPowershellProject
 

    Repair-PspPowershellProject -ProjectFile .\ISEPSProject.psproj

1 source file(s) have been removed from the project.
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
            if ( (Get-PspPowershellProjectVersion -ProjectFile $ProjectFile).IsLatest -eq $true )
            {                
                # version 1.3 and later.
                $projectData = Get-PspProjectData # Import-Clixml -Path $ProjectFile

                $removedItems = 0
                $removeKey = @()
                $controlDirectory = Get-PspControlDirectory
                foreach ( $key in $projectData.Keys )
                {
                    Write-Verbose "Checking $key"
                    if ( -Not ( Test-Path $key ) ) 
                    {
                        $removeKey += $key
                        $removedItem = Remove-Item -Path "$($controlDirectory)\.psproj\files\$($removeKey).json" 
                        $removedItems++
                    }
                }

                foreach ( $item_removeKey in $removeKey ) 
                {
                    $projectData.Remove($item_removeKey)
                }
                
            } else {
                # version pre 1.3
                $projectData = Import-Clixml -Path $ProjectFile

                if ( $ProjectFile.StartsWith(".\") )
                {
                    $projectFileKey = $ProjectFile.SubString(2)
                } else {
                    $projectFileKey = $ProjectFile
                }
            
                $removedItems = 0
                $removeKey = @()
                foreach ( $key in $projectData.Keys )
                {
                    Write-Verbose "Checking $key"
                    if ( ( $key -ne $projectFileKey ) -and ( $key -ne "ISEPSProjectDataVersion" ) )
                    {
                        if ( -Not ( Test-Path $key ) ) 
                        {
                            $removeKey += $key
                            $removedItems++
                        }
                    }
                }

                foreach ( $item_removeKey in $removeKey ) 
                {
                    $projectData.Remove($item_removeKey)
                }

                Save-PspPowershellProject -ProjectFile $ProjectFile -ProjectData $projectData
            }

            Write-Output "$($removedItems) source file(s) have been removed from the project."
        } #continue processing
    }
    End
    {
        if ( $continueProcessing -eq $true )
        {

        }
    }
}