function Set-UefiOsIndications
{
    [Alias("Set-OsIndications")]
    [CmdletBinding()]

    Param
    (
        [Parameter()]
        [UefiOsIndications]
        $FlagsToEnable,

        [Parameter()]
        [UefiOsIndications]
        $FlagsToDisable,

        [Parameter()]
        [Alias("ClearAll")]
        [switch]
        $ResetAll
    )

    Begin
    {
    }
    Process
    {
        $VarData=Get-UefiVariable -VariableName OsIndications

        $FlagsToSet=[UefiOsIndications]0
        if (!$ResetAll)
        {
            $FlagsToSet=[UefiOsIndications]$VarData[0]
        }


        foreach ($Flag in [UefiOsIndications]::GetValues([UefiOsIndications]))
        {
            if ($FlagsToEnable -and $FlagsToEnable.HasFlag($Flag) -and !$FlagsToSet.HasFlag($Flag))
            {
                $FlagsToSet+=$Flag
            }
            if ($FlagsToDisable -and $FlagsToDisable.HasFlag($Flag) -and $FlagsToSet.HasFlag($Flag))
            {
                $FlagsToSet-=$Flag
            }
        }
        if ($FlagsToSet.value__ -ne $VarData[0])
        {
            $VarData[0]=$FlagsToSet.value__
            Set-UefiVariable -VariableName OsIndications -Value $VarData
        }
    }
}