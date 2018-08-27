Function Get-PspPowershellProject
{
<#
.Synopsis
   Display a list of source files contained in the .psproj file.
.DESCRIPTION
   Used to view the list of files and their associated data. 

   Sources files are in the NAME column, and the associated item details are in the Value column.  

   Value column structure:
   Filename: matches the Name field.
   ProjectTab: name of the ISE TAB the file will be opened on.
   IncludeInBuild: True/False value for including the source file in the building of the psm1 file.
.EXAMPLE
    Get-PspPowershellProject -ProjectFile .\ISEPSProject.psproj | Format-Table -AutoSize

Name                                   Value                                                                                              
----                                   -----                                                                                              
Remove-PspSourceFromPowershellProject.ps1 @{FileName=Remove-PspSourceFromPowershellProject.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}     
Start-PspBuildPowershellProject.ps1            @{FileName=Start-PspBuildPowershellProject.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}                
Close-PspPowershellProject.ps1            @{FileName=Close-PspPowershellProject.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}                
Repair-PspPowershellProject.ps1            @{FileName=Repair-PspPowershellProject.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}                
Set-PspIncludeInBuildFlagForSource.ps1    @{FileName=Set-PspIncludeInBuildFlagForSource.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}        
Open-PspPowershellProject.ps1             @{FileName=Open-PspPowershellProject.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}                 
Get-PspPowershellProjectBackup.ps1        @{FileName=Get-PspPowershellProjectBackup.ps1; ProjectTab=ISE PSProj Backup; IncludeInBuild=False}    
Get-PspPowershellProject.ps1              @{FileName=Get-PspPowershellProject.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}                  
Compare-PspPowershellProjectBackup.ps1    @{FileName=Compare-PspPowershellProjectBackup.ps1; ProjectTab=ISE PSProj Backup; IncludeInBuild=False}
Set-PspPowershellProjectDefaults.ps1      @{FileName=Set-PspPowershellProjectDefaults.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}          
UtilityFunctions.ps1                   @{FileName=UtilityFunctions.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}                       
Add-PspSourceToPowershellProject.ps1      @{FileName=Add-PspSourceToPowershellProject.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}          
New-PspPowershellProject.ps1           @{FileName=New-PspPowershellProject.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}               
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
            if ( (Get-PspPowershellProjectVersion -ProjectFile $ProjectFile).IsLatest -eq $true )
            {                
                # version 1.3 and later.
                $projectData = Get-PspProjectData # Import-Clixml -Path $ProjectFile

                $projectDataValues = @()            
                foreach ( $key in $projectData.Keys )
                {
                    $item = "" | Select-Object ProjectTab,FileName,IncludeInBuild,ReadMeOrder
                    $item.ProjectTab = $projectData[$key].ProjectTab
                    $item.FileName = $projectData[$key].FileName
                    $item.IncludeInBuild = $projectData[$key].IncludeInBuild
                    $item.ReadMeOrder = $projectData[$key].ReadMeOrder
                    $item.PSObject.TypeNames.Insert(0,"PowershellProject.ProjectData")
                    $projectDataValues += $item                
                }

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
                $projectDataValues = @()            
                foreach ( $key in $projectData.Keys )
                {
                    $item = "" | Select-Object ProjectTab,FileName,IncludeInBuild,ReadMeOrder
                    $item.ProjectTab = $projectData[$key].ProjectTab
                    $item.FileName = $projectData[$key].FileName
                    $item.IncludeInBuild = $projectData[$key].IncludeInBuild
                    $item.ReadMeOrder = $projectData[$key].ReadMeOrder
                    $item.PSObject.TypeNames.Insert(0,"PowershellProject.ProjectData")
                    $projectDataValues += $item                
                }
            }
            Write-Output $projectDataValues | Sort-Object -Property ProjectTab,FileName
        } #continue processing
    }
    End
    {
    }
}

