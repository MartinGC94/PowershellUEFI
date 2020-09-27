function Set-UefiBootOrder
{
    [CmdletBinding()]

    Param
    (
        [Parameter()]
        [Alias("BootOnce","OneTimeBoot")]
        [AllowNull()]
        [UefiBootOption]
        $BootNext,

        [Parameter()]
        [UefiBootOption[]]
        $BootOption
    )
    Process
    {
        switch ($PSBoundParameters.Keys)
        {
            'BootNext'
            {
                Set-UefiVariable -VariableName BootNext -Value $BootNext.UefiVarData
            }
            'BootOption'
            {
                Set-UefiVariable -VariableName BootOrder -Value $BootOption.UefiVarData
            }
        }
    }
}