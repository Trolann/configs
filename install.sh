#!/bin/bash
set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LINUX_DIR="$REPO_DIR/linux"
WINDOWS_DIR="$REPO_DIR/windows"
CLAUDE_DIR="$REPO_DIR/claude"

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
log()  { echo -e "${GREEN}[+]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
err()  { echo -e "${RED}[x]${NC} $1"; }

is_wsl() { grep -qi microsoft /proc/version 2>/dev/null; }

win_home_wsl() {
    local win_home
    win_home=$(cmd.exe /c "echo %USERPROFILE%" 2>/dev/null | tr -d '\r')
    wslpath "$win_home" 2>/dev/null
}

symlink() {
    local src="$1" dst="$2"
    if [ -e "$dst" ] && [ ! -L "$dst" ]; then
        warn "Backing up $dst -> $dst.bak"
        mv "$dst" "$dst.bak"
    elif [ -L "$dst" ]; then
        rm "$dst"
    fi
    ln -s "$src" "$dst"
    log "Linked $dst"
}

setup_linux() {
    log "Setting up Linux dotfiles..."

    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        log "Installing oh-my-zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi

    if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then
        log "Installing zsh-autosuggestions..."
        git clone https://github.com/zsh-users/zsh-autosuggestions \
            "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
    fi

    symlink "$LINUX_DIR/.zshrc"      "$HOME/.zshrc"
    symlink "$REPO_DIR/.wezterm.lua" "$HOME/.wezterm.lua"
    symlink "$REPO_DIR/tmux/tmux.conf" "$HOME/.tmux.conf"

    read -rp "Set up git config? (y/N): " git_choice
    if [[ "${git_choice,,}" == "y" ]]; then
        symlink "$LINUX_DIR/.gitconfig" "$HOME/.gitconfig"
        log "Git config linked."
    else
        warn "Skipping git config — set up manually if needed."
    fi

    # i3 (desktop only — skip on headless)
    if command -v i3 &>/dev/null || [ -d "$HOME/.config/i3" ]; then
        log "Setting up i3 config..."
        mkdir -p "$HOME/.config/i3"
        symlink "$LINUX_DIR/i3/config"               "$HOME/.config/i3/config"
        symlink "$LINUX_DIR/i3/i3status.conf"        "$HOME/.config/i3/i3status.conf"
        symlink "$LINUX_DIR/i3/power.sh"             "$HOME/.config/i3/power.sh"
        symlink "$LINUX_DIR/i3/screenz.sh"           "$HOME/.config/i3/screenz.sh"
        symlink "$LINUX_DIR/i3/screenz2.sh"          "$HOME/.config/i3/screenz2.sh"
        symlink "$LINUX_DIR/i3/disconnect-displays.sh" "$HOME/.config/i3/disconnect-displays.sh"
        symlink "$LINUX_DIR/i3/krusader.sh"          "$HOME/.config/i3/krusader.sh"
        symlink "$LINUX_DIR/i3/rclone.sh"            "$HOME/.config/i3/rclone.sh"
        symlink "$LINUX_DIR/i3/pycharm_launch.sh"    "$HOME/.config/i3/pycharm_launch.sh"
        log "i3 config linked."
    else
        warn "i3 not found — skipping i3 config (headless machine)."
    fi

    setup_claude

    log "Linux dotfiles done."
}

setup_claude() {
    log "Setting up Claude Code configs..."
    mkdir -p "$HOME/.claude/commands"
    symlink "$CLAUDE_DIR/CLAUDE.md"    "$HOME/.claude/CLAUDE.md"
    symlink "$CLAUDE_DIR/settings.json" "$HOME/.claude/settings.json"
    # Symlink each custom command individually so machine-specific commands can coexist
    for cmd in "$CLAUDE_DIR/commands"/*; do
        [ -f "$cmd" ] && [ "$(basename "$cmd")" != ".gitkeep" ] && \
            symlink "$cmd" "$HOME/.claude/commands/$(basename "$cmd")"
    done
    log "Claude Code configs linked."
}

setup_windows() {
    if ! is_wsl; then
        err "Not running in WSL, skipping Windows setup."
        return
    fi

    local wh
    wh=$(win_home_wsl)
    if [ -z "$wh" ]; then
        err "Could not detect Windows home directory."
        return
    fi

    log "Windows home: $wh"
    log "Setting up Windows dotfiles..."

    cp "$REPO_DIR/.wezterm.lua"              "$wh/.wezterm.lua"
    log "Copied .wezterm.lua"

    mkdir -p "$wh/.glzr/glazewm"
    cp "$WINDOWS_DIR/glazewm/config.yaml"    "$wh/.glzr/glazewm/config.yaml"
    log "Copied glazewm/config.yaml"

    mkdir -p "$wh/.glzr/zebar"
    cp "$WINDOWS_DIR/zebar/config.yaml"      "$wh/.glzr/zebar/config.yaml"
    cp "$WINDOWS_DIR/zebar/script.js"        "$wh/.glzr/zebar/script.js"
    cp "$WINDOWS_DIR/zebar/settings.json"    "$wh/.glzr/zebar/settings.json"
    cp "$WINDOWS_DIR/zebar/start.bat"        "$wh/.glzr/zebar/start.bat"
    log "Copied zebar configs"

    warn "Windows configs copied. Run './install.sh sync-windows' to pull changes back into the repo."
    log "Windows dotfiles done."
}

setup_macos() {
    if [[ "$(uname)" != "Darwin" ]]; then
        err "Not running on macOS, skipping."
        return
    fi

    log "Setting up macOS dotfiles..."

    symlink "$REPO_DIR/.wezterm.lua" "$HOME/.wezterm.lua"

    read -rp "Set up git config? (y/N): " git_choice
    if [[ "${git_choice,,}" == "y" ]]; then
        symlink "$LINUX_DIR/.gitconfig" "$HOME/.gitconfig"
        log "Git config linked."
    else
        warn "Skipping git config — set up manually if needed."
    fi

    setup_claude

    # TODO: add macOS-specific configs to macos/ and symlink them here
    warn "Add more macOS configs to macos/ as needed."
}

sync_windows() {
    if ! is_wsl; then
        err "Not running in WSL."
        return
    fi

    local wh
    wh=$(win_home_wsl)
    if [ -z "$wh" ]; then
        err "Could not detect Windows home directory."
        return
    fi

    log "Syncing Windows configs into repo..."

    cp "$wh/.wezterm.lua"                    "$REPO_DIR/.wezterm.lua"
    cp "$wh/.glzr/glazewm/config.yaml"       "$WINDOWS_DIR/glazewm/config.yaml"
    cp "$wh/.glzr/zebar/config.yaml"         "$WINDOWS_DIR/zebar/config.yaml"
    cp "$wh/.glzr/zebar/script.js"           "$WINDOWS_DIR/zebar/script.js"
    cp "$wh/.glzr/zebar/settings.json"       "$WINDOWS_DIR/zebar/settings.json"
    cp "$wh/.glzr/zebar/start.bat"           "$WINDOWS_DIR/zebar/start.bat"

    log "Synced. Run 'git diff' to review, then commit."
}

install_mux_server() {
    local host="${1:-}"
    [ -z "$host" ] && { err "Usage: ./install.sh install-mux <host>"; exit 1; }

    log "Detecting OS on $host..."
    local remote_os
    remote_os=$(ssh "$host" "uname -s" 2>/dev/null)

    case "$remote_os" in
        Linux)
            ssh "$host" "
                curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
                echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list
                sudo apt update && sudo apt install -y wezterm
            "
            ;;
        Darwin)
            ssh "$host" "brew install wezterm"
            ;;
        *)
            err "Unsupported remote OS: $remote_os"
            exit 1
            ;;
    esac

    log "Done! Now set mux = true for '$host' in the hosts table in .wezterm.lua, then commit."
}

main() {
    echo "================================"
    echo "     Dotfiles Installer"
    echo "================================"
    echo ""

    case "${1:-}" in
        linux)         setup_linux;                  exit 0 ;;
        windows)       setup_windows;                exit 0 ;;
        macos)         setup_macos;                  exit 0 ;;
        sync-windows)  sync_windows;                 exit 0 ;;
        install-mux)   install_mux_server "${2:-}";  exit 0 ;;
    esac

    echo "What would you like to set up?"
    echo "  1) Linux dotfiles"
    if is_wsl; then
        echo "  2) Windows dotfiles (WezTerm, GlazeWM, Zebar)"
        echo "  3) Both (Linux + Windows)"
    fi
    if [[ "$(uname)" == "Darwin" ]]; then
        echo "  4) macOS dotfiles"
    fi
    echo ""
    read -rp "Choice: " choice

    case "$choice" in
        1) setup_linux ;;
        2) setup_windows ;;
        3) setup_linux; setup_windows ;;
        4) setup_macos ;;
        *) err "Invalid choice."; exit 1 ;;
    esac
}

main "$@"
