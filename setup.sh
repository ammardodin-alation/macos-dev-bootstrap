#!/usr/bin/env bash

set -o errexit
set -o errtrace
set -o pipefail

# Allow overriding version for CI
VERSION="${VERSION:-v1.0.0}"
REPO="ammardodin-alation/macos-dev-bootstrap"
BASE_URL="https://raw.githubusercontent.com/$REPO/$VERSION"

echo "🚀 Setting up macOS Development Environment (Version: $VERSION)"

# Fetch and use the Brewfile from the specific version
echo "📦 Fetching Brewfile..."
curl "$BASE_URL/Brewfile" -o ./Brewfile
brew bundle --file=./Brewfile

# Optional: Setup Python environment
echo "🐍 Setting up Python environment..."
pyenv install 3.11.7 || true
pyenv global 3.11.7

# Fetch and install starship.toml from the release
echo "✨ Configuring Starship..."
mkdir -p ~/.config
curl "$BASE_URL/starship.toml" -o ~/.config/starship.toml

echo "✅ Bootstrap completed."
