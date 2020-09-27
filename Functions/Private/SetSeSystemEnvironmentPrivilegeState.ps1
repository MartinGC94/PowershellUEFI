function SetSeSystemEnvironmentPrivilegeState ([bool]$Enable)
{
    $PrivWasEnabledBefore=$null
    $ReturnCode=[PowershellUefiNative]::RtlAdjustPrivilege(22, $true, $false, [ref]$PrivWasEnabledBefore)
    if ($ReturnCode -ne 0)
    {
        throw "Unable to enable SeSystemEnvironmentPrivilege"
    }
    $PrivWasEnabledBefore
}