Function Save-PspProjectData
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
        [Parameter(Mandatory=$false,
                   Position=1)]
        [Hashtable]
        $ProjectData
    )

    Begin
    {
        $continueProcessing = $true
        #$newProjectData = @{}
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
            $controlDirectory = Get-PspControlDirectory
            if ( $controlDirectory -ne "" )
            {
                foreach ( $key in $projectData.Keys )
                {
                    $keyParts = $key.Split("\")
                    # get the base path for .psproj and create the files directory
                    $controlDirectory = Get-PspControlDirectory
                    if ( -not ( Test-Path "$($controlDirectory)\.psproj\files" ) )
                    {
                        $newDir = New-Item -ItemType Directory -Path "$($controlDirectory)\.psproj\files"
                    }

                    # create the {tabname} directory
                    if ( -not ( Test-Path "$($controlDirectory)\.psproj\files\$($keyParts[0])" ) )
                    {
                        $newDir = New-Item -ItemType Directory -Path "$($controlDirectory)\.psproj\files\$($keyParts[0])"
                    }

                    # create the new .psproj\files\{tabname}\{sourcefile}.json file
                    $ProjectData[$key] | ConvertTo-Json | Out-File -FilePath "$($controlDirectory)\.psproj\files\$($keyParts[0])\$($keyParts[1]).json" -Encoding ascii -Force
                                
                    # just propagate all the existing data the way it was in the .psproj file.
                    #if ( $ProjectData.ContainsKey($key) )
                    #{
                    #    $newProjectData.Add($key, $projectData[$key])
                    #}
                }
            }
        } #continue processing
    }
}

