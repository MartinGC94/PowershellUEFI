#Requires -Version 5.1

[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
param
(
    [Parameter(Mandatory)]
    [Alias("ModuleVersion")]
    [version]$Version,

    [string]$Destination = "$PSScriptRoot\Releases"
)

function Get-FunctionAlias ([string]$FunctionDefinition)
{
    $ReturnedTokens = $null
    $ReturnedErrors = $null
    $SyntaxTree = [System.Management.Automation.Language.Parser]::ParseInput($FunctionDefinition, [ref]$ReturnedTokens, [ref]$ReturnedErrors)

    $SyntaxTree.FindAll(
        {
            param($AstObject)

            $AstObject -is [System.Management.Automation.Language.AttributeAst] -and
            $AstObject.Parent -is [System.Management.Automation.Language.ParamBlockAst] -and
            $AstObject.TypeName.FullName -eq "Alias"
        },
        $true
    ).PositionalArguments.Value | Sort-Object -Unique
}



#region import module data
$ModuleData = Import-PowerShellDataFile -Path "$PSScriptRoot\ModuleData.psd1"

$ModuleName     = $ModuleData["ModuleName"]
$ModuleManifest = $ModuleData["ManifestData"]
$RootModuleName = $ModuleManifest["RootModule"]

$ModuleManifest.Add("ReleaseNotes", (Get-Content -Path "$PSScriptRoot\Release Notes.txt" -Raw -Encoding Default))
$ModuleManifest.Add("ModuleVersion", $Version)
#endregion



#region build content for .psm1 file and find function aliases
$PublicFunctions  = Get-ChildItem -Path "$PSScriptRoot\Functions\Public"  -Recurse -Filter "*.ps1" -File
$PrivateFunctions = Get-ChildItem -Path "$PSScriptRoot\Functions\Private" -Recurse -Filter "*.ps1" -File
$Enums            = Get-ChildItem -Path "$PSScriptRoot\Enums"   -Recurse -Filter "*.ps1" -File
$Classes          = Get-ChildItem -Path "$PSScriptRoot\Classes" -Recurse -Filter "*.ps1" -File
$PSMBuilder = [System.Text.StringBuilder]::new()
$PublicAliasList = [System.Collections.Generic.List[string]]::new()

[void]($PSMBuilder.AppendLine("#region Enums"))
foreach ($File in $Enums)
{
    $Content = Get-Content -LiteralPath $File.FullName -Raw -Encoding Default
    [void]($PSMBuilder.AppendLine($Content))
}
[void]($PSMBuilder.AppendLine("#endregion"))

[void]($PSMBuilder.AppendLine("#region Classes"))
foreach ($File in $Classes)
{
    $Content = Get-Content -LiteralPath $File.FullName -Raw -Encoding Default
    [void]($PSMBuilder.AppendLine($Content))
}
[void]($PSMBuilder.AppendLine("#endregion"))


[void]($PSMBuilder.AppendLine("#region Public functions"))
foreach ($File in $PublicFunctions)
{
    $Content = Get-Content -LiteralPath $File.FullName -Raw -Encoding Default
    [void]($PSMBuilder.AppendLine($Content))

    Get-FunctionAlias -FunctionDefinition $Content | ForEach-Object -Process {
        $PublicAliasList.Add($_)
    }
}
[void]($PSMBuilder.AppendLine("#endregion"))


[void]($PSMBuilder.AppendLine("#region Private functions"))
foreach ($File in $PrivateFunctions)
{
    $Content = Get-Content -LiteralPath $File.FullName -Raw -Encoding Default
    [void]($PSMBuilder.AppendLine($Content))
}
[void]($PSMBuilder.AppendLine("#endregion"))
#endregion



#region Create destination folder and make sure it is empty
$DestinationDirectory = [System.IO.Path]::Combine($Destination, $ModuleName, $Version)
[void](New-Item -Path $DestinationDirectory -ItemType Directory -Force)

$ItemsToRemove = Get-ChildItem -Path $DestinationDirectory
if ($ItemsToRemove -and $PSCmdlet.ShouldProcess($DestinationDirectory, "Deleting $($ItemsToRemove.Count) item(s)"))
{
    Remove-Item -LiteralPath $ItemsToRemove.FullName -Recurse -Force
}
#endregion


#region Add all module content to $DestinationDirectory
Set-Content -Path "$DestinationDirectory\$RootModuleName" -Value $PSMBuilder.ToString().Trim() -Force
New-ModuleManifest @ModuleManifest -Path "$DestinationDirectory\$ModuleName.psd1" -FunctionsToExport $PublicFunctions.BaseName -AliasesToExport $PublicAliasList

$FilesInModule = Get-ChildItem -Path $DestinationDirectory -Recurse -File -Force
Update-ModuleManifest -Path "$DestinationDirectory\$ModuleName.psd1" -FileList $FilesInModule.FullName.Replace("$DestinationDirectory\", '')
#endregion