#requires -Version 5.1
# Installs the /prompt Clawpilot skill from lowendahl/csu-prompts.
# Idempotent: rerun any time to refresh the skill body.

$ErrorActionPreference = 'Stop'

$repo    = 'lowendahl/csu-prompts'
$branch  = 'main'
$rawBase = "https://raw.githubusercontent.com/$repo/$branch"
$skillDir = Join-Path $env:USERPROFILE '.copilot\m-skills\prompt'
$skillMd  = Join-Path $skillDir 'SKILL.md'

if (-not (Test-Path $skillDir)) {
    New-Item -ItemType Directory -Path $skillDir -Force | Out-Null
}

Write-Host "Fetching SKILL.md from $rawBase/skill/SKILL.md ..." -ForegroundColor Cyan
$skill = Invoke-WebRequest -Uri "$rawBase/skill/SKILL.md" -UseBasicParsing
[System.IO.File]::WriteAllText($skillMd, $skill.Content)

Write-Host ""
Write-Host "✅ /prompt installed at $skillMd" -ForegroundColor Green
Write-Host ""
Write-Host "Try it in Clawpilot:" -ForegroundColor Yellow
Write-Host "    /prompt list"
Write-Host "    /prompt scope"
Write-Host ""
Write-Host "To update later, just rerun this same one-liner."
