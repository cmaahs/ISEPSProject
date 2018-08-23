Function Add-PspSourceToPowershellProject
{
<#
.Synopsis
   Add a source file to an existing .psproj file.
.DESCRIPTION
   Add a source file and corresponding TAB name to the .psproj file so it can be opened as a single project later.  A backup in the -streams section of the file will also be created.
   10 backups will be kept and can be listed with Get-PspPowershellProjectBackup function.
.EXAMPLE
    Get-ChildItem


    Directory: C:\Powershell\ISEPSProject


Mode                LastWriteTime         Length Name                                                                                                                                                                
----                -------------         ------ ----                                                                                                                                                                
-a----       12/28/2016   8:10 AM           2115 Add-PspSourceToPowershellProject.ps1                                                                                                                                   
-a----       12/27/2016   8:04 PM           1865 Repair-PspPowershellProject.ps1                                                                                                                                         
-a----       12/27/2016   7:46 PM           1715 Compare-PspPowershellProjectBackup.ps1                                                                                                                                 
-a----       12/28/2016   8:06 AM           5637 New-PspPowershellProject.ps1                                                                                                                                        
-a----       12/28/2016   7:17 AM            691 Get-PspPowershellProject.ps1                                                                                                                                           
-a----       12/27/2016   7:45 PM            916 Get-PspPowershellProjectBackup.ps1                                                                                                                                     
-a----       12/28/2016   8:06 AM            718 ISEPSProject.psproj                                                                                                                                                 
-a----       12/28/2016   7:23 AM           2035 Open-PspPowershellProject.ps1                                                                                                                                          
-a----       12/28/2016   7:29 AM           2135 Remove-PspSourceFromPowershellProject.ps1                                                                                                                              



    Add-PspSourceToPowershellProject -ProjectFile .\ISEPSProject.psproj -SourceFile .\Add-PspSourceToPowershellProject.ps1 -ProjectTab "ISE PSProj" -IncludeInBuild

1 file(s) have been added to the project
0 duplicate file(s) have been skipped
.EXAMPLE
    Get-ChildItem


    Directory: C:\Powershell\ISEPSProject


Mode                LastWriteTime         Length Name                                                                                                                                                                
----                -------------         ------ ----                                                                                                                                                                
-a----       12/28/2016   8:10 AM           2115 Add-PspSourceToPowershellProject.ps1                                                                                                                                   
-a----       12/27/2016   8:04 PM           1865 Repair-PspPowershellProject.ps1                                                                                                                                         
-a----       12/27/2016   7:46 PM           1715 Compare-PspPowershellProjectBackup.ps1                                                                                                                                 
-a----       12/28/2016   8:06 AM           5637 New-PspPowershellProject.ps1                                                                                                                                        
-a----       12/28/2016   7:17 AM            691 Get-PspPowershellProject.ps1                                                                                                                                           
-a----       12/27/2016   7:45 PM            916 Get-PspPowershellProjectBackup.ps1                                                                                                                                     
-a----       12/28/2016   8:06 AM            718 ISEPSProject.psproj                                                                                                                                                 
-a----       12/28/2016   7:23 AM           2035 Open-PspPowershellProject.ps1                                                                                                                                          
-a----       12/28/2016   7:29 AM           2135 Remove-PspSourceFromPowershellProject.ps1                                                                                                                              



    Add-PspSourceToPowershellProject -ProjectFile .\ISEPSProject.psproj -SourceFile .\Repair-PspPowershellProject.ps1,Compare-PspPowershellProjectBackup.ps1 -ProjectTab "ISE PSProj" -IncludeInBuild

2 file(s) have been added to the project
0 duplicate file(s) have been skipped
.EXAMPLE 
    Get-ChildItem


    Directory: C:\Powershell\ISEPSProject


Mode                LastWriteTime         Length Name                                                                                                                                                                
----                -------------         ------ ----                                                                                                                                                                
-a----       12/28/2016   8:26 AM           7895 Add-PspSourceToPowershellProject.ps1                                                                                                                                   
-a----       12/27/2016   8:04 PM           1865 Repair-PspPowershellProject.ps1                                                                                                                                         
-a----       12/27/2016   7:46 PM           1715 Compare-PspPowershellProjectBackup.ps1                                                                                                                                 
-a----       12/28/2016   8:06 AM           5637 New-PspPowershellProject.ps1                                                                                                                                        
-a----       12/28/2016   8:29 AM            716 Get-PspPowershellProject.ps1                                                                                                                                           
-a----       12/27/2016   7:45 PM            916 Get-PspPowershellProjectBackup.ps1                                                                                                                                     
-a----       12/28/2016   8:28 AM           1482 ISEPSProject.psproj                                                                                                                                                 
-a----       12/28/2016   7:23 AM           2035 Open-PspPowershellProject.ps1                                                                                                                                          
-a----       12/28/2016   7:29 AM           2135 Remove-PspSourceFromPowershellProject.ps1                                                                                                                              



    Get-PspPowershellProject -ProjectFile .\ISEPSProject.psproj

Name                                   Value                                                                                              
----                                   -----                                                                                              
Repair-PspPowershellProject.ps1            @{FileName=Repair-PspPowershellProject.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}                
Compare-PspPowershellProjectBackup.ps1    @{FileName=Compare-PspPowershellProjectBackup.ps1; ProjectTab=ISE PSProj Backup; IncludeInBuild=False}
Add-PspSourceToPowershellProject.ps1      @{FileName=Add-PspSourceToPowershellProject.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}          
     

    Add-PspSourceToPowershellProject -ProjectFile .\ISEPSProject.psproj -SourceFile (Get-ChildItem -Filter *.ps1).FullName -ProjectTab "ISE PSProj"

5 file(s) have been added to the project
3 duplicate file(s) have been skipped
.EXAMPLE
    Get-PspPowershellProject .\ISEPSProject.psproj

Name                                   Value                                                                                              
----                                   -----                                                                                              
Remove-PspSourceFromPowershellProject.ps1 @{FileName=Remove-PspSourceFromPowershellProject.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}     
Start-PspBuildPowershellProject.ps1            @{FileName=Start-PspBuildPowershellProject.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}                
Repair-PspPowershellProject.ps1            @{FileName=Repair-PspPowershellProject.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}                
Open-PspPowershellProject.ps1             @{FileName=Open-PspPowershellProject.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}                 
Get-PspPowershellProjectBackup.ps1        @{FileName=Get-PspPowershellProjectBackup.ps1; ProjectTab=ISE PSProj Backup; IncludeInBuild=False}    
Get-PspPowershellProject.ps1              @{FileName=Get-PspPowershellProject.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}                  
Compare-PspPowershellProjectBackup.ps1    @{FileName=Compare-PspPowershellProjectBackup.ps1; ProjectTab=ISE PSProj; IncludeInBuild=False}
Add-PspSourceToPowershellProject.ps1      @{FileName=Add-PspSourceToPowershellProject.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}          
New-PspPowershellProject.ps1           @{FileName=New-PspPowershellProject.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}               



    Add-PspSourceToPowershellProject -ProjectFile .\ISEPSProject.psproj -SourceFile .\Compare-PspPowershellProjectBackup.ps1 -ProjectTab "ISE PSProj Backup"

0 file(s) have been added to the project
0 duplicate file(s) have been skipped
1 source file(s) have had their TAB locations updated.
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
        # Name of TAB to place the source file on when opening in ISE via the Open-PspPowershellProject command.
        [Parameter(Mandatory=$false,
                   Position=2)]
        [Alias('Tab','TabName')]
        [string]
        $ProjectTab = ""
        ,
        # Used to set the ReadMeOrder for the source file.
        [Parameter(Mandatory=$false,
                   Position=3)]
        [int]
        $ReadMeOrder = "999"    
        ,
        # Flag the source file for inclusion in a module build via Start-PspBuildPowershellProject command.  Default can be set via Set-PspPowershellProjectDefaults command.
        [Parameter(Mandatory=$false,
                   Position=4)]
        [switch]
        $IncludeInBuild = (Get-PspPowershellProjectDefaultIncludeInBuild)
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
            $addCount = 0
            $duplicateCount = 0
            $updatedCount = 0
            $skippedCount = 0

            if ( (Get-PspPowershellProjectVersion -ProjectFile $ProjectFile).IsLatest -eq $false )
            {
                Update-PspPowershellProjectVersion -ProjectFile $ProjectFile
            }
            $projectData = Import-Clixml -Path $ProjectFile        

            foreach ( $item_SourceFile in $m_SourceFileList )
            {                
                $okToAdd = $true
                if ( $ProjectTab -eq "" )
                {
                    Write-Verbose "Item_SoureFile: $($item_SourceFile)"
                    $ProjectTab = Get-PspISETabNameFromPath -ProjectFileItem $item_SourceFile -ProjectFile $ProjectFile
                    if ( $ProjectTab -eq "" )
                    {           
                        $okToAdd = $false      
                        Write-Warning "Unable to automatically determine -ProjectTab from directory name for $($item_SourceFile)."
                    }
                }
                #check and remove FULL path
                $projectRoot = (Get-ChildItem -Path $ProjectFile).Directory.FullName
                if ( $item_SourceFile.StartsWith($projectRoot) )
                {
                    $item_SourceFile = $item_SourceFile.SubString($projectRoot.Length+1)
                }
                #check and remove .\ notation.
                if ( $item_SourceFile.StartsWith(".\") )
                {
                    $item_SourceFile = $item_SourceFile.SubString(2)
                }        
                if ( -Not ($projectData.ContainsKey($item_Sourcefile) ) )
                {
                    if ( $okToAdd -eq $true )
                    {
                        $item = "" | Select-Object FileName,ProjectTab,IncludeInBuild,ReadMeOrder
                        $item.FileName = $item_SourceFile
                        $item.ProjectTab = $ProjectTab
                        $item.IncludeInBuild = $IncludeInBuild
                        $item.ReadMeOrder = $ReadMeOrder
                        $item.PSObject.TypeNames.Insert(0,"PowershellProject.ProjectData")
                        $projectData.Add($item_SourceFile, $item)
                        $addCount++
                    } else {
                        $skippedCount++
                    }
                } else {
                    if ( ($projectData.Get_Item($item_Sourcefile)).ProjectTab -eq $ProjectTab )
                    {
                        $duplicateCount++
                    } else {
                        $item = $projectData.Get_Item($item_Sourcefile)
                        $item.ProjectTab = $ProjectTab
                        $projectData.Set_Item($item_Sourcefile, $item)
                        $updatedCount++
                    }
                }
            }

            Save-PspPowershellProject -ProjectFile $ProjectFile -ProjectData $projectData

            Write-Output "$($addCount) file(s) have been added to the project"
            Write-Output "$($duplicateCount) duplicate file(s) have been skipped"
            Write-Output "$($updatedCount) source file(s) have had their TAB locations updated"
            Write-Output "$($skippedCount) source file(s) have been skipped"        
        } #continue processing
    }
}

