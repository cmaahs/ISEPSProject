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

            if ( (Get-PspPowershellProjectVersion -ProjectFile $ProjectFile).IsLatest -eq $false )
            {
                Update-PspPowershellProjectVersion -ProjectFile $ProjectFile
            }
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

            $tab = ($projectData.Values | Select-Object -Property ProjectTab | Sort-Object -Property ProjectTab -Unique).ProjectTab
            foreach ( $item_tab in $tab ) 
            {
                Write-Verbose "Creating new TAB: $($item_tab)"
                $newTab = $psISE.PowerShellTabs.Add()
                $newTab.DisplayName = $item_tab            

                $sourceFile = $projectData.GetEnumerator() | Where-Object { $_.Value.ProjectTab -eq $item_tab }
                foreach ( $item_sourceFile in $sourceFile ) 
                {
                    Write-Verbose "Opening: $(Get-Location)\$($item_sourceFile.Name)"
                    $newTab.Files.Add("$(Get-Location)\$($item_sourceFile.Name)")
                }
                $pwd = Get-Location
                Start-Sleep -Seconds 2
                Write-Verbose "Setting default location for $($item_tab)"
                $newTab.Invoke("Set-Location $pwd")
            }
        } #continue processing
    }
    End
    {
        if ( $continueProcessing -eq $true ) 
        {
        }
    }
}

