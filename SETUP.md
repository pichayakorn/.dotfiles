# Machine Setup Guide

This guide explains how to set up a new machine (macOS or Linux) using these dotfiles.

## 1. Prerequisites

Ensure you have the following installed on your system:

- **Zsh**: The primary shell.
- **Git**: For version control.
- **GNU Stow**: For managing symlinks.
- **Curl/Wget**: For downloading installers.

### macOS (using Homebrew)
```bash
brew install zsh git stow curl wget
```

### Linux (Ubuntu/Debian)
```bash
sudo apt update && sudo apt install zsh git stow curl wget
```

## 2. Clone the Dotfiles

Clone this repository into your home directory as `~/.dotfiles`:

```bash
git clone https://github.com/pichayakorn/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

## 3. Install Oh My Zsh

The Zsh configuration relies on Oh My Zsh:

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

*Note: You might need to remove the default `~/.zshrc` created by Oh My Zsh before symlinking.*

## 4. Install Necessary Tools

The following tools are used throughout the configuration:

- **Editors**: `nvim` (Neovim)
- **CLI Utilities**: `bat`, `ripgrep` (`rg`), `peco`, `zoxide`, `ouch`, `fastfetch`, `btop`, `yt-dlp`, `ffmpeg`, `commitizen`, `mise`, `uv`
- **Git Enhancements**: `ghq`, `hub`, `git-lfs`
- **Language Management**: `mise` (replaces nvm, nodenv, conda), `uv` (fast Python package manager)

### Recommended Installation (macOS)
```bash
brew install neovim bat ripgrep peco zoxide ouch fastfetch btop yt-dlp ffmpeg ghq hub git-lfs commitizen mise uv
```

## 5. Apply Dotfiles (Symlinking)

Use GNU Stow to symlink the configuration files to your home directory:

```bash
cd ~/.dotfiles
stow .
```

This will create symlinks for `.zshrc`, `.gitconfig`, `.config/`, etc., in your `$HOME` directory. The `.stowrc` file in this repository is pre-configured to ignore setup files, backups, and logs automatically.

## 6. Download ZSH Plugins

Run the provided script to download custom ZSH plugins:

```bash
bash ~/.config/zsh/custom/scripts/download-plugins.sh
```

## 7. Initialize Mise

Mise handles your language versions (Node, Python, etc.). After symlinking your dotfiles, install the default tools defined in `~/.config/mise/config.toml`:

```bash
mise install
```

This will install the latest Python and the LTS version of Node.js as configured.

## 8. Final Steps

- **Neovim**: Run `nvim` to let the plugin manager (Lazy.nvim) install all plugins.
- **GPG**: If you use GPG for signing commits, import your keys and ensure `gpg` is configured.
- **Fonts**: This setup is optimized for **IosevkaTerm Nerd Font** (used in Alacritty). You can find it at [Nerd Fonts](https://www.nerdfonts.com/font-downloads).
- **Commitizen**: Ensure `cz-conventional-changelog` is installed globally if you use `git cz`.
  ```bash
  npm install -g commitizen cz-conventional-changelog
  ```

Reload your shell:
```bash
source ~/.zshrc
```
