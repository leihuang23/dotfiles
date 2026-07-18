# Migrated from ~/.zshrc.backup.
# Intentionally skipped: Oh My Zsh and Powerlevel10k (conflict with home-manager's zsh/starship setup).

# ===== HarmonyOS / OpenHarmony Development =====
DEVECO_STUDIO_HOME="/Applications/DevEco-Studio.app/Contents"
if [[ -d "$DEVECO_STUDIO_HOME" ]]; then
  export DEVECO_STUDIO_HOME
  export JAVA_HOME="$DEVECO_STUDIO_HOME/jbr/Contents/Home"
  export PATH="$JAVA_HOME/bin:$PATH"
  export NODE_HOME="$DEVECO_STUDIO_HOME/tools/node"
  export PATH="$NODE_HOME/bin:$PATH"
  export DEVECO_SDK_HOME="$DEVECO_STUDIO_HOME/sdk/default/openharmony"
  export PATH="$DEVECO_SDK_HOME/toolchains:$PATH"
  export PATH="$DEVECO_STUDIO_HOME/tools/ohpm/bin:$PATH"
  export PATH="$DEVECO_STUDIO_HOME/tools/hvigor/bin:$PATH"
fi
# ===== End HarmonyOS =====

# Custom completions path
fpath=("$HOME/.zsh/completions" $fpath)

# ----- Aliases -----
alias vi="nvim"
alias vim="nvim"
alias zshconfig="nvim ~/.zshrc"
alias rebase="git fetch origin main && git rebase origin/main"

# ----- Paths -----
export PATH="$HOME/.local/bin:$PATH"
export PATH="/opt/homebrew/opt/python@3.14/libexec/bin:$PATH"
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
export PATH="$HOME/.smux/bin:$PATH"
export PATH="$HOME/.antigravity/antigravity/bin:$PATH"
export PATH="$HOME/.mavis/bin:$PATH"
export PATH="$HOME/.opencode/bin:$PATH"
export PATH="$HOME/.kimi-code/bin:$PATH"

[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# ----- Functions -----
uuid() {
  local uuid_str=$(uuidgen | tr '[:upper:]' '[:lower:]')
  echo "$uuid_str"
  echo -n "$uuid_str" | pbcopy
}

# Override rm to move files to macOS Trash instead of permanent deletion
rm() {
  local files=()
  for arg in "$@"; do
    case "$arg" in
      --help|-h)
        echo "rm: using trash (macOS Trash) — \c"
        trash --help
        return
        ;;
      -*) ;;
      *) files+=("$arg") ;;
    esac
  done
  if (( ${#files} == 0 )); then
    [[ "$1" == "-"* ]] && echo "rm: missing file operand" >&2 || echo "rm: missing operand" >&2
    return 1
  fi
  trash "${files[@]}"
}

# ----- Tokens and IDs -----
if [[ -f "$HOME/.zshrc.secrets" ]]; then
  source "$HOME/.zshrc.secrets"
fi

# Derive Claude Code DeepSeek credentials from the single DeepSeek key.
# Use ANTHROPIC_AUTH_TOKEN (not ANTHROPIC_API_KEY) when pointing at a custom base URL.
if [[ -n "$DEEPSEEK_API_KEY" ]]; then
  export ANTHROPIC_AUTH_TOKEN="$DEEPSEEK_API_KEY"
fi

# ----- Node Version Manager -----
# nvm owns interactive `node` / `npm` / global CLIs.
# DevEco above sets NODE_HOME and puts its node on PATH for HarmonyOS tooling;
# zsh's unique PATH keeps the first occurrence, so a later nvm path that is
# already present does not move to the front. Re-strip and re-prepend after load.
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
if command -v nvm >/dev/null 2>&1; then
  # Prefer the configured default, not "current" (which can be "system" when
  # DevEco/Homebrew already won PATH before nvm finished loading).
  _nvm_node="$(nvm which default 2>/dev/null || true)"
  if [[ -n "$_nvm_node" && "$_nvm_node" != system && -x "$_nvm_node" ]]; then
    _nvm_bin="${_nvm_node:h}"
    path=("${_nvm_bin}" ${path:#${_nvm_bin}})
    export PATH
    nvm use default --silent 2>/dev/null || true
  fi
  unset _nvm_node _nvm_bin
fi

# ----- zoxide (replaces omz 'z' plugin) -----
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi
