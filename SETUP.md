# Machine Setup Guide

How to install these dotfiles on a machine. For what's in the repo and why it's organised this way, see the [README](./README.md).

`install.sh` detects the machine and picks a profile:

- **Omarchy**: layers your files on top of Omarchy's defaults (bash, its terminal, Neovim and theming stay Omarchy's).
- **standalone** (macOS, Arch, EndeavourOS): the full setup, with zsh, Oh My Zsh, Alacritty, Neovim and the rest.

It's safe to run on a machine that's already set up: it skips what's done, never deletes your files, and is also how you repair a machine after something drifts.

## 🚀 Install

**Option 1: one command.** The script clones the repo to `~/.dotfiles` (or `$DOTFILES_DIR`) and installs from there:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/pichayakorn/.dotfiles/main/install.sh)"
```

**Option 2: clone it yourself.** Use any folder; the script uses the repo it lives in:

```bash
git clone https://github.com/pichayakorn/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh --dry-run   # optional: preview, changes nothing
./install.sh
```

Option 1 always installs `main`. To try a branch, use option 2 and `git switch <branch>` before running the script.

If the repo folder already exists, the script uses it as it is (no `git pull`). On an existing machine, pull first.

### Options

| Option | What it does |
|---|---|
| `--dry-run` | Show what would be installed, backed up, linked and hooked up; change nothing |
| `--link-only` | Skip packages, Oh My Zsh, zsh plugins and `mise install`; still backs up, links, adds the hook lines, offers SSH setup and runs the check |
| `--list` | Print this machine's stow packages |

## What the installer does

### On Omarchy

1. **Packages**: installs only what Omarchy doesn't ship: `stow git-delta ghq git-lfs ouch zsh wget` (zsh only runs the scripts in `~/.local/bin`; your login shell stays bash). No system upgrade: that's `omarchy update`'s job.
2. **Links** the `common/` and `omarchy/` packages into `~`. Files in the way are moved to the backup folder (see [Logs and backups](#logs-and-backups)).
3. **Hook lines**: adds one line each to `~/.bashrc`, `~/.config/hypr/hyprland.lua` and `~/.config/tmux/tmux.conf` that loads your file, and enables `ssh-agent.socket`.
4. **`~/.gitconfig.local`**: copied from `templates/gitconfig.local` if it doesn't exist.
5. **`mise install`**: your tools from `~/.config/mise/conf.d/hachi.toml` (`bun`, `uv`, `czg`, `pokeget`; plus `yt-dlp` on ARM, where the pacman build lags).
6. **SSH**: if there's no `~/.ssh/id_ed25519`, asks whether to run `ssh-setup --remote` (see [SSH and commit signing](#-ssh-and-commit-signing)).
7. **Check**: runs `dotfiles-check`.

Then open a new terminal, and log out and back in so the SSH agent and its passphrase prompt are active everywhere.

### On macOS / Arch / EndeavourOS

1. **Packages**:
   - macOS: Homebrew if missing, then the [`Brewfile`](./Brewfile) (CLI tools, apps, IosevkaTerm Nerd Font). On the first run it asks for a custom folder for apps (e.g. an external SSD), saved in `~/.zshrc.local`.
   - Arch / EndeavourOS: a full `pacman -Syu` with the CLI tools, Alacritty, Zed and the font; `vscodium-bin` from the AUR if `yay`, `paru` or `pamac` is available.
2. **Oh My Zsh**, if missing.
3. **Neovim data**: the first time your Neovim config replaces another one, the old `~/.local/share/nvim`, `~/.local/state/nvim` and `~/.cache/nvim` are renamed to `*.bak_<time>`.
4. **Links** the `common/` and `standalone/` packages into `~`, backing up files in the way.
5. **`~/.gitconfig.local`**, **zsh plugins** (`download-plugins.sh`), **`mise install`**, **SSH** and the **check**, as on Omarchy.
6. Restarts your shell as a zsh login shell.

Afterwards: open `nvim` once so Lazy.nvim installs its plugins, and set your terminal font to **IosevkaTerm Nerd Font**.

## 🔑 SSH and commit signing

One key, `~/.ssh/id_ed25519` (with a passphrase), for GitHub push/pull and for signing commits. `ssh-setup --remote`:

1. creates the key if missing,
2. adds a `github.com` entry to `~/.ssh/config` and your key to `~/.ssh/allowed_signers`,
3. turns on SSH signing for commits and tags in `~/.gitconfig.local`,
4. logs in to `gh` in the browser and registers the key on GitHub as an authentication key and a signing key,
5. switches this repo's `origin` to SSH, then tests GitHub access.

It's safe to re-run anytime to re-check the setup. For GPG signing instead (e.g. the Mac), import your key and enable it in `~/.gitconfig.local` (template: `templates/gitconfig.local`).

## ✅ After installing

```bash
dotfiles-check            # links, hook lines, commands, mise tools, SSH agent, signing, Omarchy drift
dotfiles-check --online   # also test GitHub SSH access
```

### Logs and backups

Everything a run leaves behind is in `~/.local/state/dotfiles/`, matched by timestamp:

```
logs/install-<time>.log    what the run did; install-latest.log points to the newest (the last 10 are kept)
backups/<time>/            files that run moved out of the way (never deleted automatically)
```

Passwords and passphrases are typed straight into the terminal and never reach the log. Runs before this layout left backups in `~/dotfiles_backup_<time>/`; the next run moves them here.

## 🛠 Manual installation (macOS / Arch)

Prefer the installer. On **Omarchy, always use the installer**: it also adds the hook lines and turns on the SSH agent. **Never run `stow .` on the repo root.**

1. **Prerequisites**:
   ```bash
   brew install git stow curl wget              # macOS (zsh is built in)
   sudo pacman -Syu zsh git stow curl wget      # Arch / EndeavourOS
   ```
2. **Clone** the repo (see [Install](#-install), option 2).
3. **Oh My Zsh**:
   ```bash
   sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
   ```
4. **Tools**:
   ```bash
   brew bundle --file=Brewfile                  # macOS
   sudo pacman -S --needed neovim bat ripgrep fzf fd zoxide eza ouch fastfetch btop yt-dlp ffmpeg lazygit \
     git-delta tmux ghq github-cli git-lfs mise alacritty zed ttf-iosevkaterm-nerd discord   # Arch
   yay -S vscodium-bin                          # Arch, AUR (or paru / pamac)
   ```
5. **Link**: these folders must be real folders, so stow links files into them rather than replacing them with a link:
   ```bash
   mkdir -p ~/.local/bin ~/.config/git
   stow -d common -t ~ git shell bin lazygit mise conda
   stow -d standalone -t ~ zsh git alacritty btop tmux nvim fastfetch zed
   ```
   `./install.sh --list` prints the current package lists. Stow refuses to replace existing files: move them aside first, or use `./install.sh --link-only`, which backs them up.
6. **Per-machine git settings**: `cp templates/gitconfig.local ~/.gitconfig.local`
7. **zsh plugins**: `bash ~/.config/zsh/custom/scripts/download-plugins.sh`
8. **mise tools**: `mise install`
9. **SSH and signing**: `ssh-setup --remote`
10. **Check**: `dotfiles-check`, then start a new shell (`exec zsh -l`).

**Conventional commits:** `czg` comes from `mise install`. Run `czg` in a repo, or press `C` in lazygit.
