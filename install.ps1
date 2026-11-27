# filemem-dsh public installer (Windows): fetch the current platform tarball
# from the dist repo's releases branch, verify the checksum, extract. Then
# follow the README's pnpm step in your DSH profile directory.
# Usage: .\install.ps1 [-Version 0.1.0]
param([string]$Version)
$ErrorActionPreference = 'Stop'
$base = 'https://raw.githubusercontent.com/stennyc/filemem-dsh-dist/releases'
if (-not $Version) {
  $Version = (Invoke-WebRequest "$base/SHA256SUMS" -UseBasicParsing).Content -split "\r?\n" | ForEach-Object { if ($_ -match 'filemem-dsh-([0-9.]+)-\w+-\w+\.tar\.gz') { $matches[1] } } | Sort-Object { [version]$_ } -Unique | Select-Object -Last 1
}
if (-not $Version) { Write-Error 'no version found on the releases branch'; exit 1 }
$arch = if ((Get-WmiObject Win32_Processor).Architecture -eq 'ARM64') { 'arm64' } else { 'x64' }
$F = "filemem-dsh-$Version-windows-$arch.tar.gz"
Invoke-WebRequest "$base/$F" -OutFile $F
$sums = (Invoke-WebRequest "$base/SHA256SUMS" -UseBasicParsing).Content
$want = ($sums -split "\r?\n" | Where-Object { $_ -match ('\s' + [regex]::Escape($F) + '$') }) -split '\s+' | Where-Object { $_ -match '^[0-9a-f]{64}$' } | Select-Object -First 1
$got = (Get-FileHash $F -Algorithm SHA256).Hash.ToLower()
if ($want -ne $got) { Write-Error "CHECKSUM MISMATCH for $F"; exit 1 }
Write-Host "$F : checksum ok"
& tar -xzf $F
cd (Join-Path (Get-Location) "filemem-dsh-$Version")
Remove-Item $F
Write-Host ''
Write-Host "extracted: $(Get-Location)"
Write-Host "next: in your DSH profile dir run:  pnpm add $(Get-Location)   (see README.md)"
