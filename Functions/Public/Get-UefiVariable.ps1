function Get-UefiVariable
{
    [CmdletBinding()]
    [OutputType([byte[]])]

    Param
    (
        [Parameter(Mandatory)]
        [string]
        $VariableName,

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
        $BufferSize=0
        do
        {
            $BufferSize+=1KB
            $Result = [byte[]]::new($BufferSize)
            $Size   = $BufferSize

            $ReturnBuffer=[PowershellUefiNative]::GetFirmwareEnvironmentVariable($VariableName,$Namespace,$Result,$Size)
            $LastError=[System.Runtime.InteropServices.Marshal]::GetLastWin32Error()
            
            #Error code 122: ERROR_INSUFFICIENT_BUFFER
        }
        while ($ReturnBuffer -eq 0 -and $LastError -eq 122)

        if ($ReturnBuffer -eq 0)
        {
            [void](SetSeSystemEnvironmentPrivilegeState -Enable $PrivWasEnabledBefore)
            [System.Runtime.InteropServices.Marshal]::ThrowExceptionForHR([System.Runtime.InteropServices.Marshal]::GetHRForLastWin32Error())
        }
        [array]::Resize([ref]$Result,$ReturnBuffer)

        #Write-Output, prevent PS from converting the type to [Object[]]
        $PSCmdlet.WriteObject($Result,$false)
    }
    end
    {
        [void](SetSeSystemEnvironmentPrivilegeState -Enable $PrivWasEnabledBefore)
    }
}