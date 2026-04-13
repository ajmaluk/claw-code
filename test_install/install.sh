#!/usr/bin/env bash
# Claw Code - Zero-Dependency Installer
#
# This script downloads the pre-built 'claw' binary for your system
# and installs it. No Rust or build tools required.
#
# Usage:
#   curl -sSL https://raw.githubusercontent.com/ultraworkers/claw-code/main/install.sh | sh
#

set -euo pipefail

# ---------------------------------------------------------------------------
# Pretty printing
# ---------------------------------------------------------------------------

if [ -t 1 ] && command -v tput >/dev/null 2>&1 && [ "$(tput colors 2>/dev/null || echo 0)" -ge 8 ]; then
    COLOR_RESET="$(tput sgr0)"
    COLOR_BOLD="$(tput bold)"
    COLOR_RED="$(tput setaf 1)"
    COLOR_GREEN="$(tput setaf 2)"
    COLOR_CYAN="$(tput setaf 6)"
else
    COLOR_RESET=""
    COLOR_BOLD=""
    COLOR_RED=""
    COLOR_GREEN=""
    COLOR_CYAN=""
fi

info()  { printf '%s  ->%s %s\n' "${COLOR_CYAN}" "${COLOR_RESET}" "$1"; }
ok()    { printf '%s  ok%s %s\n' "${COLOR_GREEN}" "${COLOR_RESET}" "$1"; }
error() { printf '%s  error%s %s\n' "${COLOR_RED}" "${COLOR_RESET}" "$1" 1>&2; exit 1; }

# ---------------------------------------------------------------------------
# Detection
# ---------------------------------------------------------------------------

info "Detecting system..."

OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
ARCH="$(uname -m)"

case "${OS}" in
    linux)  PLATFORM="linux" ;;
    darwin) PLATFORM="macos" ;;
    *)      error "Unsupported OS: ${OS}. Feel free to build from source." ;;
esac

case "${ARCH}" in
    x86_64)  TARGET_ARCH="x64" ;;
    arm64|aarch64) TARGET_ARCH="arm64" ;;
    *)      error "Unsupported Architecture: ${ARCH}. Feel free to build from source." ;;
esac

ASSET_NAME="claw-${PLATFORM}-${TARGET_ARCH}"
REPO_URL="https://github.com/ultraworkers/claw-code"
# Use 'latest' for the tag, or a specific version if preferred
LATEST_RELEASE_URL="${REPO_URL}/releases/latest/download/${ASSET_NAME}"

info "Platform: ${PLATFORM} (${TARGET_ARCH})"
info "Downloading latest binary: ${LATEST_RELEASE_URL}"

# ---------------------------------------------------------------------------
# Download
# ---------------------------------------------------------------------------

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

CLAW_TMP="${TMP_DIR}/claw"

if command -v curl >/dev/null 2>&1; then
    curl -sSL -o "${CLAW_TMP}" "${LATEST_RELEASE_URL}" || error "Download failed. The release might not be published yet."
elif command -v wget >/dev/null 2>&1; then
    wget -q -O "${CLAW_TMP}" "${LATEST_RELEASE_URL}" || error "Download failed."
else
    error "Missing 'curl' or 'wget'. Please install one to continue."
fi

chmod +x "${CLAW_TMP}"

# ---------------------------------------------------------------------------
# Installation
# ---------------------------------------------------------------------------

INSTALL_DIR="/usr/local/bin"
if [ ! -w "${INSTALL_DIR}" ]; then
    # Fallback to user binary dir if /usr/local/bin is not writable
    INSTALL_DIR="${HOME}/.local/bin"
    mkdir -p "${INSTALL_DIR}"
fi

info "Installing to ${INSTALL_DIR}/claw..."

if [ -w "${INSTALL_DIR}" ]; then
    mv "${CLAW_TMP}" "${INSTALL_DIR}/claw"
else
    sudo mv "${CLAW_TMP}" "${INSTALL_DIR}/claw"
fi

ok "Claw Code installed successfully!"

# ---------------------------------------------------------------------------
# Next steps
# ---------------------------------------------------------------------------

case ":${PATH}:" in
    *:"${INSTALL_DIR}":*) ;;
    *)
        printf "\n%sManual Action Required:%s\n" "${COLOR_BOLD}" "${COLOR_RESET}"
        printf "Add ${INSTALL_DIR} to your PATH to run 'claw' from anywhere.\n"
        printf "Example (for ~/.bashrc or ~/.zshrc):\n"
        printf "  export PATH=\"\$PATH:${INSTALL_DIR}\"\n"
        ;;
esac

printf "\nTry it out:\n"
printf "  ${COLOR_BOLD}claw doctor${COLOR_RESET}\n\n"
