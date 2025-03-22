#!/usr/bin/env bash

set -o errexit
set -o errtrace
set -o pipefail
set -o nounset

trap 'echo "❌ Error occurred at $BASH_SOURCE:$LINENO"' ERR

HOME="${HOME:-.}"
ZSHRC="$HOME/.zshrc"
VERSION=$(git rev-parse --short HEAD 2>/dev/null || echo "dev")

echo "🚀 macOS Development Environment Setup (Version: $VERSION)"

# Install Homebrew if needed
if ! command -v brew &>/dev/null; then
  echo "🍺 Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  echo "✅ Homebrew already installed."
fi

# Install shell-specific tools first
if [[ "${CI_MODE:-0}" -eq 0 ]]; then
  echo "🔧 Installing shell utilities from Brewfile.shell..."
  brew bundle --file=Brewfile.shell
else
  echo "🚀 CI Mode: Skipping Brewfile.shell (handled by CI)"
fi

echo "⚙️ Configuring Zsh, plugins, completions, history, and Starship..."

# Install Oh My Zsh if missing
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "✨ Installing Oh My Zsh..."
  export RUNZSH=no
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "✅ Oh My Zsh already installed."
fi

# Set Zsh as default shell
ZSH_BIN="/bin/zsh"
if ! grep -q "$ZSH_BIN" /etc/shells; then
  echo "$ZSH_BIN" | sudo tee -a /etc/shells
fi

if [ "$SHELL" != "$ZSH_BIN" ] && [[ "${CI_MODE:-0}" -eq 0 ]]; then
  chsh -s "$ZSH_BIN"
  echo "✅ Default shell changed to system Zsh."
else
  echo "✅ Default shell is already Zsh."
fi

# Add zsh-autosuggestions
if ! grep -q "^source \\\$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh\$" "$ZSHRC"; then
  echo "source \$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh" >> "$ZSHRC"
fi

# Ensure compinit is configured
if ! grep -q '^autoload -Uz compinit' "$ZSHRC"; then
  cat <<'EOF' >> "$ZSHRC"

# Zsh Completion System
autoload -Uz compinit
compinit -d "${ZDOTDIR:-$HOME}/.zcompdump"
EOF
fi

# Setup Starship prompt
mkdir -p "${HOME}/.config"
if ! diff -q "starship.toml" "${HOME}/.config/starship.toml" &>/dev/null; then
  cp "starship.toml" "${HOME}/.config/starship.toml"
  echo "✅ starship.toml updated."
else
  echo "✅ starship.toml is already up to date."
fi

if ! grep -q "^eval \"\\\$(starship init zsh)\"\$" "$ZSHRC"; then
  echo "eval \"\$(starship init zsh)\"" >> "$ZSHRC"
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

sed -i '' "/$FUNCTION_BLOCK_START/,/$FUNCTION_BLOCK_END/d" "$ZSHRC"
printf "\n%s\n%s\n%s\n" "$FUNCTION_BLOCK_START" "$CUSTOM_FUNCTIONS" "$FUNCTION_BLOCK_END" >> "$ZSHRC"
echo "✅ Custom functions synced to .zshrc"

# Sync Zsh history settings
echo "🧠 Syncing Zsh history settings..."
HISTORY_BLOCK_START="# >>> ZSH HISTORY SETTINGS >>>"
HISTORY_BLOCK_END="# <<< ZSH HISTORY SETTINGS <<<"
HISTORY_SETTINGS=$(cat <<'EOF'
# History settings
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY
EOF
)

sed -i '' "/$HISTORY_BLOCK_START/,/$HISTORY_BLOCK_END/d" "$ZSHRC"
printf "\n%s\n%s\n%s\n" "$HISTORY_BLOCK_START" "$HISTORY_SETTINGS" "$HISTORY_BLOCK_END" >> "$ZSHRC"
echo "✅ Zsh history settings synced to .zshrc"

# Install remaining tools and apps BEFORE iTerm2 bindings
if [[ "${CI_MODE:-0}" -eq 0 ]]; then
  echo "📦 Installing remaining tools from Brewfile.tools..."
  brew bundle --file=Brewfile.tools
else
  echo "🚀 CI Mode: Skipping Brewfile.tools (handled by CI)"
fi

# iTerm2 Keybinding setup (last step)
echo "🔧 Configuring iTerm2 key binding for Ctrl + Backspace (delete word)"
function configure_iterm2_keybinding() {
  PLIST=~/Library/Preferences/com.googlecode.iterm2.plist

  /usr/libexec/PlistBuddy -c "Delete :New\ Bookmarks" "$PLIST" || true
  /usr/libexec/PlistBuddy -c "Add :New\ Bookmarks array" "$PLIST"

  /usr/libexec/PlistBuddy -c "Add :New\ Bookmarks:0 dict" "$PLIST"
  /usr/libexec/PlistBuddy -c "Add :New\ Bookmarks:0:Shortcut string 0x7f" "$PLIST"
  /usr/libexec/PlistBuddy -c "Add :New\ Bookmarks:0:Action integer 10" "$PLIST"
  /usr/libexec/PlistBuddy -c "Add :New\ Bookmarks:0:Text string \u0017" "$PLIST"
  /usr/libexec/PlistBuddy -c "Add :New\ Bookmarks:0:ModifierFlags integer 262144" "$PLIST"

  echo "✅ iTerm2 keybinding updated via PlistBuddy. Restart iTerm2 to apply."
}


echo ""
echo "🎉 Setup complete!"
echo "✅ Oh My Zsh configured"
echo "✅ Zsh plugins, history, and completions ready"
echo "✅ Starship prompt configured"
echo "✅ Custom functions installed"
echo "✅ Tools installed"
echo ""
echo "💡 Next Step: Update iTerm2 key bindings manually"
echo "➡️ Open iTerm2 → Preferences → Profiles → Keys"
echo "➡️ Add a new key mapping:"
echo "    - Keyboard Shortcut: ⌃ (Control) + ⌫ (Backspace)"
echo "    - Action: Send Hex Code"
echo "    - Hex Code: 0x17 (This sends Ctrl+W)"
echo ""
echo "💡 Also, set your iTerm2 font to 'Hack Nerd Font' for best experience"
echo "💡 Run 'exec zsh' or restart your terminal"
