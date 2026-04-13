# Claw Code - Windows Zero-Dependency Installer
#
# This script downloads the pre-built 'claw.exe' for your system
# and installs it. No Rust, Visual Studio, or build tools required.
#

$ErrorActionPreference = "Stop"

$REPO_URL = "https://github.com/ultraworkers/claw-code"

Write-Host "Detecting Architecture..." -ForegroundColor Cyan

$ARCH = $env:PROCESSOR_ARCHITECTURE
switch ($ARCH) {
    "AMD64" { $TARGET_ARCH = "x64" }
    "ARM64" { $TARGET_ARCH = "arm64" }
    default { throw "Unsupported architecture: $ARCH" }
}

$ASSET_NAME = "claw-windows-$TARGET_ARCH.exe"
$INSTALL_DIR = Join-Path $HOME ".claw\bin"

Write-Host "Platform: Windows ($TARGET_ARCH)" -ForegroundColor White

Write-Host "Downloading latest binary: $LATEST_RELEASE_URL" -ForegroundColor Cyan

if (-not (Test-Path $INSTALL_DIR)) {
    New-Item -ItemType Directory -Path $INSTALL_DIR -Force
}

$CLAW_PATH = Join-Path $INSTALL_DIR "claw.exe"

try {
    Invoke-WebRequest -Uri $LATEST_RELEASE_URL -OutFile $CLAW_PATH -UseBasicParsing
} catch {
    Write-Error "Download failed. The release might not be published yet."
}

Write-Host "Claw Code installed to: $CLAW_PATH" -ForegroundColor Green

# ---------------------------------------------------------------------------
# Update PATH
# ---------------------------------------------------------------------------

Write-Host "Updating PATH..." -ForegroundColor Cyan
$UserPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($UserPath -notlike "*$INSTALL_DIR*") {
    $NewPath = "$UserPath;$INSTALL_DIR"
    [Environment]::SetEnvironmentVariable("Path", $NewPath, "User")
    $env:Path = "$env:Path;$INSTALL_DIR"
    Write-Host "PATH updated permanently for current user." -ForegroundColor Green
} else {
    Write-Host "PATH already contains $INSTALL_DIR." -ForegroundColor White
}

Write-Host "`nClaw Code installed successfully!" -ForegroundColor Green
Write-Host "Try it out (re-open terminal if needed):" -ForegroundColor White
Write-Host "  claw doctor" -ForegroundColor Gray
