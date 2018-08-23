Function New-PspPowershellProject
{
<#
.Synopsis
   Create an empty .psproj file.
.DESCRIPTION
   In order to start populating a .psproj file with the Add and Remove commands one needs to have an existing .psproj because we are validating the existance of the file in all of the other commands in this module that take the -ProjectFile parameter.
.EXAMPLE
   New-PspPowershellProject ISEPSProject
   Get-ChildItem ISEPSProject.psproj


    Directory: C:\Powershell\ISEPSProject


Mode                LastWriteTime         Length Name                                                                                                                                                                
----                -------------         ------ ----                                                                                                                                                                
-a----       12/28/2016   7:57 AM            912 ISEPSProject.psproj                                                                                                                                                 

.EXAMPLE
When the file exists with the .psproj extension, and we only specify the basename, we will fail with a warning.

    dir


    Directory: C:\Powershell\ISEPSProject


Mode                LastWriteTime         Length Name                                                                                                                                                                
----                -------------         ------ ----                                                                                                                                                                
-a----       12/28/2016   7:28 AM           1993 Add-PspSourceToPowershellProject.ps1                                                                                                                                   
-a----       12/27/2016   8:04 PM           1865 Repair-PspPowershellProject.ps1                                                                                                                                         
-a----       12/27/2016   7:46 PM           1715 Compare-PspPowershellProjectBackup.ps1                                                                                                                                 
-a----       12/28/2016   7:44 AM           1207 New-PspPowershellProject.ps1                                                                                                                                        
-a----       12/28/2016   7:17 AM            691 Get-PspPowershellProject.ps1                                                                                                                                           
-a----       12/27/2016   7:45 PM            916 Get-PspPowershellProjectBackup.ps1                                                                                                                                     
-a----       12/28/2016   7:44 AM            912 ISEPSProject.psproj                                                                                                                                                   
-a----       12/28/2016   7:23 AM           2035 Open-PspPowershellProject.ps1                                                                                                                                          
-a----       12/28/2016   7:29 AM           2135 Remove-PspSourceFromPowershellProject.ps1                                                                                                                              

    New-PspPowershellProject ISEProject

WARNING: After adding .psproj extension to the chosen filename, we have determined the file already exists.
.EXAMPLE
When we specify a project file with the extension, and it already exists, we will fail via the ValidationScript.

    New-PspPowershellProject ISEPSProject.psproj

New-PspPowershellProject : Cannot validate argument on parameter 'ProjectFile'. The " -Not (Test-Path $_) " validation script for the argument with value "ISEPSProject.psproj" did not return a result of True. 
Determine why the validation script failed, and then try the command again.
At line:1 char:26
+ New-PspPowershellProject ISEPSProject.psproj
+                          ~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidData: (:) [New-PspPowershellProject], ParameterBindingValidationException
    + FullyQualifiedErrorId : ParameterArgumentValidationError,New-PspPowershellProject
 
#>
    [CmdletBinding()]
    Param
    (
        # Specify the project file to open.
        [Parameter(Mandatory=$true,
                   Position=0)]
        [Alias('File','FilePath')]
        [ValidateScript({ -Not (Test-Path $_) })]
        [string]
        $ProjectFile
        ,
        # Create new project details, adding defaults, PSD file, etc.
        [Parameter(Mandatory=$true,
                   Position=0)]
        [switch]
        $CreateNewProjectDetails
    )

    Begin
    {
        $baseName = [System.IO.Path]::GetFileNameWithoutExtension($ProjectFile)
        $extension = [System.IO.Path]::GetExtension($ProjectFile)

        $ProjectFileToCreate = "$($baseName).psproj"

        Write-Verbose "Checking for the existance of the filename with the .psproj extension: $($ProjectFileToCreate)"
        if ( Test-Path $ProjectFileToCreate ) 
        {
            Write-Warning "After adding .psproj extension to the chosen filename, we have determined the file already exists."
            break;
        }

    }
    Process
    {   
    }
    End
    {
        $projectData = @{"$($ProjectFileToCreate)"="$($ProjectFileToCreate)";"ISEPSProjectDataVersion"="$((Get-PspPowershellProjectCurrentVersion).CurrentVersion)"}
        $projectData | Export-Clixml -Path $ProjectFileToCreate -Force

        if ( $CreateNewProjectDetails -eq $true )
        {
            #Set Defaults
            Set-PspPowershellProjectDefaults -ProjectFile $ProjectFileToCreate -IncludeInBuild No -BuildStyle IncludeStyle
            
            #PSD File Creation
            $psdFileName = ".\Deploy\$($baseName).psd1"
            if ( -not ( Test-Path ".\Deploy" ) )
            {
                New-Item -Path ".\Deploy" -ItemType Directory
            }
            if ( -not ( Test-Path $psdFileName ) )
            {
                $psdTemplate = @"
#
# Module manifest for module '$($baseName)'
#
# Generated by: TODO:Add Name
#
# Generated on: $((Get-Date).ToString("yyyy-MM-dd"))
#

@{

# Script module or binary module file associated with this manifest.
RootModule = '.\$($baseName).psm1'

# Version number of this module.
ModuleVersion = '1.0'

# ID used to uniquely identify this module
GUID = '$(New-Guid)'

# Author of this module
Author = 'TODO:Add Author'

# Company or vendor of this module
CompanyName = 'TODO:Add Company'

# Copyright statement for this module
Copyright = 'TODO:Add Copyright'

# Description of the functionality provided by this module
Description = 'TODO:Add Description'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '3.0'

# Name of the Windows PowerShell host required by this module
# PowerShellHostName = ''

# Minimum version of the Windows PowerShell host required by this module
# PowerShellHostVersion = ''

# Minimum version of Microsoft .NET Framework required by this module
# DotNetFrameworkVersion = ''

# Minimum version of the common language runtime (CLR) required by this module
# CLRVersion = ''

# Processor architecture (None, X86, Amd64) required by this module
# ProcessorArchitecture = ''

# Modules that must be imported into the global environment prior to importing this module
# RequiredModules = @()

# Assemblies that must be loaded prior to importing this module
# RequiredAssemblies = @()

# Script files (.ps1) that are run in the caller's environment prior to importing this module.
# ScriptsToProcess = @()

# Type files (.ps1xml) to be loaded when importing this module
# TypesToProcess = @()

# Format files (.ps1xml) to be loaded when importing this module
# FormatsToProcess = @()

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
# NestedModules = @()

# Functions to export from this module
FunctionsToExport = '*'

# Cmdlets to export from this module
CmdletsToExport = '*'

# Variables to export from this module
VariablesToExport = '*'

# Aliases to export from this module
AliasesToExport = '*'

# DSC resources to export from this module
# DscResourcesToExport = @()

# List of all modules packaged with this module
# ModuleList = @()

# List of all files packaged with this module
# FileList = @()

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        # Tags = @()

        # A URL to the license for this module.
        # LicenseUri = ''

        # A URL to the main website for this project.
        # ProjectUri = ''

        # A URL to an icon representing this module.
        # IconUri = ''

        # ReleaseNotes of this module
        ReleaseNotes = @'
TODO: Add Release Notes
'@

    } # End of PSData hashtable

} # End of PrivateData hashtable

# HelpInfo URI of this module
# HelpInfoURI = ''

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''

}
"@
                $psdTemplate | Out-File -FilePath $psdFileName -Force -Encoding ascii

                #Add PSD to Defaults
                Set-PspPowershellProjectDefaults -ModulePSDFile $psdFileName
                Add-PspSourceToPowershellProject -ProjectFile $ProjectFileToCreate -SourceFile $psdFileName
                Set-PspPowershellProjectDefaults -IncludeInBuild Yes
            } else {
                Write-Warning "A PSD1 file already exists in the Deploy directory."
            }

            
            #README.md File Creation
            $readmeFileName = ".\Deploy\README.md"
            if ( -not ( Test-Path ".\Deploy" ) )
            {
                New-Item -Path ".\Deploy" -ItemType Directory
            }
            if ( -not ( Test-Path $readmeFileName ) )
            {
                $readmeTemplate = @"
## $($baseName)

### Description
TODO: Add a description

### Functionality
"@
                $readeTemplate | Out-File -FilePath $readmeFileName -Force -Encoding ascii

                #Add README to Defaults
                Set-PspPowershellProjectDefaults -ModuleREADMEFile $readmeFileName
                Add-PspSourceToPowershellProject -ProjectFile $ProjectFileToCreate -SourceFile $readmeFileName
                Set-PspPowershellProjectDefaults -IncludeInBuild Yes
            } else {
                Write-Warning "A README.md file already exists in the Deploy directory."
            }
        } #CreateNewProjectDetails is true
    }
}