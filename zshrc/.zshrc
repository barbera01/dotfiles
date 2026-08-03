
# --- WSL Windows user (used by freelens, kube-sync-win, etc.) ---
WIN_USER="${WIN_USER:-AndyBarber}"
WIN_HOME="/mnt/c/Users/$WIN_USER"

if [ -f "$HOME/.zshrc-env-sec" ]; then
  source "$HOME/.zshrc-env-sec"
fi

# --- Oh My Zsh setup ---
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME=""  # Oh My Posh controls the prompt; skip OMZ theme loading

plugins=(git)

source "$ZSH/oh-my-zsh.sh"

# --- Modular config (loaded after OMZ so functions/completions are available) ---
for file in "$HOME/.config/zsh/"*.zsh; do
  source "$file"
done

# --- Modern PATH management ---
# Use zsh deduplication
typeset -U PATH

# Base user tools
PATH="$HOME/.local/bin:$PATH"
PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
PATH="$HOME/.tfenv/bin:$PATH"

# Go
PATH="/usr/local/go/bin:$PATH"
PATH="$HOME/go/bin:$PATH"

# Neovim
PATH="/opt/nvim-linux-x86_64/bin:$PATH"

# .NET
export DOTNET_ROOT="$HOME/.dotnet"
PATH="$HOME/.dotnet:$PATH"

# Development tooling
PATH="$HOME/.opencode/bin:$PATH"

# NVM (lazy-loaded to avoid ~300ms shell startup penalty)
export NVM_DIR="$HOME/.nvm"
_lazy_nvm() {
  unset -f nvm node npm npx
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
}
nvm()  { _lazy_nvm; nvm "$@"; }
node() { _lazy_nvm; node "$@"; }
npm()  { _lazy_nvm; npm "$@"; }
npx()  { _lazy_nvm; npx "$@"; }

export PATH

# --- Starship prompt ---
# This controls your shell PROMPT theme (cloud-native Azure theme).
# Config: ~/.config/starship.toml
export STARSHIP_CONFIG="$HOME/.config/starship.toml"
eval "$(starship init zsh)"



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
  local COLLECTION_DIR="${POSTING_COLLECTION_DIR:-$HOME/repos/aba-sorted-github/Posting-Collections}"

  command posting \
    --collection "$COLLECTION_DIR" \
    "$@"
}
#override 
#POSTING_COLLECTION_DIR=./posting posting run test

# --- Launch Freelens from WSL tmux panes ---

freelens() {
  local exe="$WIN_HOME/AppData/Local/Programs/Freelens/Freelens.exe"
  powershell.exe -NoProfile -NonInteractive -Command \
    "Start-Process '$(wslpath -w "$exe")'" \
    >/dev/null 2>&1 </dev/null & disown
}
# --- Azure CLI "profile" selector (AZURE_CONFIG_DIR + KUBECONFIG) ---
# Usage:
#   az-ctx                 # interactive selection
#   az-ctx ABA             # set a specific context
#   az-ctx --persist       # also persist across panes: tmux server env in
#                          # tmux, or a state file (herdr has no server-side
#                          # global env, so new herdr panes source it instead)
: "${HERDR_AZURE_ENV_FILE:=$HOME/.config/herdr/azure-env.zsh}"

az-ctx() {
  emulate -L zsh

  local persist=0
  if [[ "${1:-}" == "--persist" ]]; then
    persist=1
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

  if (( persist )) && [[ -n "${TMUX:-}" ]]; then
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

  # herdr has no tmux-style server-side global env, so persist via a state
  # file instead; new herdr panes source it near the top of this file.
  if (( persist )) && [[ -n "${HERDR_ENV:-}" ]]; then
    mkdir -p "${HERDR_AZURE_ENV_FILE:h}"
    {
      if [[ -n "${AZURE_CONFIG_DIR:-}" ]]; then
        echo "export AZURE_CONFIG_DIR=${(qq)AZURE_CONFIG_DIR}"
      fi
      if [[ -n "${KUBECONFIG:-}" ]]; then
        echo "export KUBECONFIG=${(qq)KUBECONFIG}"
      fi
    } > "$HERDR_AZURE_ENV_FILE"
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
  clear
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

# --- Auto prompt for Azure context when inside tmux or herdr ---
# herdr panes don't inherit a server-side global env (unlike tmux), so pick
# up whatever context was last persisted via `az-ctx --persist` first.
if [[ -n "${HERDR_ENV:-}" && -z "${AZURE_CONFIG_DIR:-}" && -r "$HERDR_AZURE_ENV_FILE" ]]; then
  source "$HERDR_AZURE_ENV_FILE"
fi

if [[ ( -n "${TMUX:-}" || -n "${HERDR_ENV:-}" ) && -z "${AZURE_CONFIG_DIR:-}" && -t 0 ]]; then
  az-ctx
fi

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

  local win_kube_dir="$WIN_HOME/.kube"
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
  local -a vars=("${(@f)$(grep -E '^[A-Za-z_][A-Za-z0-9_]*=' "$env_file" | cut -d= -f1)}")
  local var
  for var in "${vars[@]}"; do
    unset "$var"
  done
}

bw-unlock() {
  # Ensure we’re pointed at your Vaultwarden
  bw config server https://vault.andybarber.dev >/dev/null

  # If already unlocked, reuse the session
  if bw status 2>/dev/null | jq -e '.status=="unlocked"' >/dev/null; then
    echo "Bitwarden already unlocked ✅"
    return 0
  fi

  # Prompt for master password (hidden)
  unset BW_PASSWORD
  echo -n "Bitwarden master password: "
  read -rs BW_PASSWORD
  echo
  export BW_PASSWORD

  # Login with API key if needed
  if ! bw status | jq -e '.status!="unauthenticated"' >/dev/null; then
    bw login --apikey --raw >/dev/null
  fi

  # Unlock and capture session
  export BW_SESSION="$(bw unlock --passwordenv BW_PASSWORD --raw)"

  # Clear master password from environment immediately
  unset BW_PASSWORD

  # Optional but recommended
  bw sync >/dev/null

  echo "Vault unlocked 🔓"
}
alias podman=podman.exe
export BROWSER="/mnt/c/Program Files (x86)/Microsoft/Edge/Application/msedge.exe"

# --- HackerRank / interview prep helpers (optional) ---
alias tmuxconfig='${EDITOR:-nvim} ~/.tmux.conf'
alias zshreload='source ~/.zshrc && echo "zshrc reloaded"'

export PATH="$PATH:$(go env GOPATH)/bin"
export PATH="$PATH:/snap/bin"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$PATH:/opt/mssql-tools18/bin"



export PATH=$(echo "$PATH" | tr ':' '\n' | grep -v '/mnt/c/Users/AndyBarber/AppData/Roaming/npm' | paste -sd:)
alias lzd-RT0='DOCKER_HOST=ssh://user@racetrack-0 lazydocker'
alias lzd-RT1='DOCKER_HOST=ssh://user@racetrack-1 lazydocker'

# Fix Wayland clipboard for nvim/wl-clipboard under WSLg (real socket lives here, not /run/user/$UID)
export XDG_RUNTIME_DIR=/mnt/wslg/runtime-dir
