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

### Arch Linux
```bash
sudo pacman -Syu zsh git stow curl wget
```

### Ubuntu/Debian
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

The following tools are used throughout the configuration. Choose the installation method for your OS.

### macOS (Homebrew)
```bash
# CLI Utilities
brew install neovim bat ripgrep fzf fd zoxide eza ouch fastfetch btop yt-dlp ffmpeg lazygit tmux ghq hub git-lfs mise uv rmtrash pnpm

# GUI Applications
brew install --cask alacritty zed vscodium
```

### Arch Linux (Pacman & AUR)
```bash
# Core & CLI Tools
sudo pacman -S neovim bat ripgrep fzf fd zoxide eza ouch fastfetch btop yt-dlp ffmpeg lazygit tmux ghq hub git-lfs mise uv alacritty zed pnpm

# AUR Packages (using yay or paru)
yay -S vscodium-bin rmtrash pokeget-rs
```

### Ubuntu/Debian
```bash
# Standard Repositories
sudo apt install neovim bat ripgrep fzf fd-find zoxide btop ffmpeg tmux git-lfs rmtrash

# Mise (Environment Manager)
curl https://mise.jdx.dev/install.sh | sh

# Uv (Python Manager)
curl -LsSf https://astral.sh/uv/install.sh | sh

# Eza, Lazygit, Fastfetch, Ouch (Recommended via Pre-built Binaries or Official Repos)
# Please refer to their respective documentation for the latest installation methods on Debian-based systems.
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

