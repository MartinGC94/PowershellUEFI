class UefiBootOption
{
    [string] $Name

    [string] $Description

    [bool] $BootNext

    [bool] $BootCurrent

    hidden [byte[]] $UefiVarData
}