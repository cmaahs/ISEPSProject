Function Set-PspReadMeOrderForSource
{
<#
.Synopsis
    Set the ReadMeOrder value for a source file.
.DESCRIPTION
    Each source item in the .psproj file contains a flag named ReadMeOrder.  This flag drives the order of appearance of Help Text in the README.md file.
.EXAMPLE
#>
    [CmdletBinding()]
    Param
    (
        # Specify the source file name to add to the project.
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true)]        
        [string[]]
        $Name
        ,
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true)]        
        [string[]]
        $Directory
        ,
        # Specify the project file to open.  Default project can be specified via the Set-PspPowershellProjectDefaults command.
        [Parameter(Mandatory=$false,
                   Position=0)]
        [Alias('File','FilePath')]
        #[ValidateScript({ Test-Path $_ })]
        [string]       
        $ProjectFile = (Get-PspPowershellProjectDefaultProjectFile)
        ,
        # Specify the source file name to add to the project.
        [Parameter(Mandatory=$false,
                   Position=1)]
        [Alias('Source','SourcePath')]
        [ValidateScript({ Test-Path $_ })]
        [string[]]
        $SourceFile
        ,
        # Used to set the ReadMeOrder for the source file.
        [Parameter(Mandatory=$false,
                   Position=2)]
        [int]
        $ReadMeOrder = "999"        
    )

    Begin
    {           
        $continueProcessing = $true
        $m_SourceFileList = @()        
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
        if ( ( $Exclude -eq $true ) -and ( $Include -eq $true ) )
        {
            $Exclude = $false            
        }   
        if ( ( $Exclude -eq $false ) -and ( $Include -eq $false ) ) 
        {
            $Include = $true
        }
    }
    Process
    {
        if ( $continueProcessing -eq $true )
        {
            if ( $SourceFile.Length -gt 0 )
            {
                $addFile = $SourceFile
            }
            if ( ( $Name.Length -gt 0 ) -and ( $Directory.Length -gt 0 ) )
            {
                Write-Verbose "File: $($Name)"
                Write-Verbose "Path: $($Directory)"
                Write-Verbose "FullName: $($Directory)\$($Name)"
                $addFile = Get-PspRelativePathFromProjectRoot -FullName "$($Directory)\$($Name)"
            }
            Write-Verbose "Adding $($addFile)"
            if ( $addFile.Length -gt 0 )
            {
                $m_SourceFileList += $addFile
            }
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
            $projectData = Import-Clixml -Path $ProjectFile

            $updatedItems = 0
            $notFoundItems = 0  
            $keyToUpdate = @()      
            foreach ($item_SourceFile in $m_SourceFileList)
            {
                if ( $item_SourceFile.StartsWith(".\") )
                {
                    $item_SourceFile = $item_SourceFile.SubString(2)
                }        
           
                if ( $projectData.ContainsKey($item_SourceFile) )
                {
                    $keyToUpdate += $item_SourceFile
                } else {
                    $notFoundItems++
                }
            }
            foreach ( $item_keyToUpdate in $keyToUpdate )
            {
                $item = $projectData[$item_keyToUpdate]
                $item.ReadMeOrder = $ReadMeOrder
                $projectData[$item_keyToUpdate] = $item
                $updatedItems++
            }

            Save-PspPowershellProject -ProjectFile $ProjectFile -ProjectData $projectData
        
            Write-Output "$($updatedItems) source file(s) have been updated in the project"
            Write-Output "$($notFoundItems) source file(s) were not found in the project"

        } #continue processing
    }
}

