# renodx_config

This repository contains a PowerShell script that updates the `FPSLimit` setting inside RenoDX-managed `ReShade.ini` files.

## Files
- `config.json` – Machine-specific array of absolute `ReShade.ini` paths (git-ignored).
- `config.example.json` – Template to copy when creating your own `config.json`.
- `reno_fps_update.ps1` – Script that iterates over the configured paths and replaces the `FPSLimit` line.

## Usage
1. Copy `config.example.json` to `config.json`.
2. Replace the placeholder entry with full paths to the `ReShade.ini` files you want to manage.
3. Run the script from PowerShell. The value passed to `-FPSLimit` becomes the fallback FPS cap for every file.

### Example Commands
```powershell
# Update all default config paths to an FPS limit of 60
pwsh ./reno_fps_update.ps1 -FPSLimit 60

# Update all default config paths to an FPS limit of 90, -FPSLimit is not required if its the first and only argument
pwsh ./reno_fps_update.ps1 90

# Target an alternate manifest while testing
pwsh ./reno_fps_update.ps1 -FPSLimit 75 -ConfigPath "E:/Configs/test.json"
```

## Apollo Environment Variables
- `APOLLO_CLIENT_FPS` overrides the `-FPSLimit` parameter when set and when `APOLLO_APP_STATUS` is anything other than `TERMINATING`.
- Values are parsed with invariant culture; invalid numbers fall back to the explicit `-FPSLimit` you pass.
- Unset or empty variables leave the script behavior unchanged.

## Notes
- Paths must be absolute and use Windows-style separators, e.g. `E:/Games/Hades II/ReShade.ini`.
- Keep `config.json` out of source control if it contains machine-specific paths.
- If a listed file cannot be found or lacks the `FPSLimit` key, the script logs a warning and continues.
