[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
param(
  [Parameter(Mandatory = $true, Position = 0)]
  [double]$FPSLimit,

  [Parameter(Mandatory = $false, Position = 1)]
  [string]$ConfigPath
)

try {
  if (-not $PSBoundParameters.ContainsKey('ConfigPath') -or [string]::IsNullOrWhiteSpace($ConfigPath)) {
    # Resolve default config next to the script location, not the current directory
    $scriptDir = if ($PSScriptRoot) {
      $PSScriptRoot
    } elseif ($PSCommandPath) {
      Split-Path -Parent $PSCommandPath
    } else {
      Split-Path -Parent $MyInvocation.MyCommand.Path
    }
    $ConfigPath = Join-Path -Path $scriptDir -ChildPath 'config.json'
  }
  if (-not (Test-Path -Path $ConfigPath)) {
    throw "Config file not found: $ConfigPath"
    }
} catch {
    Write-Error "Can't find config"
    exit 1
}

$jsonRaw = Get-Content -Path $ConfigPath -Raw
$filePaths = $jsonRaw | ConvertFrom-Json

if (-not ($filePaths -is [System.Collections.IEnumerable])) {
    Write-Error "Config JSON must be an array of file paths."
    exit 1
}

$culture = [System.Globalization.CultureInfo]::InvariantCulture
$apolloFPS = $env:APOLLO_CLIENT_FPS
$apolloStatus = $env:APOLLO_APP_STATUS
$effectiveFPSLimit = [double]$FPSLimit

if ($null -ne $apolloFPS -and $apolloStatus -ne 'TERMINATING') {
    try {
        $effectiveFPSLimit = [System.Convert]::ToDouble($apolloFPS, $culture)
    } catch {
        Write-Warning "apolloFPS value '$apolloFPS' is not a valid number. Using provided FPSLimit instead."
        $effectiveFPSLimit = [double]$FPSLimit
    }
}

$reno_replacement = 'FPSLimit=' + $effectiveFPSLimit.ToString('0.########', $culture)
$dc_replacement = 'fps_limit=' + $effectiveFPSLimit.ToString('0.########', $culture)

foreach ($filePath in $filePaths) {
    if (-not [string]::IsNullOrWhiteSpace($filePath)) {
        if (Test-Path -LiteralPath $filePath) {
            try {
                $originalLines = Get-Content -LiteralPath $filePath
            } catch {
                Write-Warning "Failed to read $filePath"
                continue
            }

            $found = $false
            $updatedLines = foreach ($line in $originalLines) {
                if ($line -match '^\s*FPSLimit=') {
                    $found = $true
                    $reno_replacement
                } elseif ($line -match '^\s*fps_limit=') {
                    $found = $true
                    $dc_replacement
                } else {
                    $line
                }
            }

            if ($found) {
                try {
                    Set-Content -LiteralPath $filePath -Value $updatedLines -Encoding utf8
                    Write-Host "Updated FPSLimit in $filePath"
                } catch {
                    Write-Warning "Failed to write to $filePath"
                }
            } else {
                Write-Host "No FPSLimit line found in $filePath"
            }
        } else {
            Write-Warning "File does not exist: $filePath"
        }
    }
}
