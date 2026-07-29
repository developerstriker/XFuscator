param(
    [Parameter(Mandatory = $true)]
    [string]$File
)

$repo = "https://github.com/developerstriker/XFuscator/archive/refs/heads/main.zip"

$temp = Join-Path $env:TEMP ("XFuscator_" + [guid]::NewGuid())
$zip = "$temp.zip"

New-Item -ItemType Directory -Force -Path $temp | Out-Null

Write-Host "Baixando XFuscator..."
Invoke-WebRequest $repo -OutFile $zip

Expand-Archive $zip -DestinationPath $temp

# Procura o XFuscator.lua em qualquer subpasta
$xfuscator = Get-ChildItem $temp -Recurse -Filter XFuscator.lua | Select-Object -First 1

if (-not $xfuscator) {
    throw "XFuscator.lua n�o encontrado."
}

Push-Location $xfuscator.Directory.FullName

lua $xfuscator.FullName $File

Pop-Location

$output = Join-Path $xfuscator.Directory.FullName (
    $name = [System.IO.Path]::GetFileNameWithoutExtension($File)
    $output = Join-Path $xf.Directory.FullName "$name [Obfuscated].lua"
)

if (Test-Path $output) {
    Copy-Item $output (Split-Path $File -Parent) -Force
    Write-Host "Conclu�do!"
}

Remove-Item $zip -Force -ErrorAction SilentlyContinue
Remove-Item $temp -Recurse -Force -ErrorAction SilentlyContinue