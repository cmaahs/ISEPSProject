Function Get-PspPowershellProjectFilesNotIncludedInProject
{
<#
.Synopsis
    Display the files in the PROJECT directory that haven't been added as a source.   
.DESCRIPTION
   
.EXAMPLE
    
#>
    $projectFiles = @{}

    $psFiles = Get-ChildItem -Filter *.ps1 -Recurse
    $pspKeys = Get-PspPowershellProjectKeys | Sort-Object
    foreach ( $p in $pspKeys )
    {
        $f = Get-ChildItem $p
        $projectFiles.Add($f.FullName,$p)
    }
    
    $missingItems = @()
    foreach ( $p in $psFiles ) 
    { 
        if ( -not ( $p.FullName.Contains("\bin\") ) )
        {
            #Write-Verbose $p.FullName -Verbose
            #Write-Verbose $projectFiles.ContainsKey($p.FullName) -Verbose
            if ( -Not ( $projectFiles.ContainsKey($p.FullName) ) ) 
            {
                $item = "" | Select-Object Name,Directory
                $item.Name = $p.Name
                $item.Directory = $p.Directory
                #Write-Output "Missing: $($p.FullName)" 
                $missingItems += $item
            }
        }
    }
    Write-Output $missingItems
}

