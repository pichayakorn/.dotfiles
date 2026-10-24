# 🌌 .dotfiles

A collection of configuration files for [Omarchy](https://omarchy.org), macOS and Arch Linux / EndeavourOS, optimized for productivity, aesthetics, and a modern development workflow. On Omarchy they're a thin layer on top of Omarchy's defaults; elsewhere they're the full setup.

## ✨ Features

- **Shell**: Bash on Omarchy, Zsh with [Oh My Zsh](https://ohmyz.sh/) elsewhere — aliases and functions are shared.
- **Editors** (macOS / Arch; Omarchy keeps its own LazyVim):
  - **Neovim**: Powerful config using [Lazy.nvim](https://github.com/folke/lazy.nvim).
  - **Zed**: Modern, fast editor with custom settings.
  - **VSCodium**: Open-source binary of VS Code.
- **Terminal**: [Alacritty](https://alacritty.org/) with Catppuccin themes and Iosevka Nerd Font (macOS / Arch; Omarchy keeps its own terminal and theme).
- **Git**: one SSH key for push/pull and signed commits, set up by `ssh-setup`.
- **Tools**:
  - [mise](https://mise.jdx.dev/): Polyglot runtime manager (Node, Python, Rust, etc.).
  - [uv](https://github.com/astral-sh/uv): Ultra-fast Python package installer and resolver.
  - [git-delta](https://github.com/dandavison/delta): A syntax-highlighting pager for git.
  - [lazygit](https://github.com/jesseduffield/lazygit): Simple terminal UI for git commands.
  - [eza](https://github.com/eza-community/eza): A modern replacement for `ls`.
  - [zoxide](https://github.com/ajeetdsouza/zoxide): A smarter `cd` command.
- **System**:
  - Multi-OS support (Omarchy, macOS, Arch Linux / EndeavourOS).
  - Automated installation script, safe to re-run, with a dry run and a log of every run.
  - Managed by [GNU Stow](https://www.gnu.org/software/stow/) for clean symlinking.

## 🚀 Quick Start

Run the automated installer to set up your environment in minutes:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/pichayakorn/.dotfiles/main/install.sh)"
```

[SETUP.md](./SETUP.md) has the details: installing from a clone, the installer's options, what it does on each system, SSH setup, logs and backups, and the manual steps.

## 📂 Structure

Configs are split into [GNU Stow](https://www.gnu.org/software/stow/) packages, grouped by where they apply:

| Group | Packages | Used on |
|---|---|---|
| `common/` | `git` `shell` `bin` `lazygit` `mise` `conda` | everywhere |
| `omarchy/` | `tmux` `hypr` `starship` `ssh` `hooks` | [Omarchy](https://omarchy.org) — layered on top of Omarchy's defaults |
| `standalone/` | `zsh` `git` `alacritty` `btop` `tmux` `nvim` `fastfetch` `zed` | macOS, Arch, EndeavourOS — full setup |
| `windows/` | `powershell` | not stowed by `install.sh` |

`./install.sh --list` prints the packages for the current machine.

- `common/shell/.config/shell/`: aliases, functions and fzf settings shared by bash and zsh (`rc.sh` is the entry point).
- `common/bin/.local/bin/`: personal commands on `PATH`: `dlmusic` and `yt-split` (zsh scripts, so `zsh` is installed on every machine as their interpreter, even where bash is the login shell), plus `ssh-setup`, `dotfiles-check` and `git-ssh-sign`.
- `standalone/git/.config/git/config`: an unmodified copy of Omarchy's git defaults (rebase on pull, auto upstream on push, histogram diffs, rerere), so the Mac behaves the same; `~/.gitconfig` is read after it and wins. `dotfiles-check` on Omarchy flags when Omarchy changes it, and `--accept` refreshes the copy.
- `templates/gitconfig.local`: per-machine git settings (signing key, work identity), copied to `~/.gitconfig.local`.

### On Omarchy

**Rule: Omarchy owns everything; this repo holds only your differences, in your own files.** Where Omarchy owns a file, `install.sh` adds one line that loads yours:

| Omarchy's file | Gets one line loading | Yours |
|---|---|---|
| `~/.bashrc` | `~/.config/shell/rc.sh` | aliases, functions, fzf |
| `~/.config/tmux/tmux.conf` | `tmux.local.conf` | prefix `C-t`, vim panes, `\|`/`-` splits |
| `~/.config/hypr/hyprland.lua` | `hypr/hachi.lua` | natural scrolling |

Other layers need no line: `~/.gitconfig` overrides Omarchy's `~/.config/git/config`, `mise/conf.d/hachi.toml` sits next to Omarchy's `config.toml`, colors follow `omarchy theme`. The one copy you own is `starship.toml` (Omarchy's prompt + Node/Python versions in projects), because starship can't include another file.

SSH (package `omarchy/ssh`, self-contained: copy that folder to share it): one key (`~/.ssh/id_ed25519`, with passphrase) for push/pull and signing. `ssh-agent.socket` + `environment.d` serve it to every process. Right after login a `post-boot` hook (`ssh-unlock`) asks for the passphrase in a themed floating prompt (`ssh-askpass-gum`), so the key stays unlocked until logout, even for AI agents. Cancel it and the first push, pull or signed commit asks instead (`git-ssh-sign` loads the key for signing like `AddKeysToAgent` does for push/pull). On a new machine, `install.sh` offers to run `ssh-setup --remote`, which creates the key, `~/.ssh/config`, `allowed_signers` and the signing settings in `~/.gitconfig.local`, registers the key on GitHub (with `gh`) and switches this repo to ssh.

### Keeping up with Omarchy

```bash
dotfiles-check            # links, the hook lines, SSH agent, signing, Omarchy changes to starship.toml
dotfiles-check --online   # also test GitHub SSH access
ssh-setup --remote        # new machine: SSH key for push/pull + signing, registered on GitHub
dotfiles-check --accept   # after merging Omarchy's starship change into yours: new baseline, then commit
```

`upstream/omarchy/starship` is Omarchy's prompt as you last reviewed it, so the check shows only Omarchy's changes. A `post-update` hook runs the check after every `omarchy update` and notifies you only if something needs a look. If a refresh resets one of Omarchy's files, `./install.sh --link-only` adds the line back.

### Maintaining it

1. Use Omarchy's default first; add something only after you've missed it twice.
2. Add, don't replace: your own small file + one line, never a copy of Omarchy's file.
3. Edit through the links (`~/.config/shell/aliases.sh` is the repo file), then `git diff` and commit.
4. Prune now and then: aliases and packages you no longer use.

## 🛠 Manual Management

Preview with `./install.sh --dry-run`, re-link after changes with `./install.sh --link-only`. Manual stow commands are in [SETUP.md](./SETUP.md#-manual-installation-macos--arch); never run `stow .` on the repo root.

## 📜 License

This project is open-sourced under the MIT License. See the [LICENSE](LICENSE) file for details.
