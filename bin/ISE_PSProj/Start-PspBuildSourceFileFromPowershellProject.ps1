Function Start-PspBuildSourceFileFromPowershellProject
{
<#
.Synopsis
   Build a single PS1 from from a source PS1 file.
.DESCRIPTION
   when we use the <#PINC: replacement feature, we cannot simply RUN the code in the ISE editor window in order to add the function to our session.  We need to "build" it first, then we can dot load it into our session from the "bin" directory.
.EXAMPLE
   Start-PspBuildSourceFileFromPowershellProject -SourceFile ISE_PSProj\Add-PspSourceToPowershellProject.ps1 -ProjectFile ISEPSProject.psproj -Force

Build Created.
Import the built PS1 file into your session with:
. .\bin\Add-PspSourceToPowershellProject.ps1
#>
    [CmdletBinding()]
    Param
    (   
        # Specify the project file to open.  Default project can be specified via the Set-PspPowershellProjectDefaults command.
        [Parameter(Mandatory=$false,
                   Position=1)]
        [Alias('File','FilePath')]
        #[ValidateScript({ Test-Path $_ })]
        [string]       
        $ProjectFile = (Get-PspPowershellProjectDefaultProjectFile)
        ,
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
        $commonParameters = Get-PspCommonParameters        
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
            $moduleFile = ".\bin\$((Get-ChildItem $SourceFile).Name)"
            Write-Verbose "Build File Name: $($moduleFile)"
            if ( Test-Path $moduleFile )
            {
                $backupModule = Get-Content $moduleFile
            }

            if ( $continueProcessing -eq $true )
            {
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
            } #continue processing            
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
                    Write-Output "Import the built PS1 file into your session with:"
                    Write-Output ". $($moduleFile)"
                } else {
                    Write-Warning "You must specify the -Force switch in order to over-write the existing psm1 file."
                }
            } #continue processing        
        } #continue processing
    }
}

