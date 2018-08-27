Function Get-PspProjectData
{
<#
.Synopsis
   Build a PSObject based on the .psproj\files directory structure.
.DESCRIPTION
   Returns a PSObject based on the JSON data files in .psproj\files directory.

.EXAMPLE
    TODO: Example
#>
    [CmdletBinding()]
    Param
    (
        <#PINC:ProjectFile#>
    )

    Begin
    {
        $continueProcessing = $true
        <#
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
        #>
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
            $projectData = @{}
            #$projectVersionInfo = Import-Clixml -Path $ProjectFile
            $controlDirectory = Get-PspControlDirectory
            if ( Test-Path "$($controlDirectory)\.psproj\files" )
            {
                $fileList = Get-ChildItem -Path "$($controlDirectory)\.psproj\files" -Recurse -Filter "*.json" | Sort-Object -Property FullName
                foreach ( $f in $fileList )
                {
                    $key = ($f.FullName.Split("\")[-2..-1] -join "\").Replace(".json","")
                    Write-Verbose "Key adding: $($key)"
                    #$item = "" | Select-Object FileName,ProjectTab,IncludeInBuild,ReadMeOrder
                    $item = Get-Content -Path $f.FullName | ConvertFrom-Json

                    $dataItem = "" | Select-Object FileName,ProjectTab,IncludeInBuild,ReadMeOrder
                    $dataItem.FileName = $item.FileName
                    $dataItem.ProjectTab = $item.ProjectTab
                    $dataItem.ReadMeorder = $item.ReadMeOrder
                    if ( $item.IncludeInBuild -eq $false )
                    {
                        $dataItem.IncludeInBuild = $false
                    } else {
                        $dataItem.IncludeInBuild = $true
                    }

                    $projectData.Add($key,$dataItem)
                }
                Write-Output $projectData                
            } else {
                Write-Error "Cannot locate the .psproj\files\ directory containing the project file metadata"
                $continueProcessing = $false
            } # test for files path
        } #continue processing
    }
}
