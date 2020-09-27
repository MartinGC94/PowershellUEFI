function Set-UefiVariable
{
    [CmdletBinding()]

    Param
    (
        [Parameter(Mandatory)]
        [string]
        $VariableName,

        [Parameter(Mandatory)]
        [AllowNull()]
        [byte[]]
        $Value,

        [Parameter()]
        [string]
        $NameSpace='{8BE4DF61-93CA-11D2-AA0D-00E098032B8C}'
    )
    begin
    {
        $PrivWasEnabledBefore=SetSeSystemEnvironmentPrivilegeState -Enable $true
    }
    Process
    {
        if ($null -eq $Value)
        {
            $Value=0
            $Size=0
        }
        else
        {
            $Size=$Value.Length
        }
        
        $ReturnBuffer=[PowershellUefiNative]::SetFirmwareEnvironmentVariable($VariableName,$Namespace,$Value,$Size)

        if ($ReturnBuffer -eq 0)
        {
            [void](SetSeSystemEnvironmentPrivilegeState -Enable $PrivWasEnabledBefore)
            [System.Runtime.InteropServices.Marshal]::ThrowExceptionForHR([System.Runtime.InteropServices.Marshal]::GetHRForLastWin32Error())
        }
    }
    end
    {
        [void](SetSeSystemEnvironmentPrivilegeState -Enable $PrivWasEnabledBefore)
    }
}