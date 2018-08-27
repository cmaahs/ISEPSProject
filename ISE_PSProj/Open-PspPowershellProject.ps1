Function Open-PspPowershellProject
{
<#
.Synopsis
   Open a Powershell .PSPROJ file in ISE, separated by TABS
.DESCRIPTION
   Define a collection of scripts and open them in a single command.

   This process will loop through the Source files and their associated Project TAB names and open new TABs and open the Source files on those TABs.

.EXAMPLE
   Open-PspPowershellProject -ProjectFile ISEPSProject.psproj
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
            Write-Verbose "ProjectFile: $($ProjectFile)"
            $vCheck = Get-PspPowershellProjectVersion -ProjectFile $ProjectFile -Verbose
            Write-Verbose $vCheck
            Write-Verbose "Version Check $((Get-PspPowershellProjectVersion -ProjectFile $ProjectFile -Verbose).IsLatest)" 
            if ( (Get-PspPowershellProjectVersion -ProjectFile $ProjectFile).IsLatest -eq $false )
            {
                Write-Verbose "Update to $((Get-PspPowershellProjectCurrentVersion).CurrentVersion)"
                Update-PspPowershellProjectVersion -ProjectFile $ProjectFile
            }
            
            if ( (Get-PspPowershellProjectVersion -ProjectFile $ProjectFile).IsLatest -eq $true )
            {                
                # open version 1.3 and later.
                Write-Verbose "Running an open using version 1.3 format."
                $projectData = Get-PspProjectData # Import-Clixml -Path $ProjectFile

                $toolsTab = $psISE.PowerShellTabs.Add()
                $toolsTab.DisplayName = "Project Code Tools"
                $pwd = Get-Location
                Start-Sleep -Seconds 2
                Write-Verbose "Setting default location for $($item_tab)"
                $toolsTab.Invoke("Set-Location $pwd")
                $codeTools = @'
#Start-PspBuildPowershellProject -Force -Verbose


$newTab = $psISE.PowerShellTabs.Add()
$newTab.DisplayName = "Module Test"
$pwd = Get-Location
Start-Sleep -Seconds 2
Write-Verbose "Setting default location for $($item_tab)"
$newTab.Invoke("Set-Location $pwd")
$text = @"
Import-Module $((Get-Location).Path.Split("\")[-1]).psm1
#some commands here, possibly add commands to the .psproj directory to populate here.
"@
$newTab.ExpandedScript = $true
Start-Sleep -Seconds 2
$newTab.Files[0].Editor.Text = $text
'@
                $toolsTab.ExpandedScript = $true
                Start-Sleep -Seconds 2
                $toolsTab.Files[0].Editor.Text = $codeTools


                $tab = ($projectData.Values | Select-Object -Property ProjectTab | Sort-Object -Property ProjectTab -Unique).ProjectTab
                foreach ( $item_tab in $tab ) 
                {
                    Write-Verbose "Creating new TAB: $($item_tab)"
                    $newTab = $psISE.PowerShellTabs.Add()
                    $newTab.DisplayName = $item_tab            

                    $sourceFile = $projectData.GetEnumerator() | Where-Object { $_.Value.ProjectTab -eq $item_tab } | Sort-Object -Property Name
                    foreach ( $item_sourceFile in $sourceFile ) 
                    {
                        Write-Verbose "Opening: $(Get-Location)\$($item_sourceFile.Name)"
                        $addResult = $newTab.Files.Add("$(Get-Location)\$($item_sourceFile.Name)")
                    }
                    $pwd = Get-Location
                    Start-Sleep -Seconds 2
                    Write-Verbose "Setting default location for $($item_tab)"
                    $newTab.Invoke("Set-Location $pwd")
                }


            } else { 
                # open pre 1.3 version ({Project}.psproj file based
                Write-Verbose "Opening using a pre 1.3 format."
                $projectData = Import-Clixml -Path $ProjectFile

                if ( $ProjectFile.StartsWith(".\") )
                {
                    $projectFileKey = $ProjectFile.SubString(2)
                } else {
                    $projectFileKey = $ProjectFile
                }       
                Write-Verbose "Checking for ProjectFile: $($ProjectFileKey)"
                if ( $projectData.ContainsKey($projectFileKey) )
                {
                    $projectData.Remove($projectFileKey)
                }
                if ( $projectData.ContainsKey("ISEPSProjectDataVersion") )
                {
                    $projectData.Remove("ISEPSProjectDataVersion")
                }

                $toolsTab = $psISE.PowerShellTabs.Add()
                $toolsTab.DisplayName = "Project Code Tools"
                $pwd = Get-Location
                Start-Sleep -Seconds 2
                Write-Verbose "Setting default location for $($item_tab)"
                $toolsTab.Invoke("Set-Location $pwd")
                $codeTools = @'
#Start-PspBuildPowershellProject -Force -Verbose


$newTab = $psISE.PowerShellTabs.Add()
$newTab.DisplayName = "Module Test"
$pwd = Get-Location
Start-Sleep -Seconds 2
Write-Verbose "Setting default location for $($item_tab)"
$newTab.Invoke("Set-Location $pwd")
$text = @"
Import-Module $((Get-Location).Path.Split("\")[-1]).psm1
#some commands here, possibly add commands to the .psproj directory to populate here.
"@
$newTab.ExpandedScript = $true
Start-Sleep -Seconds 2
$newTab.Files[0].Editor.Text = $text
'@
                $toolsTab.ExpandedScript = $true
                Start-Sleep -Seconds 2
                $toolsTab.Files[0].Editor.Text = $codeTools


                $tab = ($projectData.Values | Select-Object -Property ProjectTab | Sort-Object -Property ProjectTab -Unique).ProjectTab
                foreach ( $item_tab in $tab ) 
                {
                    Write-Verbose "Creating new TAB: $($item_tab)"
                    $newTab = $psISE.PowerShellTabs.Add()
                    $newTab.DisplayName = $item_tab            

                    $sourceFile = $projectData.GetEnumerator() | Where-Object { $_.Value.ProjectTab -eq $item_tab } | Sort-Object -Property Name
                    foreach ( $item_sourceFile in $sourceFile ) 
                    {
                        Write-Verbose "Opening: $(Get-Location)\$($item_sourceFile.Name)"
                        $addResult = $newTab.Files.Add("$(Get-Location)\$($item_sourceFile.Name)")
                    }
                    $pwd = Get-Location
                    Start-Sleep -Seconds 2
                    Write-Verbose "Setting default location for $($item_tab)"
                    $newTab.Invoke("Set-Location $pwd")
                }
            } # end open pre 1.3 version ({Project}.psproj file based
            $psISE.PowerShellTabs.SetSelectedPowerShellTab($toolsTab)
        } #continue processing
    }
    End
    {
        if ( $continueProcessing -eq $true ) 
        {
        }
    }
}
