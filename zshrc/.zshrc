
if [ -f "$HOME/.zshrc-env-sec" ]; then
  source "$HOME/.zshrc-env-sec"
fi

# --- Oh My Zsh setup ---
export ZSH="$HOME/.oh-my-posh"
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

plugins=(git)

source $ZSH/oh-my-zsh.sh

# --- Modern PATH management ---
# Use zsh deduplication
typeset -U PATH

# Base user tools
PATH="$HOME/.local/bin:$PATH"
PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
PATH="$HOME/.tfenv/bin:$PATH"
PATH="$HOME/.tfenv/bin:$PATH"
PATH="$HOME/.tfenv/bin:$PATH"
PATH="$HOME/.tfenv/bin:$PATH"
PATH="$HOME/.tfenv/bin:$PATH"

# Go
PATH="/usr/local/go/bin:$PATH"
PATH="$HOME/go/bin:$PATH"

# Neovim
PATH="/opt/nvim-linux-x86_64/bin:$PATH"

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"

# Terraform env manager
PATH="$HOME/.tfenv/bin:$PATH"

export PATH

# --- Oh My Posh prompt ---
# This controls your shell PROMPT theme
eval "$(oh-my-posh init zsh --config ~/.poshthemes/cloud-native-azure.omp.json)"

# --- eza integration ---
# Make file listings match tmux Catppuccin mocha flavor
export EZA_COLORS="di=38;2;166;218;149:\
ex=38;2;238;212;159:\
ln=38;2;245;194;231:\
so=38;2;137;180;250:\
pi=38;2;249;226;175:\
bd=38;2;203;166;247:\
cd=38;2;203;166;247:\
or=38;2;243;139;168"

alias ls='eza --icons'

# --- tmux specific behaviour ---
# Start ssh-agent automatically when outside SSH
if [ -z "$SSH_AUTH_SOCK" ]; then
  eval "$(ssh-agent -s)" > /dev/null 2>&1
fi


# --- Launch Freelens from WSL tmux panes ---
freelens() {
  cmd.exe /c start "" "C:\Users\AndyBarber\AppData\Local\Programs\Freelens\Freelens.exe" >/dev/null 2>&1
}

# --- Azure Subscription selector (fixed + modern) ---
az-sub() {
  if ! command -v az >/dev/null 2>&1; then
    echo "Azure CLI not installed"
    return 1
  fi

  if ! az account show >/dev/null 2>&1; then
    echo "❌ Not logged into Azure CLI"
    az login --use-device-code
  fi

  mapfile -t SUBS < <(az account list --all --query "[].name" -o tsv)

  if [ ${#SUBS[@]} -eq 0 ]; then
    echo "No subscriptions found"
    return 1
  fi

  echo "Select Azure subscription:"
  select name in "${SUBS[@]}"; do
    if [ -n "$name" ]; then
      az account set --subscription "$name"
      echo "Active subscription set to: $name"
      break
    fi
  done
}

# --- Azure context selector when inside tmux ---
if [[ -n "$TMUX" && -z "$AZURE_CONFIG_DIR" ]]; then
  echo "Select Azure CLI context:"

  select AZCTX in SOR-Default SOR-COM ABA ABA-DEV ABA-Home-Cloud none; do
    case "$AZCTX" in
      SOR-Default)
        export AZURE_CONFIG_DIR="$HOME/.azure-sor-default"
        export KUBECONFIG="$HOME/.kube/config-sor-default"
        ;;
      SOR-COM)
        export AZURE_CONFIG_DIR="$HOME/.azure-sor-com"
        export KUBECONFIG="$HOME/.kube/config-sor-com"
        ;;
      ABA)
        export AZURE_CONFIG_DIR="$HOME/.azure-ABA"
        export KUBECONFIG="$HOME/.kube/config-aba"
        ;;
      ABA-DEV)
        export AZURE_CONFIG_DIR="$HOME/.azure-ABA-DEV"
        export KUBECONFIG="$HOME/.kube/config-aba-dev"
        ;;
      none)
        unset AZURE_CONFIG_DIR
        unset KUBECONFIG
        echo "Azure & Kubernetes context not set"
        break
        ;;
      *)
        echo "Invalid selection"
        continue
        ;;
    esac

    # If a context was set and login is required
    if [[ -n "$AZURE_CONFIG_DIR" ]]; then
      if ! az account show >/dev/null 2>&1; then
        echo "🔐 Azure login required – using device code"
        az login --use-device-code
      fi
    fi

    break
  done
fi

# -- Kubernetes ---
alias kubectl-clear='kubectl config unset current-context'

# --- Development tooling ---
export PATH="/home/andy/.opencode/bin:$PATH"
export PATH="/home/andy/.tfenv/bin:$PATH"

# --- HackerRank / interview prep helpers (optional) ---
alias tmuxconfig='${EDITOR:-nvim} ~/.tmux.conf'
alias zshreload='source ~/.zshrc && echo "zshrc reloaded"'

