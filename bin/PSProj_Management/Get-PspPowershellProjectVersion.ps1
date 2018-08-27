function Get-PspPowershellProjectVersion
{
<#
.Synopsis
   Get the .psproj data version
.DESCRIPTION
   Returns the version of the .psproj data

.EXAMPLE
PS> Get-PspPowershellProjectVersion -ProjectFile ISEPSProject.psproj

Version CurrentVersion IsLatest
------- -------------- --------
1.1     1.1                True

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
            $projectData = Import-Clixml -Path $ProjectFile
            $item = "" | Select-Object Version,CurrentVersion,IsLatest
            $item.CurrentVersion = (Get-PspPowershellProjectCurrentVersion).CurrentVersion
            Write-Verbose "Current Version: $($item.CurrentVersion)"
            $item.IsLatest = $false
        
            if ( $projectData.ContainsKey("ISEPSProjectDataVersion") )
            {
                $item.Version = $projectData["ISEPSProjectDataVersion"]
            } else {
                $item.Version = "1.0"
            }
            Write-Verbose "Project File Version: $($item.Version)"
            if ( $item.CurrentVersion -eq $item.Version ) 
            {
                Write-Verbose "Versions Match"
                $item.IsLatest = $true
            }
            Write-Output $item
        } #continue processing
    }
    End
    {
        if ( $continueProcessing -eq $true )
        {
        }
    }
}

