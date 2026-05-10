# 🌌 .dotfiles

A collection of configuration files for macOS and Linux (Arch/Debian), optimized for productivity, aesthetics, and a modern development workflow.

## ✨ Features

- **Shell**: Zsh managed by [Oh My Zsh](https://ohmyz.sh/) with custom plugins and themes.
- **Editors**:
  - **Neovim**: Powerful config using [Lazy.nvim](https://github.com/folke/lazy.nvim).
  - **Zed**: Modern, fast editor with custom settings.
  - **VSCodium**: Open-source binary of VS Code.
- **Terminal**: [Alacritty](https://alacritty.org/) with Catppuccin themes and Iosevka Nerd Font.
- **Tools**:
  - [mise](https://mise.jdx.dev/): Polyglot runtime manager (Node, Python, Rust, etc.).
  - [uv](https://github.com/astral-sh/uv): Ultra-fast Python package installer and resolver.
  - [git-delta](https://github.com/dandavison/delta): A syntax-highlighting pager for git.
  - [lazygit](https://github.com/jesseduffield/lazygit): Simple terminal UI for git commands.
  - [eza](https://github.com/eza-community/eza): A modern replacement for `ls`.
  - [zoxide](https://github.com/ajeetdsouza/zoxide): A smarter `cd` command.
- **System**:
  - Multi-OS support (macOS, Arch Linux, Debian/Ubuntu).
  - Automated installation script.
  - Managed by [GNU Stow](https://www.gnu.org/software/stow/) for clean symlinking.

## 🚀 Quick Start

Run the automated installer to set up your environment in minutes:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/pichayakorn/.dotfiles/main/install.sh)"
```

For detailed installation instructions, including manual steps and prerequisites, please refer to [SETUP.md](./SETUP.md).

## 📂 Structure

- `.config/`: Application-specific configurations (Alacritty, Nvim, Tmux, Zed, etc.).
- `.config/zsh/custom/`: Custom Zsh aliases, functions, and plugin scripts.
- `install.sh`: The main installation and setup script.
- `.stowrc`: Configuration for GNU Stow to manage symlinks correctly.

## 🛠 Manual Management

If you want to manually symlink files using Stow:

```bash
git clone https://github.com/pichayakorn/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
stow .
```

## 📜 License

This project is open-sourced under the MIT License. See the [LICENSE](LICENSE) file for details.
