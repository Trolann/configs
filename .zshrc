export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="refined"

DISABLE_AUTO_TITLE="true"
echo -ne "\033]0;$(hostname)\007"
COMPLETION_WAITING_DOTS="true"

plugins=(git python zsh-autosuggestions)

source $ZSH/oh-my-zsh.sh

alias ls="ls -lah --color=auto"
alias cat=batcat
alias update="sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y && sudo apt autoclean"

export PATH="$HOME/.local/bin:$PATH"

ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# fnm
FNM_PATH="$HOME/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="$FNM_PATH:$PATH"
  eval "`fnm env`"
fi

venv() {
    if [ $# -eq 0 ]; then
        for dir in */; do
            if [ -f "${dir}bin/activate" ]; then
                source "${dir}bin/activate"
                echo "Activated: ${dir%/}"
                return 0
            fi
        done
        echo "No venv found. Usage: venv <name> to create one."
    else
        if [ -d "$1" ]; then
            source "$1/bin/activate"
        else
            python3 -m venv "$1" && source "$1/bin/activate"
        fi
    fi
}

