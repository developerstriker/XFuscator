param(
    [Parameter(Mandatory = $true)]
    [string]$Input
)

$repo = "https://github.com/SEU_USUARIO/XFuscator/archive/refs/heads/main.zip"

$temp = Join-Path $env:TEMP ("XFuscator_" + [guid]::NewGuid())
$zip = "$temp.zip"

New-Item -ItemType Directory -Force -Path $temp | Out-Null

Write-Host "Baixando XFuscator..."
Invoke-WebRequest $repo -OutFile $zip

Expand-Archive $zip -DestinationPath $temp

$root = Get-ChildItem $temp -Directory | Select-Object -First 1

Push-Location $root.FullName

lua XFuscator.lua $Input

Pop-Location

$output = Join-Path $root.FullName (
    (Split-Path $Input -LeafBase) + " [Obfuscated].lua"
)

if (Test-Path $output) {
    Copy-Item $output (Split-Path $Input)
    Write-Host "`nConcluído!"
}

Remove-Item $zip -Force
Remove-Item $temp -Recurse -Force