# Machine Setup Guide

This guide explains how to set up a new machine (macOS or Linux) using these dotfiles.

> **Omarchy:** use the installer. It keeps Omarchy's bash, terminal, Neovim and theming, and only hooks your own files into `~/.bashrc` and `tmux.conf` with one line each. Never run `stow .` on the repo root.

## 🚀 Automated Installation (Recommended)

You can set up everything with a single command:

```bash
# Using bash-c (Safest - downloads entire script before execution)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/pichayakorn/.dotfiles/main/install.sh)"

# OR using a pipe
curl -fsSL https://raw.githubusercontent.com/pichayakorn/.dotfiles/main/install.sh | bash
```

Alternatively, you can clone the repository and run the installer locally:

```bash
git clone https://github.com/pichayakorn/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

The script will handle package manager updates, tool installations via Brew/Pacman, symlinking with GNU Stow, and ZSH plugin setup.

---

## 🛠 Manual Installation

If you prefer to set up everything manually, follow these steps:

### 1. Install Prerequisites

Ensure you have the following installed on your system:

- **Zsh**: The primary shell.
- **Git**: For version control.
- **GNU Stow**: For managing symlinks.
- **Curl/Wget**: For downloading installers.

#### macOS (using Homebrew)
```bash
brew install zsh git stow curl wget
```

#### Arch Linux / Manjaro / Omarchy / EndeavourOS
```bash
sudo pacman -Syu zsh git stow curl wget
```

### 2. Clone the Dotfiles

Clone this repository into your home directory as `~/.dotfiles`:

```bash
git clone https://github.com/pichayakorn/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

### 3. Install Oh My Zsh

The Zsh configuration relies on Oh My Zsh:

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

*Note: You might need to remove the default `~/.zshrc` created by Oh My Zsh before symlinking.*

### 4. Install Necessary Tools

The following tools are used throughout the configuration. Choose the installation method for your OS.

#### macOS (Homebrew)
The package list lives in [`Brewfile`](./Brewfile) (CLI tools, apps and the IosevkaTerm Nerd Font):
```bash
brew bundle --file=~/.dotfiles/Brewfile
```

#### Arch Linux / Manjaro / Omarchy / EndeavourOS (Pacman & AUR)
```bash
# Core & CLI Tools
sudo pacman -S neovim bat ripgrep fzf fd zoxide eza ouch fastfetch btop yt-dlp ffmpeg lazygit git-delta tmux ghq github-cli git-lfs mise alacritty zed ttf-iosevkaterm-nerd discord

# AUR Packages (using yay, paru, or pamac; not needed on Omarchy)
yay -S vscodium-bin
# or
pamac install vscodium-bin

# pokeget (for `ffp`) comes from mise on every machine: `mise install`
```

### 5. Apply Dotfiles (Symlinking)

Use GNU Stow to symlink the packages for your machine (see the Structure table in the README):

```bash
cd ~/.dotfiles
stow -d common git shell bin lazygit mise conda
stow -d standalone zsh git alacritty btop tmux nvim fastfetch zed   # macOS / Arch
# stow -d omarchy tmux hypr starship                 # Omarchy instead of standalone (use install.sh: it also adds the source lines)
```

Stow refuses to replace existing files. Move them aside first, or let `./install.sh --link-only` back them up for you.

### 6. Download ZSH Plugins

Run the provided script to download custom ZSH plugins:

```bash
bash ~/.config/zsh/custom/scripts/download-plugins.sh   # zsh (standalone) only
```

### 7. Initialize Mise

Mise handles your language versions (Node, Python, etc.). After symlinking your dotfiles, install the default tools defined in `~/.config/mise/config.toml`:

```bash
mise install
```

### 8. Final Steps

- **Neovim**: Run `nvim` to let the plugin manager (Lazy.nvim) install all plugins.
- **GPG**: If you sign commits, import your key and enable signing in `~/.gitconfig.local` (template: `templates/gitconfig.local`).
- **Fonts**: This setup is optimized for **IosevkaTerm Nerd Font** (package: `ttf-iosevkaterm-nerd` or `font-iosevka-term-nerd-font`). You can find it at [Nerd Fonts](https://www.nerdfonts.com/font-downloads).
- **Conventional commits**: `czg` is installed by `mise install` (see `~/.config/mise/conf.d/hachi.toml`). Run `czg` in a repo, or press `C` in lazygit.

Reload your shell:
```bash
source ~/.zshrc
```
