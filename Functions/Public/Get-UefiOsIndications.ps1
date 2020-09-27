function Get-UefiOsIndications
{
    [Alias("Get-OsIndications")]
    [CmdletBinding()]

    Param
    (
    )
    Process
    {
        $SupportedFlags=[UefiOsIndications](Get-UefiVariable -VariableName OsIndicationsSupported)[0]
        $ActiveFlags   =[UefiOsIndications](Get-UefiVariable -VariableName OsIndications)[0]
        
        foreach ($Flag in [UefiOsIndications]::GetValues([UefiOsIndications]))
        {
            [pscustomobject]@{
                Flag        = $Flag
                IsSupported = $SupportedFlags.HasFlag($Flag)
                IsActive    = $ActiveFlags.HasFlag($Flag)
            }
        }
    }
}