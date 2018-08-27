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
        } #continue processing
    }
    End
    {
            if ( (Get-PspPowershellProjectVersion -ProjectFile $ProjectFile).IsLatest -eq $true )
            {                
                # version 1.3 and later.
                $projectData = Get-PspProjectData # Import-Clixml -Path $ProjectFile

            } else {
                # version pre 1.3
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
            } # end version 1.3 check 
            Write-Output $projectData.Keys

    } #continue processing
}
