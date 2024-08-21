#!/bin/bash

# This script will be hosted at setup.mathisen.dev
# It will point to/mirror a public GitHub repository

# GitHub repository URL
GITHUB_REPO="https://github.com/trolann/your-repo-name.git"
REPO_DIR="$HOME/.config/configs"

# Function to securely read password
read_password() {
  unset password
  prompt="Enter decryption password: "
  while IFS= read -p "$prompt" -r -s -n 1 char; do
    if [[ $char == $'\0' ]]; then
      break
    fi
    prompt='*'
    password+="$char"
  done
  echo
}

# Function to ensure the repository is up to date
ensure_repo_updated() {
  if [ -d "$REPO_DIR" ]; then
    echo "Updating existing repository..."
    cd "$REPO_DIR"
    git pull
  else
    echo "Cloning repository..."
    git clone "$GITHUB_REPO" "$REPO_DIR"
    cd "$REPO_DIR"
  fi
}

# Function to run Ansible playbook
run_ansible_playbook() {
  local tags=$1
  local extra_vars=$2

  ansible-playbook setup-playbook.yml --tags "$tags" $extra_vars
}

# Main script
main() {
  # Ensure the repository is up to date
  ensure_repo_updated

  # Ask for operation mode
  echo "Select operation mode:"
  echo "1. Full setup"
  echo "2. Sync configurations"
  read -p "Enter your choice (1/2): " operation_mode

  # Install Ansible if not already installed
  if ! command -v ansible &>/dev/null; then
    sudo apt update
    sudo apt install -y ansible
  fi

  case $operation_mode in
  1)
    # Full setup
    read_password
    DECRYPT_PASSWORD=$password

    read -p "Do you want to setup Tailscale? (y/N): " setup_tailscale
    setup_tailscale=${setup_tailscale:-n}
    SETUP_TAILSCALE=$(echo $setup_tailscale | tr '[:upper:]' '[:lower:]')

    run_ansible_playbook "setup,sync" "--extra-vars \"decrypt_password=$DECRYPT_PASSWORD setup_tailscale=$SETUP_TAILSCALE\""

    echo "Full setup complete!"
    ;;
  2)
    # Sync configurations only
    run_ansible_playbook "sync"

    echo "Configuration sync complete!"
    ;;
  *)
    echo "Invalid choice. Exiting."
    exit 1
    ;;
  esac
}

# Run the main script
main
