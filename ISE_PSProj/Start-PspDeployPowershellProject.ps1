Function Start-PspDeployPowershellProject
{
<#
.Synopsis
   Deploy a .psproj deliverable to the local Documents\WindowsPowershell\Modules\{projectname}\{projectname}.psm1 target.

   Location can be set with: Set-PspPowershellProjectDefaults -LocalDeployDirectory {deploy directory}
.DESCRIPTION
   
.EXAMPLE
   Start-PspDeployPowershellProject -ProjectFile ISEPSProject.psproj -Force

VERBOSE: Default Target Directory: C:\Program Files\WindowsPowerShell\Modules\ISEPSProject
VERBOSE: Module File Name: ISEPSProject.psm1
VERBOSE: Manifest File Name: ISEPSProject.psd1
VERBOSE: Target Path: C:\Program Files\WindowsPowerShell\Modules\ISEPSProject
#>
    [CmdletBinding()]
    Param
    (
        <#PINC:ProjectFile#>
        <#PINC:PARAMCOMMA#>
        # Force overwrite of the existing psm1 file.
        [Parameter(Mandatory=$false,
                   Position=1)]
        [switch]
        $Force = $false
    )

    Begin
    {
        $continueProcessing = $true
        #$commonParameters = Get-PspCommonParameters
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
        $defaultTargetDirectory = (Get-PspPowershellProjectDefaultLocalDeployDirectory)
        $buildStyle = (Get-PspPowershellProjectDefaultBuildStyle)
        Write-Verbose "Default Target Directory: $($defaultTargetDirectory)"
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
            if ( (Get-PspPowershellProjectVersion -ProjectFile $ProjectFile).IsLatest -eq $true )
            {                
                # version 1.3 and later.
                $projectData = Get-PspProjectData # Import-Clixml -Path $ProjectFile
                $newModule = @()

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

                $rootPath = (Get-ChildItem ($ProjectFile)).Directory.FullName
                $aboutList = Get-ChildItem -Path $rootPath -Filter 'about*.txt' -Recurse
                foreach ( $aboutFile in $aboutList )
                {
                    $dirName = $aboutFile.Directory.Name
                    $dirPath = $aboutFile.Directory.FullName
                    if ( -not ( Test-Path "$($targetDirectory)\$($dirName)" ) ) 
                    {
                        New-Item -Path "$($targetDirectory)\$($dirName)" -ItemType Directory
                    }
                    if ( Test-Path $dirPath )
                    {
                        Copy-Item -Path $dirPath -Destination "$($targetDirectory)" -Recurse -Force
                    }
                }

                if ( $buildStyle -eq "IncludeStyle" )
                {
                
                
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
            } else {
                # version pre 1.3
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

                $rootPath = (Get-ChildItem ($ProjectFile)).Directory.FullName
                $aboutList = Get-ChildItem -Path $rootPath -Filter 'about*.txt' -Recurse
                foreach ( $aboutFile in $aboutList )
                {
                    $dirName = $aboutFile.Directory.Name
                    $dirPath = $aboutFile.Directory.FullName
                    if ( -not ( Test-Path "$($targetDirectory)\$($dirName)" ) ) 
                    {
                        New-Item -Path "$($targetDirectory)\$($dirName)" -ItemType Directory
                    }
                    if ( Test-Path $dirPath )
                    {
                        Copy-Item -Path $dirPath -Destination "$($targetDirectory)" -Recurse -Force
                    }
                }

                if ( $buildStyle -eq "IncludeStyle" )
                {
                
                
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
            } # end version 1.3 check                
        } #continue processing
    }
}
