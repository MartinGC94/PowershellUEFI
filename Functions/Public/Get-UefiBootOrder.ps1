function Get-UefiBootOrder
{
    [CmdletBinding()]
    [OutputType([UefiBootOption])]

    Param
    (
    )
    Process
    {
        $BootNextData    = Get-UefiVariable -VariableName BootNext -ErrorAction SilentlyContinue
        $BootCurrentData = Get-UefiVariable -VariableName BootCurrent

        [array]::Reverse($BootNextData)
        [array]::Reverse($BootCurrentData)

        $BootNext    = $BootNextData -join ''
        $BootCurrent = $BootCurrentData -join ''


        $VariableData = Get-UefiVariable -VariableName BootOrder
        
        $BootOrder=for ($i = 1; $i -le $VariableData.Length; $i+=2)
        {
            $BootId="$($VariableData[$i])$($VariableData[$i-1])"

            [UefiBootOption]@{
                Name        = "Boot$($BootId.PadLeft(4,'0'))"
                Description = ""
                BootNext    = $BootId -eq $BootNext
                BootCurrent = $BootId -eq $BootCurrent
                UefiVarData = $VariableData[($i-1),$i]
            }
        }

        foreach ($Item in $BootOrder)
        {
            $VariableData=Get-UefiVariable -VariableName $Item.Name
        
            $DescriptionBuilder=[System.Text.StringBuilder]::new()
            $TerminatingChar=[char]0
            for ($i = 6; $i -le $VariableData.Length; $i+=2)
            {
                $CharToAdd=[char]($VariableData[$i])
                
                if ($CharToAdd -eq $TerminatingChar)
                {
                    break
                }
                else
                {
                    [void]($DescriptionBuilder.Append($CharToAdd))
                }
            }
            $Item.Description=$DescriptionBuilder.ToString()
            $Item
        }
    }
}
