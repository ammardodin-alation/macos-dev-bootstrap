# 🚀 macOS Dev Environment Setup

This project bootstraps a fully-featured macOS development environment, handling shell setup, essential tools, and terminal enhancements in a clean, modular flow.

## 📚 Table of Contents
- [🧰 CLI Tools Installed](#-cli-tools-installed-via-homebrew)
- [🖥️ GUI Applications](#️-gui-applications-via-homebrew-cask)
- [🐚 Zsh Configuration](#-zsh-configuration)
- [🌟 Starship Prompt Customization](#-starship-prompt-customization)
- [🛠 Execution Flow](#-execution-flow)
- [🎯 iTerm2 Enhancements](#-iterm2-enhancements)
- [✅ CI Validated](#-ci-validated-github-actions)
- [🚀 Usage](#-usage)
- [🛠 After Running](#-after-running)
- [🎉 Result](#-result)

## 🧰 CLI Tools Installed (via Homebrew)

- **Cloud & DevOps**: `awscli`, `gh`, `helm`, `kubectl`, `kubectx`, `tfenv`
- **Productivity**: `ripgrep`, `jq`, `yq`, `watch`, `tree`, `htop`, `neofetch`, `pyenv`, `curl`
- **Shell Enhancements**: `zsh-autosuggestions`, `starship`

## 🖥️ GUI Applications (via Homebrew Cask)

- `iterm2` – Terminal replacement
- `font-hack-nerd-font` – Nerd Font for rich prompts
- `orbstack` – Docker/Kubernetes manager
- `postman` – API testing
- `visual-studio-code` – Code editor

## 🐚 Zsh Configuration

- Installs **Oh My Zsh** and sets Zsh as the default shell
- Adds **zsh-autosuggestions** plugin
- Configures **compinit** for completions
- Injects custom functions:
  - 📜 Git log formatter
  - ☁️ AWS EC2 helpers (list & terminate instances)
- Adds Zsh history optimizations
- Initializes **Starship prompt**

## 🌟 Starship Prompt Customization

- Clean, icon-enhanced prompt featuring:
  - 🐍 Python
  - 🛠️ Terraform
  - ☸️ Kubernetes
  - ➜ Success symbol
- Configurable via `starship.toml`

## 🛠 Execution Flow

1. Install **shell essentials** (`Brewfile.shell`) – `starship`, `zsh-autosuggestions`, `pyenv`
2. Configure **Zsh**: completions, history, plugins, Starship
3. Install **tools and apps** (`Brewfile.tools`) – AWS CLI, Kubernetes tools, VS Code, etc.
4. **Configure iTerm2 key bindings** as the final step

## 🎯 iTerm2 Enhancements

- Automatically maps `Ctrl + Backspace` to **delete the previous word**
- Recommends **Hack Nerd Font** for proper icon and glyph rendering

## ✅ CI Validated (GitHub Actions)

- Runs on:
  - **macOS Intel (`macos-13`)**
  - **Apple Silicon (`macos-14`)**
- Validates:
  - `.zshrc` configuration
  - Starship prompt setup
  - Custom functions and completions

## 🚀 Usage

```bash
chmod +x setup.sh
./setup.sh
```

## 🛠 After Running

1. Open **iTerm2**
2. Go to **Preferences → Profiles → Text**
3. Set the font to **Hack Nerd Font**
4. Restart iTerm2 or run `exec zsh`

## 🎉 Result

✅ Fully configured Zsh environment with Starship prompt  
✅ Cloud, Kubernetes, Python, and Terraform ready  
✅ Zsh completions, history settings, and custom AWS helpers  
✅ Beautiful, minimal Starship-powered terminal  
✅ iTerm2 key binding and Nerd Font support  
✅ CI-tested on both Intel and Apple Silicon Macs
