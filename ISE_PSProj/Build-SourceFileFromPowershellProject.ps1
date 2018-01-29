<#
.Synopsis
   Create a single PSM1 file from the PS1 files included in the .psproj file.  Because the ISE editor doesn't yet have great code navigation tools, it is easier to have smaller source files opened separately.
.DESCRIPTION
   This process will loop through the Source files and check for the IncludeInBuild flag.  Any source file with the include flag will be copied into the {projectname}.psm1 file. 
.EXAMPLE
   PS> Build-PowershellProject -ProjectFile ISEPSProject.psproj -Force

Build Created.
All functions export: FunctionsToExport = @('Add-SourceToPowershellProject','Build-PowershellProject','Clean-PowershellProject','Close-PowershellProject','Create-PowershellProjec
t','Get-PowershellProject','Open-PowershellProject','Remove-SourceFromPowershellProject','Set-IncludeInBuildFlagForSource','Set-PowershellProjectDefaults','Get-CSVFromStringArray
','Get-PowershellProjectBackupData','Get-PowershellProjectCurrentVersion','Get-PowershellProjectDefaultIncludeInBuild','Get-PowershellProjectDefaultProjectFile','Get-PowershellPr
ojectFunctions','Get-PowershellProjectVersion','Save-PowershellProject','Save-PowershellProjectDefaults','Update-PowershellProjectVersion')
#>
Function Build-SourceFileFromPowershellProject
{
    [CmdletBinding()]
    Param
    (        
        # Specify the source file name to build in ./bin/
        [Parameter(Mandatory=$true,
                   Position=1)]
        [Alias('Source','SourcePath')]
        [ValidateScript({ Test-Path $_ })]
        [string[]]
        $SourceFile
        ,
        # Force overwrite of the existing ps1 file.
        [Parameter(Mandatory=$false,
                   Position=2)]
        [switch]
        $Force = $false
        ,
        # Add an NTFS streams version of the existing module content to the newly created ps1 file.
        [Parameter(Mandatory=$false,
                   Position=3)]
        [switch]
        $PerformBackup = $false
    )

    Begin
    {
        $continueProcessing = $true
        $commonParameters = Get-CommonParameters        
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
            $moduleFile = ".\.bin\$((Get-ChildItem $SourceFile).Name)"
            Write-Verbose "Build File Name: $($moduleFile)"
            if ( Test-Path $moduleFile )
            {
                $backupModule = Get-Content $moduleFile
            }

            #foreach ( $key in $projectData.Keys )
            #{
                if ( $continueProcessing -eq $true )
                {
                    #if ( $projectData[$key].IncludeInBuild -eq $true ) 
                    #{
                        Write-Verbose "Processing $($SourceFile)..."
                        $psData = Get-Content -Path $SourceFile
                        if ( ($psData | Where-Object { $_.Trim().StartsWith("<#PINC:") }).Count -gt 0 ) 
                        {
                            if ( $commonParameters ) 
                            {
                                $pCount = 0
                                $newData = ""
                                foreach ( $line in $psData ) 
                                {
                                    if ( $line.Trim().StartsWith("<#PINC:") )
                                    {
                                        $incfile = ($line.Split(":")[1]).Replace("#>","")
                                        Write-Verbose "Include File: $($incfile)"
                                        $newData += ($commonParameters[$incfile]).Replace("~x~", $pCount)
                                        $newData += "`r`n"
                                        $pCount++
                                    } else {
                                        $newData += "$($line)`r`n"
                                    }
                                    if ( $line.Trim().StartsWith("[Parameter") )
                                    {
                                        $pCount++
                                    }
                                }
                                $newModule += $newData
                            } else {
                                Write-Error "There is a <#PINC:#> include reference, yet no .\.psproj\commonParameters.clixml exists."
                                $continueProcessing = $false
                            }
                        } else {
                            $newModule += $psData
                        }                    
                    #} #include in build
                } #continue processing
            #}
            if ( $continueProcessing -eq $true )
            {
                if ( ( ( Test-Path $moduleFile ) -and ( $Force -eq $true ) ) -or ( -Not ( Test-Path $moduleFile ) ) )
                {
                    $newModule | Out-File -FilePath $moduleFile -Force -Encoding ascii
                    if ( ( $PerformBackup -eq $true ) -and ( $backupModule.Length -gt 0 ) )
                    {
                        $backupName = (Get-Date).ToString('yyyy-MM-dd_HHmmss')
                        Add-Content -Path $moduleFile -Value $backupModule -Stream $backupName                    
                    }
                    Write-Output "Build Created."
                } else {
                    Write-Warning "You must specify the -Force switch in order to over-write the existing psm1 file."
                }
            } #continue processing
        
        } #continue processing
    }
}
