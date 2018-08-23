Function Close-PspPowershellProject
{
<#
.Synopsis
   Close Project Source files if they are saved.  This routine was born out of the problem of simply closing ISE with bunches of files/tabs open.  Often the next re-open caused ISE to go into recovery mode.
.DESCRIPTION
   This process will loop through the Source files and their associated Project TAB names and close the open files (if they are saved) and close any empty TABs.

.EXAMPLE
   Close-PspPowershellProject -ProjectFile ISEPSProject.psproj

Files that are not part of the .psproj file AND files unsaved will be left open.
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
        } #continue processing
   }
    End
    {
        if ( $continueProcessing -eq $true )
        {
            if ( (Get-PspPowershellProjectVersion -ProjectFile $ProjectFile).IsLatest -eq $false )
            {
                Update-PspPowershellProjectVersion -ProjectFile $ProjectFile
            }
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

            $activeTabs = $psISE.PowerShellTabs

            $removeTabs = @()
            foreach ( $tab in $activeTabs )
            {
                $activeFiles = $tab.Files
                $removeFiles = @()
                foreach ( $file in $activeFiles )
                {
                    Write-Verbose "Checking: $($file.DisplayName)"
                    Write-Verbose "Checking: $($tab.DisplayName)\$($file.DisplayName)"
                    if ( ( $projectData.ContainsKey($file.DisplayName) ) -or ( $projectData.ContainsKey("$($tab.DisplayName)\$($file.DisplayName)") ) ) 
                    {
                        Write-Verbose "Found Key, it lives on $($projectData[$file.Displayname])$($tab.DisplayName)\$($file.DisplayName)"
                        if ( ( ($projectData[$file.DisplayName]).ProjectTab -eq $tab.DisplayName ) -or ( $projectDAta["$($tab.DisplayName)\$($file.DisplayName)"].ProjectTab -eq $tab.DisplayName ) ) 
                        {
                            Write-Verbose "Key is in current tab"
                            #this file on this tab IS part of the project and can be closed, if it hasn't been saved.
                            if ( $file.IsSaved ) 
                            {
                                $removeFiles += $file
                            }
                        }
                    }
                }
                foreach ( $file in $removeFiles )
                {
                    Write-Verbose "Attempting to close: $($file.DisplayName)"
                    $tab.Files.Remove($file)            
                }
                if ( $tab.Files.Count -eq 0 ) 
                {
                    Write-Verbose "Scheduling the removal of $($tab.DisplayName)"
                    $removeTabs += $tab
                }
            }

            $activeTab = $psISE.CurrentPowerShellTab.DisplayName
            foreach ( $tab in $removeTabs ) 
            {
                if ( $tab.DisplayName -eq $activeTab )
                {
                    $lastTabToRemove = $tab
                } else {
                    Write-Verbose "Removing Empty Tab: $($tab.DisplayName)"
                    $psISE.PowerShellTabs.Remove($tab)
                }
            }
            $lastTabToRemove.DisplayName = "ISEPSProject - Last Tab"
            $newTab = $psISE.PowerShellTabs.Add()
            $psISE.PowerShellTabs.Remove($lastTabToRemove)            
        }
    } #continue processing
}

