Function Get-PspControlDirectory
{
<#
.Synopsis
   This function will walk from the current $PWD path until it finds the .psproj directory and return that path.
.DESCRIPTION
   Used to feed other Powershell Project commands.

.EXAMPLE

#>
    [CmdletBinding()]
    Param
    (       
    )

    Begin
    {        
    }
    Process
    {     
    }
    End
    {
        $pwdParts = $PWD.ToString().Split("\")
        $x = 1
        for ( $x = 1; $x -le $pwdParts.Count; $x++ )
        {            
            $testPath = $pwdParts[0..($pwdParts.Count-$x)] -join "\"
            Write-Verbose "Testing $($testPath)"
            if ( Test-Path "$($testPath)\.psproj" )
            {
                Write-Output $testPath
                break
            }
        }
        
    }
}
