#!/usr/bin/env bash

set -o errexit
set -o errtrace
set -o pipefail

set -x

# Allow overriding version for CI
VERSION="${VERSION:-v1.0.0}"
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

echo "🐟 Setting fish as the default shell..."

brew install fish || true

if ! grep -q "$(brew --prefix)/bin/fish" /etc/shells; then
  echo "$(brew --prefix)/bin/fish" | sudo tee -a /etc/shells
fi

chsh -s "$(brew --prefix)/bin/fish"

echo "✅ Default shell set to fish."

# Fetch and install starship.toml from the release
echo "✨ Configuring Starship..."
mkdir -p "${HOME}/.config"
curl --fail "$BASE_URL/starship.toml" -o "${HOME}/.config/starship.toml"

echo "✅ Bootstrap completed."
