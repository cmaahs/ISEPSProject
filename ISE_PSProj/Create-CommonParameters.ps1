$commonParameters = @{
    "ProjectFile" = @'
        # Specify the project file to open.  Default project can be specified via the Set-PowershellProjectDefaults command.
        [Parameter(Mandatory=$false,
                   Position=~x~)]
        [Alias('File','FilePath')]
        #[ValidateScript({ Test-Path $_ })]
        [string]       
        $ProjectFile = (Get-PowershellProjectDefaultProjectFile)
'@
    ;
    "SourceFile" = @'
        # Specify the source file name to add to the project.
        [Parameter(Mandatory=$true,
                   Position=~x~)]
        [Alias('Source','SourcePath')]
        [ValidateScript({ Test-Path $_ })]
        [string[]]
        $SourceFile
'@
}

$commonParameters | Export-Clixml -Path ".\.psproj\commonParameters.clixml" -Force