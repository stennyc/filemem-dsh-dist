# filemem-dsh public installer (Windows): download the matching platform
# tarball from the latest release, verify the checksum, extract. Then follow
# the README's pnpm step in your DSH profile directory.
$ErrorActionPreference = 'Stop'
$api = 'https://api.github.com'
$repo = 'stennyc/filemem-dsh-dist'
$latest = Invoke-RestMethod "$api/repos/$repo/releases/latest"
$ver = $latest.tag_name -replace '^v', ''
$arch = if ((Get-WmiObject Win32_Processor).Architecture -eq 'ARM64') { 'arm64' } else { 'x64' }
$F = "filemem-dsh-$ver-windows-$arch.tar.gz"
Invoke-WebRequest "$api/repos/$repo/releases/latest/download/$F" -OutFile $F
Invoke-WebRequest "$api/repos/$repo/releases/latest/download/SHA256SUMS" -OutFile 'SHA256SUMS.txt'
$want = (Select-String -Path 'SHA256SUMS.txt' -Pattern ("\s" + [regex]::Escape($F) + '$') | ForEach-Object { ($_.Line -split '\s+') | Where-Object { $_ } | Select-Object -First 1 })
$got = (Get-FileHash $F -Algorithm SHA256).Hash.ToLower()
if ($want -ne $got) { Write-Error "CHECKSUM MISMATCH for $F"; exit 1 }
Write-Host "$F : checksum ok"
& tar -xzf $F
cd (Join-Path (Get-Location) "filemem-dsh-$ver")
Remove-Item $F, 'SHA256SUMS.txt'
Write-Host ''
Write-Host "extracted: $(Get-Location)"
Write-Host "next: in your DSH profile dir run:  pnpm add $(Get-Location)   (see README.md)"
