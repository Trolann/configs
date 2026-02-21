#!/bin/bash
# Bootstrap a new machine with dotfiles
# Usage: curl -fsSL https://raw.githubusercontent.com/Trolann/configs/main/bootstrap.sh | bash
# Or: clone the repo and run ./bootstrap.sh
set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
log()  { echo -e "${GREEN}[+]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
err()  { echo -e "${RED}[x]${NC} $1"; }

detect_os() {
    if [[ "$(uname)" == "Darwin" ]]; then
        echo "macos"
    elif grep -qi microsoft /proc/version 2>/dev/null; then
        echo "wsl"
    elif [[ -f /etc/os-release ]]; then
        echo "linux"
    else
        echo "unknown"
    fi
}

install_packages_linux() {
    log "Installing base packages..."
    sudo apt update -q
    sudo apt install -y zsh bat unzip curl git
}

install_packages_macos() {
    if ! command -v brew &>/dev/null; then
        log "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    log "Installing base packages..."
    brew install zsh bat unzip curl git
}

set_default_shell() {
    local zsh_path
    zsh_path=$(which zsh)
    if [[ "$SHELL" != "$zsh_path" ]]; then
        log "Setting zsh as default shell..."
        chsh -s "$zsh_path"
        warn "Shell changed. Log out and back in for it to take effect."
    else
        log "zsh is already the default shell."
    fi
}

install_tailscale() {
    if command -v tailscale &>/dev/null; then
        log "Tailscale already installed."
        return
    fi
    log "Installing Tailscale..."
    curl -fsSL https://tailscale.com/install.sh | sh
}

main() {
    echo "================================"
    echo "     Machine Bootstrap"
    echo "================================"
    echo ""

    local os
    os=$(detect_os)
    log "Detected OS: $os"

    case "$os" in
        linux|wsl)
            install_packages_linux
            ;;
        macos)
            install_packages_macos
            ;;
        *)
            err "Unsupported OS. Install zsh, bat, curl, git manually then run ./install.sh"
            exit 1
            ;;
    esac

    set_default_shell

    read -rp "Install Tailscale? (y/N): " ts_choice
    if [[ "${ts_choice,,}" == "y" ]]; then
        install_tailscale
    fi

    log "Running dotfiles installer..."
    case "$os" in
        linux|wsl) bash "$REPO_DIR/install.sh" linux ;;
        macos)     bash "$REPO_DIR/install.sh" macos ;;
    esac

    log "Bootstrap complete! Run 'exec zsh' to apply shell changes."
}

main "$@"
