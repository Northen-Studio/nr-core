param([string]$Destination)

$ErrorActionPreference = 'Stop'
$resourceRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$manifest = Get-Content -LiteralPath (Join-Path $resourceRoot 'fxmanifest.lua') -Raw
$version = [regex]::Match($manifest, "(?m)^version '([^']+)'$").Groups[1].Value
if (-not $version) { throw 'Missing manifest version.' }
if (-not $Destination) {
    $Destination = Join-Path (Split-Path $resourceRoot -Parent) "nr-core-$version.zip"
}
$Destination = [IO.Path]::GetFullPath($Destination)
Add-Type -AssemblyName System.IO.Compression
$stream = [IO.File]::Open($Destination, [IO.FileMode]::CreateNew)
try {
    $archive = [IO.Compression.ZipArchive]::new($stream, [IO.Compression.ZipArchiveMode]::Create, $true)
    try {
        $files = Get-ChildItem -LiteralPath $resourceRoot -Recurse -File -Force
        foreach ($file in $files) {
            $relative = $file.FullName.Substring($resourceRoot.Length + 1).Replace('\', '/')
            if ($relative -match '(^|/)(\.git|\.test-tools|node_modules|\.idea|\.vscode)(/|$)' -or
                $relative -match '\.(zip|log)$' -or $file.FullName -eq $Destination) { continue }
            $entry = $archive.CreateEntry("nr-core/$relative", [IO.Compression.CompressionLevel]::Optimal)
            $inputStream = [IO.File]::OpenRead($file.FullName)
            $outputStream = $entry.Open()
            try { $inputStream.CopyTo($outputStream) }
            finally { $outputStream.Dispose(); $inputStream.Dispose() }
        }
    } finally { $archive.Dispose() }
} finally { $stream.Dispose() }
Write-Output "Created $Destination"
