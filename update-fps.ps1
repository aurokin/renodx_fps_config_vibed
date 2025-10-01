param(
    [Parameter(Mandatory = $true)][int]$FPSLimit,
    [string]$ConfigPath
)

# Resolve the config path relative to the script location when not provided.
if (-not $ConfigPath) {
    $scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
    $ConfigPath = Join-Path -Path $scriptRoot -ChildPath 'config.json'
}

if (-not (Test-Path -LiteralPath $ConfigPath)) {
    Write-Error "Config file not found: $ConfigPath"
    exit 1
}

try {
    $configJson = Get-Content -LiteralPath $ConfigPath -Raw
    $filePaths = $configJson | ConvertFrom-Json
} catch {
    Write-Error "Failed to parse JSON from $ConfigPath: $_"
    exit 1
}

if (-not ($filePaths -is [System.Collections.IEnumerable])) {
    Write-Error "Config JSON must be an array of file paths."
    exit 1
}

$replacement = "FPSLimit=$FPSLimit"

foreach ($filePath in $filePaths) {
    if (-not [string]::IsNullOrWhiteSpace($filePath)) {
        if (Test-Path -LiteralPath $filePath) {
            try {
                $originalLines = Get-Content -LiteralPath $filePath
            } catch {
                Write-Warning "Failed to read $filePath: $_"
                continue
            }

            $found = $false
            $updatedLines = foreach ($line in $originalLines) {
                if ($line -match '^\s*FPSLimit=') {
                    $found = $true
                    $replacement
                } else {
                    $line
                }
            }

            if ($found) {
                try {
                    Set-Content -LiteralPath $filePath -Value $updatedLines -Encoding utf8
                    Write-Host "Updated FPSLimit in $filePath"
                } catch {
                    Write-Warning "Failed to write to $filePath: $_"
                }
            } else {
                Write-Host "No FPSLimit line found in $filePath"
            }
        } else {
            Write-Warning "File does not exist: $filePath"
        }
    }
}
