$File = [System.IO.Path]::GetFullPath((Join-Path (Get-Location) $File))

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

$xfuscator = Get-ChildItem $temp -Recurse -Filter XFuscator.lua | Select-Object -First 1

if (-not $xfuscator) {
    throw "XFuscator.lua não encontrado."
}

# Caminho absoluto do arquivo de entrada
if (-not [System.IO.Path]::IsPathRooted($File)) {
    $File = Join-Path (Get-Location) $File
}

$File = [System.IO.Path]::GetFullPath($File)

# Usa o Lua 5.4 (último encontrado no PATH)
$lua = Join-Path $xfuscator.Directory.FullName "lua\lua.exe"

if (!(Test-Path $lua)) {
    throw "lua.exe não encontrado."
}

& $lua $xfuscator.FullName $File

Pop-Location

$name = [System.IO.Path]::GetFileNameWithoutExtension($File)
$dest = Split-Path $File -Parent

$output = Join-Path $xfuscator.Directory.FullName "$name [Obfuscated].lua"

if (Test-Path $output) {
    Copy-Item $output $dest -Force
    Write-Host "Concluído!"
} else {
    Write-Host "O arquivo obfuscado não foi gerado."
}

Remove-Item $zip -Force -ErrorAction SilentlyContinue
Remove-Item $temp -Recurse -Force -ErrorAction SilentlyContinue