
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
PS> Get-PowershellProject -ProjectFile .\ISEPSProject.psproj | Format-Table -AutoSize

Name                                   Value                                                                                              
----                                   -----                                                                                              
Remove-SourceFromPowershellProject.ps1 @{FileName=Remove-SourceFromPowershellProject.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}     
Build-PowershellProject.ps1            @{FileName=Build-PowershellProject.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}                
Close-PowershellProject.ps1            @{FileName=Close-PowershellProject.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}                
Clean-PowershellProject.ps1            @{FileName=Clean-PowershellProject.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}                
Set-IncludeInBuildFlagForSource.ps1    @{FileName=Set-IncludeInBuildFlagForSource.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}        
Open-PowershellProject.ps1             @{FileName=Open-PowershellProject.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}                 
Get-PowershellProjectBackup.ps1        @{FileName=Get-PowershellProjectBackup.ps1; ProjectTab=ISE PSProj Backup; IncludeInBuild=False}    
Get-PowershellProject.ps1              @{FileName=Get-PowershellProject.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}                  
Compare-PowershellProjectBackup.ps1    @{FileName=Compare-PowershellProjectBackup.ps1; ProjectTab=ISE PSProj Backup; IncludeInBuild=False}
Set-PowershellProjectDefaults.ps1      @{FileName=Set-PowershellProjectDefaults.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}          
UtilityFunctions.ps1                   @{FileName=UtilityFunctions.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}                       
Add-SourceToPowershellProject.ps1      @{FileName=Add-SourceToPowershellProject.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}          
Create-PowershellProject.ps1           @{FileName=Create-PowershellProject.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}               
#>
Function Get-PowershellProject
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
            Write-Warning "Must specify the -ProjectFile, or use Set-PowershellProjectDefaults command to set a default ProjectFile"
            $continueProcessing = $false
        }
    }
    Process
    {
        if ( $continueProcessing -eq $true ) 
        {
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

            Write-Output $projectData
        } #continue processing
    }
    End
    {
    }
}

