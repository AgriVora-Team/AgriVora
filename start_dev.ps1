#!/usr/bin/env pwsh
# AgriVora Dev Launcher
# Runs adb reverse (so backend is reachable from physical Android device)
# then starts the Flutter app.
# Usage: .\start_dev.ps1

$ADB = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"

Write-Host ""
Write-Host "=================================" -ForegroundColor Cyan
Write-Host "  AgriVora Dev Launcher" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""

# Check adb exists
if (-not (Test-Path $ADB)) {
    Write-Host "[ERROR] adb.exe not found at: $ADB" -ForegroundColor Red
    Write-Host "Make sure Android SDK platform-tools are installed." -ForegroundColor Yellow
    exit 1
}

# Show connected devices
Write-Host "[1/3] Checking connected devices..." -ForegroundColor Yellow
& $ADB devices

Write-Host ""
Write-Host "[2/3] Setting up adb reverse (port 8000)..." -ForegroundColor Yellow
$result = & $ADB reverse tcp:8000 tcp:8000 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "      adb reverse tcp:8000 tcp:8000 -> OK ($result)" -ForegroundColor Green
} else {
    Write-Host "[WARN] adb reverse failed (device may not be connected via USB)" -ForegroundColor Yellow
    Write-Host "       The app will fall back to Wi-Fi IP 172.20.10.4" -ForegroundColor Yellow
}


# ─── Start Backend ──────────────────────────────────────────────────────────
Write-Host ""
Write-Host "To start the backend, run in a SEPARATE terminal:" -ForegroundColor Cyan
Write-Host "  cd backend" -ForegroundColor White
Write-Host "  .\.venv\Scripts\python.exe -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000" -ForegroundColor Green
Write-Host ""
Write-Host "  --host 0.0.0.0  makes it reachable over WiFi (172.20.10.4) AND via adb reverse (127.0.0.1)" -ForegroundColor Yellow
Write-Host ""

# ─── Start Flutter App ──────────────────────────────────────────────────────
Write-Host "[3/3] Starting Flutter app..." -ForegroundColor Yellow
Write-Host ""

Set-Location "$PSScriptRoot\frontend"
flutter run
