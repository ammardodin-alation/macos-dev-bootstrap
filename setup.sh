#!/usr/bin/env bash

set -o errexit
set -o errtrace
set -o pipefail

if [[ -n "${DEBUG}" ]]; then
    set -x
fi

# x-release-please-start-version
TAG=v0.0.0
# x-release-please-end

FALLBACK_TAG="v1.0.0"

VERSION="${VERSION:-FALLBACK_TAG}"
HOME="${HOME:-.}"
REPO="ammardodin-alation/macos-dev-bootstrap"
BASE_URL="https://raw.githubusercontent.com/$REPO/$VERSION"

echo "🚀 Setting up macOS Development Environment (Version: $VERSION)"

ls -alh

# Fetch and use the Brewfile from the specific version
echo "📦 Fetching Brewfile..."
echo "ok"
curl --fail "$BASE_URL/Brewfile" -o ./Brewfile
brew bundle --file=./Brewfile || true

echo "✨ Installing Oh My Zsh..."
export RUNZSH=no
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

echo "🐚 Setting Zsh as the default shell..."
if ! grep -q "$(brew --prefix)/bin/zsh" /etc/shells; then
  echo "$(brew --prefix)/bin/zsh" | sudo tee -a /etc/shells
fi
chsh -s "$(brew --prefix)/bin/zsh"

echo "✨ Installing zsh-autosuggestions plugin..."
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

echo "✨ Configuring Oh My Zsh plugins..."
sed -i '' '/^plugins=/d' ~/.zshrc
echo 'plugins=(git kubectl pyenv zsh-autosuggestions)' >> ~/.zshrc

# Fetch and install starship.toml from the release
echo "✨ Configuring Starship..."
mkdir -p "${HOME}/.config"
curl --fail "$BASE_URL/starship.toml" -o "${HOME}/.config/starship.toml"

echo "✨ Ensuring Starship is configured in Zsh..."
if ! grep -q 'eval "$(starship init zsh)"' ~/.zshrc; then
  echo 'eval "$(starship init zsh)"' >> ~/.zshrc
fi

echo "⚠️  Open iTerm2 → Preferences → Profiles → Text → Change Font → Select 'Hack Nerd Font'"

echo "✅ Bootstrap completed."
