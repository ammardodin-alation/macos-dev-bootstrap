#!/usr/bin/env bash

set -o errexit
set -o errtrace
set -o pipefail
set -o nounset

trap 'echo "❌ Error occurred at $BASH_SOURCE:$LINENO"' ERR

HOME="${HOME:-.}"
ZSHRC="$HOME/.zshrc"
BREWFILE="./Brewfile"
VERSION=$(git rev-parse --short HEAD 2>/dev/null || echo "dev")

echo "🚀 Setting up macOS Development Environment (Version: $VERSION)"

# Utility: Sync a block between START and END markers
sync_zsh_block() {
  local start_tag="$1"
  local end_tag="$2"
  local content="$3"

  sed -i '' "/$start_tag/,/$end_tag/d" "$ZSHRC"
  printf "\n%s\n%s\n%s\n" "$start_tag" "$content" "$end_tag" >> "$ZSHRC"
}

# Install Homebrew if missing
if ! command -v brew &>/dev/null; then
  echo "🍺 Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  echo "✅ Homebrew already installed."
fi

# Install Brewfile dependencies (skip in CI)
if [[ "${CI_MODE:-0}" -eq 0 ]]; then
  echo "📦 Checking Brewfile dependencies..."
  if ! brew bundle check --file="$BREWFILE"; then
    echo "📦 Installing missing Brewfile dependencies..."
    brew bundle --file="$BREWFILE"
  else
    echo "✅ All Brewfile dependencies are already installed."
  fi
else
  echo "🚀 Skipping brew bundle install in CI mode (handled by CI job)"
fi

# Install Oh My Zsh if missing
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "✨ Installing Oh My Zsh..."
  export RUNZSH=no
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "✅ Oh My Zsh already installed."
fi

# Set Zsh as default shell
echo "🐚 Setting Zsh as the default shell..."
ZSH="/bin/zsh"
if ! grep -q "$ZSH" /etc/shells; then
  echo "$ZSH" | sudo tee -a /etc/shells
fi

if [ "$SHELL" != "$ZSH" ]; then
  [[ "${CI_MODE:-0}" -eq 0 ]] && chsh -s "$ZSH" && echo "✅ Default shell changed to system Zsh."
else
  echo "✅ Default shell is already set to system Zsh."
fi

# Ensure zsh-autosuggestions is sourced (store literal command in .zshrc)
echo "✨ Ensuring zsh-autosuggestions is sourced..."
if ! grep -q '^source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh$' "$ZSHRC"; then
  echo "source \$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh" >> "$ZSHRC"
fi

# Ensure Zsh completion system is initialized
echo "✨ Ensuring Zsh completion system is initialized..."
if ! grep -q '^autoload -Uz compinit' "$ZSHRC"; then
  cat <<'EOF' >> "$ZSHRC"

# Zsh Completion System
autoload -Uz compinit
compinit -d "${ZDOTDIR:-$HOME}/.zcompdump"
EOF
fi

# Configure Starship prompt
echo "🚀 Configuring Starship..."
mkdir -p "${HOME}/.config"
if ! diff -q "starship.toml" "${HOME}/.config/starship.toml" &>/dev/null; then
  cp "starship.toml" "${HOME}/.config/starship.toml"
  echo "✅ starship.toml updated."
else
  echo "✅ starship.toml is already up to date."
fi

echo "✨ Ensuring Starship is initialized in Zsh..."
if ! grep -q '^eval "$(starship init zsh)"$' "$ZSHRC"; then
  echo 'eval "$(starship init zsh)"' >> "$ZSHRC"
fi

# Sync custom functions into .zshrc
echo "🧠 Syncing custom functions..."
FUNCTION_BLOCK_START="# >>> CUSTOM FUNCTIONS >>>"
FUNCTION_BLOCK_END="# <<< CUSTOM FUNCTIONS <<<"
CUSTOM_FUNCTIONS=$(cat <<'EOF'
function glmd() {
  echo "| Commit Hash | Author       | Date       | Commit Message                                      |"
  echo "|-------------|--------------|------------|-----------------------------------------------------|"
  git log "$1"..."$2" --pretty=format:"| %h | %an | %ad | %s |" --date=short
}

function listec2 {
  region=${1:-${AWS_REGION:-us-east-1}}
  profile=${2:-${AWS_PROFILE:-engineering}}
  aws --region "${region}" --profile "${profile}" ec2 describe-instances --filters "Name=tag:Owner,Values=${USER}" "Name=instance-state-name,Values=running" --query 'Reservations[].Instances[].InstanceId' --output text
}

function terminateec2 {
  region=${1:-${AWS_REGION:-us-east-1}}
  profile=${2:-${AWS_PROFILE:-engineering}}
  ec2list="$(listec2 "$region" "$profile")"
  if [[ -z "$ec2list" ]]; then
    echo "No active EC2 instances were found"
    return 0
  fi
  aws --region "${region}" --profile "${profile}" ec2 terminate-instances --instance-ids "${ec2list}"
}
EOF
)
sync_zsh_block "$FUNCTION_BLOCK_START" "$FUNCTION_BLOCK_END" "$CUSTOM_FUNCTIONS"
echo "✅ Custom functions synced to .zshrc"

# Sync Zsh history settings
echo "🧠 Syncing Zsh history settings..."
HISTORY_BLOCK_START="# >>> ZSH HISTORY SETTINGS >>>"
HISTORY_BLOCK_END="# <<< ZSH HISTORY SETTINGS <<<"
HISTORY_SETTINGS=$(cat <<'EOF'
# History settings
HISTFILE=~/.zsh_history
HISTSIZE=10000             # Lines kept in memory
SAVEHIST=10000             # Lines saved to history file

setopt APPEND_HISTORY        # Don't overwrite history
setopt INC_APPEND_HISTORY    # Add commands to history immediately
setopt SHARE_HISTORY         # Share history across sessions
setopt HIST_IGNORE_DUPS      # Ignore duplicate consecutive entries
setopt HIST_IGNORE_ALL_DUPS  # Ignore all duplicates
setopt HIST_FIND_NO_DUPS     # Avoid duplicate entries when searching
setopt HIST_REDUCE_BLANKS    # Remove extra spaces
setopt HIST_VERIFY           # Confirm before executing from history
EOF
)
sync_zsh_block "$HISTORY_BLOCK_START" "$HISTORY_BLOCK_END" "$HISTORY_SETTINGS"
echo "✅ Zsh history settings synced to .zshrc"

# iTerm2 Keybinding: Ctrl+Backspace to delete previous word (send 0x17 / Ctrl-W)
echo ""
echo "⚠️  iTerm2 Key Binding Automation:"
echo "🔧 Setting up Ctrl + Backspace to delete the previous word (like Ctrl+W)"
defaults write com.googlecode.iterm2 "New Bookmarks" -array-add \
  "{
    Name = \"Default\";
    Shortcut = \"^?\";
    Action = 10;
    Text = \"\\U0017\";
    ModifierFlags = 262144;
  }"
echo "✅ iTerm2 key binding added (restart iTerm2 if needed)"

# Final output
echo ""
echo "🎉 Setup complete!"
echo "✅ Oh My Zsh configured"
echo "✅ Homebrew packages installed (if not CI)"
echo "✅ Starship prompt ready"
echo "✅ Custom Zsh functions, completion, and history settings applied"
echo ""
echo "⚠️  Don't forget: Open iTerm2 → Preferences → Profiles → Text → Change Font → Select 'Hack Nerd Font'"
echo "⚠️  Run 'exec zsh' or restart your terminal to apply changes"
