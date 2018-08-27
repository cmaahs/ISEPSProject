$commonParameters = @{
    "ProjectFile" = @'
        # Specify the project file to open.  Default project can be specified via the Set-PspPowershellProjectDefaults command.
        [Parameter(Mandatory=$false,
                   Position=~x~)]
        [Alias('File','FilePath')]
        #[ValidateScript({ Test-Path $_ })]
        [string]       
        $ProjectFile = (Get-PspPowershellProjectDefaultProjectFile)
'@
    ;
    "SourceFile" = @'
        # Specify the source file name to add to the project.
        [Parameter(Mandatory=$false,
                   Position=~x~)]
        [Alias('Source','SourcePath','FilePath','FileName')]
        [ValidateScript({ Test-Path $_ })]
        [string[]]
        $SourceFile
'@
    ;
    "PARAMCOMMA" = @'
        ,
'@
    ;
    "SourceFileWithPipeline" = @'
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
'@
}

$commonParameters | Export-Clixml -Path ".\.psproj\commonParameters.clixml" -Force