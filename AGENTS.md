# AGENTS.md — AI Agent Instructions for This Repo

This repository manages dotfiles and system configurations across multiple machines and platforms. This file provides context for AI agents (Claude Code, etc.) working in this repo.

## What This Repo Is

A multi-platform dotfiles manager for:
- **Linux desktop** — i3 WM, WezTerm, zsh
- **Linux headless** — VPS/home servers, zsh, WezTerm mux
- **Windows** — GlazeWM + Zebar + WezTerm (via WSL)
- **macOS** — WezTerm + Aerospace (to be added)

The goal is to keep configurations synchronized across all machines, with consistent keybindings and workflows everywhere.

## Entry Points

| Script | Purpose |
|--------|---------|
| `bootstrap.sh` | Full new-machine setup: installs packages, then calls `install.sh` |
| `install.sh linux` | Symlink dotfiles for Linux (desktop + headless) |
| `install.sh macos` | Symlink dotfiles for macOS |
| `install.sh windows` | Copy configs to Windows home (run from WSL) |
| `install.sh sync-windows` | Pull Windows config changes back into repo |
| `install.sh install-mux <host>` | Install WezTerm mux server on a remote host |

## Repo Structure

```
configs/
├── bootstrap.sh          # New machine setup (no Ansible — pure bash)
├── install.sh            # Dotfiles symlinker
├── .zshrc                # Shared zshrc (fallback/reference)
├── .wezterm.lua          # WezTerm config (shared across all platforms)
├── .vimrc                # Minimal vim config
│
├── linux/
│   ├── .zshrc            # Linux zshrc — symlinked to ~/.zshrc
│   ├── .gitconfig        # Git config — optional, user is prompted
│   └── i3/               # i3 WM — auto-detected, skipped on headless
│       ├── config        # Main i3 config
│       ├── i3status.conf # i3 status bar config
│       ├── power.sh      # Rofi power menu
│       ├── screenz.sh    # Multi-monitor layout selector (rofi)
│       ├── screenz2.sh   # Alternate monitor layout script
│       ├── disconnect-displays.sh
│       ├── krusader.sh   # Toggle Krusader file manager
│       ├── rclone.sh     # Cloud sync on startup
│       └── pycharm_launch.sh / *.json  # JetBrains layout helpers
│
├── claude/
│   ├── CLAUDE.md         # Global Claude Code instructions (shared)
│   ├── settings.json     # Shared Claude Code settings
│   └── commands/         # Custom slash commands (shared across machines)
│
├── windows/
│   ├── glazewm/config.yaml   # GlazeWM tiling WM config
│   └── zebar/                # Status bar (CPU, mem, clock, weather)
│
├── macos/                # Sparse — Aerospace config goes here when ready
└── tmux/                 # tmux config (kept for reference; use WezTerm mux instead)
```

## Design Principles

1. **No Ansible** — bootstrap.sh uses plain bash + apt/brew. Easy to run anywhere.
2. **Symlinks, not copies** — `install.sh` symlinks files so edits are immediately tracked in git.
3. **Per-machine flexibility** — gitconfig is optional. i3 is auto-detected. Claude's `settings.local.json` is never touched.
4. **WezTerm as the multiplexer** — tmux auto-launch is removed. Use WezTerm pane splitting instead.
5. **Consistent keybindings** — i3, GlazeWM, and Aerospace share the same Alt+hjkl navigation pattern.

## Cross-Platform Keybinding Reference

| Action | i3 (Linux) | GlazeWM (Windows) | Aerospace (macOS) |
|--------|-----------|-------------------|-------------------|
| Focus left/right/up/down | Alt+h/l/k/j | Alt+h/l/k/j | (to be configured) |
| Move window | Alt+Shift+h/l/k/j | Alt+Shift+h/l/k/j | |
| Switch workspace | Alt+1-9 | Alt+1-9 | |
| Move to workspace | Alt+Shift+1-9 | Alt+Shift+1-9 | |
| Open terminal | Alt+Enter | (configured separately) | |
| App launcher | Alt+d | (configured separately) | |
| Close window | Alt+Shift+q | Alt+Shift+q | |
| Resize mode | Alt+r | Alt+r | |
| Lock screen | Super+l | | |
| **WezTerm panes** | | | |
| Split vertical | Ctrl+\ | Ctrl+\ | Ctrl+\ |
| Split horizontal | Ctrl+Alt+\ | Ctrl+Alt+\ | Ctrl+Alt+\ |
| Navigate panes | Ctrl+Shift+h/j/k/l | Ctrl+Shift+h/j/k/l | Ctrl+Shift+h/j/k/l |

## Claude Code Configs (`claude/`)

What's tracked in git (shared across machines):
- `CLAUDE.md` — global instructions for Claude Code
- `settings.json` — shared preferences (auto-updates, etc.)
- `commands/` — custom slash commands available on all machines

What's NOT tracked (machine-specific):
- `settings.local.json` — per-machine permissions/overrides
- `history.jsonl`, `todos/`, `debug/`, `plans/` — session data
- `projects/` — per-project memory and CLAUDE.md
- `plugins/` — managed by Claude Code itself

To add machine-specific commands that won't sync, drop them directly in `~/.claude/commands/` (don't put them in the repo's `claude/commands/`).

## Machine-Specific Overrides (`.local` files)

Every shared config sources a `.local` file that is gitignored and never committed.
Use these for work-specific aliases, paths, keybindings, credentials, etc.

| Shared config | Local override | Format |
|---|---|---|
| `~/.zshrc` | `~/.zshrc.local` | Shell script — aliases, exports, PATH additions |
| `~/.gitconfig` | `~/.gitconfig.local` | Git config — `[user] email = work@company.com` |
| `~/.wezterm.lua` | `~/.wezterm.local.lua` | Lua — `return { { name = 'dev', exec_cmd = {...} } }` |
| `~/.tmux.conf` | `~/.tmux.local.conf` | tmux config — extra bindings, status bar tweaks |
| `~/.claude/CLAUDE.md` | `~/.claude/CLAUDE.md.local` | Markdown — machine-specific Claude instructions |
| `~/.claude/settings.json` | `~/.claude/settings.local.json` | JSON — machine-specific permissions |

Example `~/.zshrc.local` for a Meta work Mac:
```bash
alias dev='ondemand connect mydevserver'
export PATH="/opt/homebrew/bin:$PATH"
```

Example `~/.wezterm.local.lua` for a Meta work Mac:
```lua
return {
  { name = 'devserver', exec_cmd = { 'ondemand', 'connect', 'mydevserver' } },
}
```

Example `~/.gitconfig.local` for work:
```gitconfig
[user]
    email = trevorm@meta.com
```

## Adding a New Machine

1. Clone repo: `git clone https://github.com/Trolann/configs.git ~/.config/configs`
2. Run: `~/.config/configs/install.sh linux` (or `macos` / `windows`)
3. Create `~/.zshrc.local`, `~/.wezterm.local.lua`, etc. for machine-specific config
4. For headless servers, the installer auto-detects no i3 and skips WM configs
5. For WezTerm SSH multiplexing: `./install.sh install-mux <hostname>`, then set `mux = true` in the hosts table

## What NOT to Do

- Don't add neovim/lazygit configs here — not tracked intentionally
- Don't commit `.local` files — they contain machine-specific or private config
- Don't commit `claude/settings.local.json` — it has machine-specific permissions
- Don't commit `claude/history.jsonl` or session data
- Don't add tmux auto-launch back to `.zshrc` — use WezTerm multiplexing
- Don't hardcode `/home/tr` paths — always use `$HOME`
