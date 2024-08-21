export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="refined"

DISABLE_AUTO_TITLE="true"
echo -ne "\033]0;$(hostname)\007"
COMPLETION_WAITING_DOTS="true"

plugins=(git python zsh-autosuggestions)

source $ZSH/oh-my-zsh.sh

alias ls="ls -lah --color=auto"
alias cat=batcat
alias vim=nvim
alias update="sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y && sudo apt autoclean"

export PYTHON_AUTO_VRUN=true
export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH:/opt/nvim-linux64/bin"
export PATH="$PATH:/opt/nvim-linux64/bin"

ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# fnm
FNM_PATH="/home/tr/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="/home/tr/.local/share/fnm:$PATH"
  eval "`fnm env`"
fi

venv() {
    if [ $# -eq 0 ]; then
        # No arguments, search for and activate the first valid venv
        for dir in */; do
            if [ -f "${dir}bin/activate" ]; then
                source "${dir}bin/activate"
                echo "Activated virtual environment: ${dir%/}"
                return 0
            fi
        done
        echo "No virtual environment found in the current directory."
        echo "Usage: venv <env-name> to create a new environment."
    else
        # Argument provided, create or activate named venv
        if [ -d "$1" ]; then
            source "$1/bin/activate"
        else
            python3 -m venv "$1"
            source "$1/bin/activate"
        fi
    fi
}

# Function to automatically activate/deactivate virtual environments
auto_venv() {
    # Deactivate any active virtual environment
    if [[ -n "$VIRTUAL_ENV" ]]; then
        deactivate
    fi

    # Check if .dont_auto_load_venv exists
    if [[ -f ".dont_auto_load_venv" ]]; then
        return
    fi

    # Look for a virtual environment in the current directory
    local venv_dir
    venv_dir=(*/bin/activate(N))
    if (( $#venv_dir )); then
        echo "Activating virtual environment: ${venv_dir[1]%/bin/activate}"
        source "${venv_dir[1]}"
    fi
}

# Add auto_venv to the chpwd_functions array
autoload -U add-zsh-hook
add-zsh-hook chpwd auto_venv

# Automatically start or attach to tmux session named 'main'
if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
  exec tmux new-session -A -s main
fi
