# 🚀 macOS Dev Bootstrap

This repository provides a simple, testable way to bootstrap a macOS development machine with a fundamental set of tools.

## ✅ Features
- Python (via `pyenv`) and Terraform (`tfenv`) version management
- Fish shell and Starship prompt setup
- CI validation of the bootstrap process

## 📦 Included Tools
- jq, yq, pyenv, fish, starship, htop, ripgrep, curl, kubectl, kubectx
- Terraform and tfenv
- Visual Studio Code and OrbStack

## 🔧 Usage

### 🚀 Run Directly from GitHub (versioned release)
You can fetch and run the bootstrap script from a specific tag:

```
curl -fsSL https://raw.githubusercontent.com/your-org/macos-dev-bootstrap/v1.0.0/setup.sh | bash
```

✅ Replace `v1.0.0` with any release tag you want to pin.

## 🔄 CI Automation
This repo includes a GitHub Actions workflow that:
- Lints the setup script with shellcheck
- Runs the bootstrap on `macos-latest`
- Verifies tool installation

Run it via:
```
github actions / .github/workflows/ci.yml
```

## 🛠 Customization
- Update `setup.sh` to customize Python/Terraform versions or shell behavior
