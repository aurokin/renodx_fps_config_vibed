# Repository Guidelines

## Project Structure & Module Organization
- `reno_fps_update.ps1` holds the FPS patch logic. Treat it as the single source of truth for manipulating ReShade configs.
- `config.json` is machine-specific and git-ignored; it must contain a JSON array of absolute `ReShade.ini` paths.
- `config.example.json` provides the schema to copy when onboarding a new machine.
- `README.md` summarizes usage. Update it whenever you add new behaviors or flags.

## Build, Test, and Development Commands
- `pwsh ./reno_fps_update.ps1 -FPSLimit 60` runs the updater against the default `config.json` in this directory.
- `pwsh ./reno_fps_update.ps1 -FPSLimit 60 -ConfigPath ./configs/dev.json` targets an alternate manifest when validating changes.
- Use `pwsh -NoProfile` during testing to avoid profile side-effects.

## Coding Style & Naming Conventions
- PowerShell: two-space indentation, one statement per line, and PascalCase for function/parameter names (`$FPSLimit`, `$ConfigPath`).
- JSON: arrays of quoted Windows-style paths (`"E:/Games/.../ReShade.ini"`); no trailing commas; final newline required.
- Prefer descriptive names for new config manifests (`configs/<purpose>.json`) and keep scripts in the repo root unless a module split is justified.

## Testing Guidelines
- Exercise the script with a disposable copy of `ReShade.ini`. Validate both the success path and the warning paths (missing file, missing `FPSLimit`).
- When possible, capture `pwsh` output using `-Verbose` or `-WhatIf` to document behavioral changes in your PR.
- Add automated checks only if they can run cross-platform in CI; document any manual steps in the PR description.

## Commit & Pull Request Guidelines
- Write commits in the imperative mood (`Add`, `Fix`, `Document`) and keep them scoped to a single concern.
- PRs should link to related issues, summarize behavior changes, and include before/after snippets for config mutations.
- Mention required follow-up (e.g., regenerating `config.json`) so reviewers know when post-merge actions are needed.

## Configuration Tips
- Never commit real user paths. Ship placeholders and document how to populate them.
- If you introduce new environment variables (e.g., `APOLLO_CLIENT_FPS`), explain defaults and priority ordering in both the script and README.
