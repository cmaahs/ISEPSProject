$Build_Management = @(Get-ChildItem -Path $PSScriptRoot\bin\Build_Management\*.ps1 -ErrorAction SilentlyContinue)
$Completion_Stops = @(Get-ChildItem -Path $PSScriptRoot\bin\Completion_Stops\*.ps1 -ErrorAction SilentlyContinue)
$ISE_PSProj = @(Get-ChildItem -Path $PSScriptRoot\bin\ISE_PSProj\*.ps1 -ErrorAction SilentlyContinue)
$ISE_PSProj_Backup = @(Get-ChildItem -Path $PSScriptRoot\bin\ISE_PSProj_Backup\*.ps1 -ErrorAction SilentlyContinue)
$PSProj_Defaults = @(Get-ChildItem -Path $PSScriptRoot\bin\PSProj_Defaults\*.ps1 -ErrorAction SilentlyContinue)
$PSProj_Management = @(Get-ChildItem -Path $PSScriptRoot\bin\PSProj_Management\*.ps1 -ErrorAction SilentlyContinue)
$Support_Functions = @(Get-ChildItem -Path $PSScriptRoot\bin\Support_Functions\*.ps1 -ErrorAction SilentlyContinue)
    Foreach($import in @($Build_Management + $Completion_Stops + $ISE_PSProj + $ISE_PSProj_Backup + $PSProj_Defaults + $PSProj_Management + $Support_Functions))
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

Update-FormatData -AppendPath $PSScriptRoot\bin\PSProj_Management\PowershellProject.Format.ps1xml

