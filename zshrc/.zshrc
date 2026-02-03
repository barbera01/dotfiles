
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

posting() {
  local COLLECTION_DIR="${POSTING_COLLECTION_DIR:-/home/andy/repos/aba-sorted-github/Posting-Collections}"

  command posting \
    --collection "$COLLECTION_DIR" \
    "$@"
}
#override 
#POSTING_COLLECTION_DIR=./posting posting run test

# --- Launch Freelens from WSL tmux panes ---

freelens() {
  local exe="/mnt/c/Users/AndyBarber/AppData/Local/Programs/Freelens/Freelens.exe"
  powershell.exe -NoProfile -NonInteractive -Command \
    "Start-Process '$(wslpath -w "$exe")'" \
    >/dev/null 2>&1 </dev/null & disown
}
# --- Azure CLI "profile" selector (AZURE_CONFIG_DIR + KUBECONFIG) ---
# Usage:
#   az-ctx                 # interactive selection
#   az-ctx ABA             # set a specific context
#   az-ctx --persist       # also persist into tmux server env
az-ctx() {
  emulate -L zsh

  local persist_tmux=0
  if [[ "${1:-}" == "--persist" ]]; then
    persist_tmux=1
    shift
  fi

  local requested="${1:-}"
  local AZCTX=""

  if [[ -n "$requested" ]]; then
    AZCTX="$requested"
  else
    if [[ ! -t 0 ]]; then
      echo "az-ctx: no TTY available; pass a context name (e.g. 'az-ctx ABA')"
      return 2
    fi
    echo "Select Azure CLI context:"
    select AZCTX in SOR-Default SOR-COM ABA ABA-DEV ABA-Home-Cloud SOR-Admin-default none; do
      [[ -n "${AZCTX:-}" ]] || { echo "Invalid selection"; continue; }
      break
    done
  fi

  case "$AZCTX" in
    SOR-Default)
      export AZURE_CONFIG_DIR="$HOME/.azure-sor-default"
      export KUBECONFIG="$HOME/.kube/config-sor-default"
      ;;
    SOR-Admin-default)
      export AZURE_CONFIG_DIR="$HOME/.azure-sor-admin-default"
      export KUBECONFIG="$HOME/.kube/config-sor-admin-default"
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
    ABA-Home-Cloud)
      export AZURE_CONFIG_DIR="$HOME/.azure-ABA-Home-Cloud"
      export KUBECONFIG="$HOME/.kube/config-aba-home-cloud"
      ;;
    none)
      unset AZURE_CONFIG_DIR
      unset KUBECONFIG
      echo "Azure & Kubernetes context not set"
      ;;
    *)
      echo "Unknown context: $AZCTX"
      echo "Valid: SOR-Default | SOR-COM | ABA | ABA-DEV | ABA-Home-Cloud | SOR-Admin-default | none"
      return 1
      ;;
  esac

  if (( persist_tmux )) && [[ -n "${TMUX:-}" ]]; then
    if [[ -n "${AZURE_CONFIG_DIR:-}" ]]; then
      tmux set-environment -g AZURE_CONFIG_DIR "$AZURE_CONFIG_DIR"
    else
      tmux set-environment -gu AZURE_CONFIG_DIR
    fi

    if [[ -n "${KUBECONFIG:-}" ]]; then
      tmux set-environment -g KUBECONFIG "$KUBECONFIG"
    else
      tmux set-environment -gu KUBECONFIG
    fi
  fi

  # If a context was set and login is required
  if [[ -n "${AZURE_CONFIG_DIR:-}" ]]; then
    if ! command -v az >/dev/null 2>&1; then
      echo "Azure CLI not installed"
      return 1
    fi

    if ! az account show >/dev/null 2>&1; then
      echo "Azure login required - using device code"
      az login --use-device-code || return 1
    fi
  fi
}

# --- Azure Subscription selector (numbered TSV list) ---
az-sub() {
  emulate -L zsh

  if ! command -v az >/dev/null 2>&1; then
    echo "Azure CLI not installed"
    return 1
  fi

  if ! az account show >/dev/null 2>&1; then
    echo "Not logged into Azure CLI; starting device login"
    az login --use-device-code || return 1
  fi

  local -a sub_names sub_ids sub_states sub_defaults
  local name id state isDefault

  while IFS=$'\t' read -r name id state isDefault; do
    [[ -n "$id" ]] || continue
    sub_names+=("$name")
    sub_ids+=("$id")
    sub_states+=("$state")
    sub_defaults+=("$isDefault")
  done < <(az account list --all --query "[].{name:name,id:id,state:state,isDefault:isDefault}" -o tsv)

  if (( ${#sub_ids[@]} == 0 )); then
    echo "No subscriptions found"
    return 1
  fi

  echo "Subscriptions:"
  echo $'No\tName\tID\tState\tNotes'

  local i notes
  for (( i = 1; i <= ${#sub_ids[@]}; i++ )); do
    notes=""
    if [[ "${sub_defaults[$i]}" == "true" ]]; then
      notes="default"
    fi
    printf "%d\t%s\t%s\t%s\t%s\n" \
      "$i" "${sub_names[$i]}" "${sub_ids[$i]}" "${sub_states[$i]}" "$notes"
  done

  local choice
  printf "Enter number to set subscription (blank to cancel): "
  IFS= read -r choice

  if [[ -z "$choice" ]]; then
    echo "Cancelled"
    return 0
  fi

  if [[ "$choice" != <-> ]]; then
    echo "Invalid selection: $choice"
    return 1
  fi

  if (( choice < 1 || choice > ${#sub_ids[@]} )); then
    echo "Selection out of range: $choice"
    return 1
  fi

  local sub_id="${sub_ids[$choice]}"
  az account set --subscription "$sub_id" || return 1
  echo "Active subscription set to: ${sub_names[$choice]} ($sub_id)"
}

# --- Auto prompt for Azure context when inside tmux ---
if [[ -n "${TMUX:-}" && -z "${AZURE_CONFIG_DIR:-}" && -t 0 ]]; then
  az-ctx
fi

export DOTNET_ROOT=$HOME/.dotnet
export PATH=$HOME/.dotnet:$PATH


# -- Kubernetes ---
alias kubectl-clear='kubectl config unset current-context'

# Sync current kubeconfig to Windows ~/.kube (WSL)
kube-sync-win() {
  emulate -L zsh

  local src=""
  if [[ -n "${1:-}" ]]; then
    src="$1"
  elif [[ -n "${KUBECONFIG:-}" ]]; then
    local -a candidates
    candidates=("${(@s/:/)KUBECONFIG}")
    local c
    for c in "${candidates[@]}"; do
      [[ -n "$c" ]] || continue
      c="${~c}"
      c="${c:A}"
      if [[ -f "$c" ]]; then
        src="$c"
        break
      fi
    done
  fi

  [[ -n "$src" ]] || src="$HOME/.kube/config"

  if [[ ! -f "$src" ]]; then
    echo "kubeconfig not found: $src"
    [[ -n "${KUBECONFIG:-}" ]] && echo "KUBECONFIG=$KUBECONFIG"
    return 1
  fi

  local win_kube_dir="/mnt/c/Users/AndyBarber/.kube"
  local dst="$win_kube_dir/${src:t}"

  mkdir -p "$win_kube_dir" || return 1
  cp -f "$src" "$dst" || return 1
  echo "Synced kubeconfig -> $dst"
}
srcenv() {
  if [ $# -ne 1 ]; then
    echo "Usage: srcenv <env-file>" >&2
    return 1
  fi

  local env_file="$1"

  if [ ! -f "$env_file" ]; then
    echo "srcenv: file not found: $env_file" >&2
    return 1
  fi

  set -a
  # shellcheck disable=SC1090
  source "$env_file"
  set +a
}
unsrcenv() {
  if [ $# -ne 1 ]; then
    echo "Usage: unsrcenv <env-file>" >&2
    return 1
  fi

  local env_file="$1"

  if [ ! -f "$env_file" ]; then
    echo "unsrcenv: file not found: $env_file" >&2
    return 1
  fi

  # Extract variable names and unset them
  grep -E '^[A-Za-z_][A-Za-z0-9_]*=' "$env_file" |
    cut -d= -f1 |
    while read -r var; do
      unset "$var"
    done
}

# --- Development tooling ---
export PATH="/home/andy/.opencode/bin:$PATH"
export PATH="/home/andy/.tfenv/bin:$PATH"

# --- HackerRank / interview prep helpers (optional) ---
alias tmuxconfig='${EDITOR:-nvim} ~/.tmux.conf'
alias zshreload='source ~/.zshrc && echo "zshrc reloaded"'
