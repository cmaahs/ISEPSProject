$ISE_PSProj = @(Get-ChildItem -Path $PSScriptRoot\bin\ISE_PSProj\*.ps1 -ErrorAction SilentlyContinue)
$ISE_PSProj_Backup = @(Get-ChildItem -Path $PSScriptRoot\bin\ISE_PSProj_Backup\*.ps1 -ErrorAction SilentlyContinue)
$Support_Functions = @(Get-ChildItem -Path $PSScriptRoot\bin\Support_Functions\*.ps1 -ErrorAction SilentlyContinue)
    Foreach($import in @($ISE_PSProj + $ISE_PSProj_Backup + $Support_Functions))
    {
        Try
        {
            . $import.fullname
        }
        Catch
        {
            Write-Error -Message "Failed to import function $($import.fullname): $_"
        }
    }
