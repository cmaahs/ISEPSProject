function Save-PspSourceToBuildFolder
{
<#
.Synopsis
   
.DESCRIPTION
   
.EXAMPLE

#>
    [CmdletBinding()]
    Param
    (        
        # File Item from .psproj file.
        [Parameter(Mandatory=$true,
                   Position=0)]
        [string]
        $ProjectFileItem
        ,
        # Build file contents
        [Parameter(Mandatory=$true,
                   Position=1)]
        [string]
        $BuildContents
    )

    Begin
    {  
        $resultItem = "" | Select-Object BuildPath,WrittenOK  
        if ( -not ( Test-Path "bin" ) )
        {
            New-Item -Path "./" -Name "bin" -ItemType Directory
        }    
        $resultItem.writtenOK = $false
        $fileTargetDir = $ProjectFileItem.Split("\")[0]
        $fileTarget = "bin\$($ProjectFileItem)"
        $resultItem.BuildPath = $fileTargetDir
        if ( -not ( Test-Path "bin\$($fileTargetDir)" ) )
        {
            New-Item -Path "bin" -Name $fileTargetDir -ItemType Directory
        }

        $BuildContents | Out-File -FilePath $fileTarget -Force -Encoding ascii

        if ( Test-Path $fileTarget )
        {
            $resultItem.writtenOK = $true
        }
    }
    Process
    {
    }
    End
    {
        Write-Output $resultItem
    }
}
