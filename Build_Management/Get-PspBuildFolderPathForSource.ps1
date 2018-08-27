function Get-PspBuildFolderPathForSource
{
<#
.Synopsis
   Returns the path to the Build folder location for a source item.
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
    )

    Begin
    {  
        $itemPath = ""       
        if ( Test-Path "bin" )
        {
            $fileTargetDir = $ProjectFileItem.Split("\")[0]
            $fileTarget = "bin\$($ProjectFileItem)"
            if ( Test-Path "bin\$($fileTargetDir)" ) 
            {
                if ( Test-Path $fileTarget )
                {
                    $itemPath = $fileTarget
                }
            }

        }    

    }
    Process
    {
    }
    End
    {
        Write-Output $itemPath
    }
}
