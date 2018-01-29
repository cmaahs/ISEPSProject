<#
.Synopsis
   Deploy a .psproj deliverable to the local Documents\WindowsPowershell\Modules\{projectname}\{projectname}.psm1 target.
.DESCRIPTION
   
.EXAMPLE
   PS> Deploy-PowershellProject -ProjectFile ISEPSProject.psproj -Force
#>
Function Deploy-PowershellProject
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
        # Force overwrite of the existing psm1 file.
        [Parameter(Mandatory=$false,
                   Position=1)]
        [switch]
        $Force = $false
    )

    Begin
    {
        $continueProcessing = $true
        #$commonParameters = Get-CommonParameters
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
        $defaultTargetDirectory = (Get-PowershellProjectDefaultLocalDeployDirectory)
        $buildStyle = (Get-PowershellProjectDefaultBuildStyle)
        Write-Verbose "Default Target Directory: $($defaultTargetDirectory)"
    }
    Process
    {
        if ( $continueProcessing -eq $true ) 
        {
            if ( (Get-PowershellProjectVersion -ProjectFile $ProjectFile).IsLatest -eq $false )
            {
                Update-PowershellProjectVersion -ProjectFile $ProjectFile
            }
            $projectData = Import-Clixml -Path $ProjectFile
            $newModule = @()

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

            $moduleFile = "$((Get-ChildItem $ProjectFile).BaseName).psm1"
            $manifestFile = "$((Get-ChildItem $ProjectFile).BaseName).psd1"
            if ( ( $defaultTargetDirectory -eq "" ) -or ( -not ( Test-Path $defaultTargetDirectory ) ) )
            {
                $targetDirectory = "$($Env:HOMEDRIVE)$($Env:HOMEPATH)\Documents\WindowsPowerShell\Modules\$((Get-ChildItem $ProjectFile).BaseName)\"
            } else {
                $targetDirectory = $defaultTargetDirectory
            }
            Write-Verbose "Module File Name: $($moduleFile)"
            Write-Verbose "Manifest File Name: $($manifestFile)"
            Write-Verbose "Target Path: $($targetDirectory)"
            if ( Test-Path $targetDirectory )
            {
                Copy-Item -Path $moduleFile -Destination $targetDirectory
                Copy-Item -Path $manifestFile -Destination $targetDirectory
            } else {
                Write-Warning "The target directory $($targetDirectory) does not exists, cannot copy files."
            }
            if ( $buildStyle -eq "IncludeStyle" )
            {
                
                $rootPath = (Get-ChildItem ($ProjectFile)).Directory.FullName
                $buildPath = "$($rootPath)\bin"
                Write-Verbose "Build Path: $($buildPath)"
                if ( -not ( Test-Path "$($targetDirectory)\bin" ) ) 
                {
                    New-Item -Path "$($targetDirectory)\bin" -ItemType Directory
                }
                if ( Test-Path $buildPath )
                {
                    Copy-Item -Path $buildPath -Destination "$($targetDirectory)" -Recurse -Force
                }
                              
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

