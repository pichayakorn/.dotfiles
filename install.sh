#!/usr/bin/env bash

# Stop on error and undefined variables
set -eu

info() { printf '\033[0;36m[INFO]\033[0m %s\n' "$1"; }
warn() { printf '\033[1;33m[WARN]\033[0m %s\n' "$1"; }
error() { printf '\033[0;31m[ERROR]\033[0m %s\n' "$1"; }
success() { printf '\033[0;32m[SUCCESS]\033[0m %s\n' "$1"; }

usage() {
    echo "Usage: install.sh [--dry-run] [--link-only] [--list]"
    echo "  --dry-run    Show what would be backed up and linked; change nothing"
    echo "  --link-only  Skip package installation, only back up and stow"
    echo "  --list       Print this machine's stow packages (used by dotfiles-check)"
}

DRY_RUN=false
LINK_ONLY=false
LIST=false
for arg in "$@"; do
    case "$arg" in
        --dry-run) DRY_RUN=true; LINK_ONLY=true ;;
        --link-only) LINK_ONLY=true ;;
        --list) LIST=true ;;
        -h|--help) usage; exit 0 ;;
        *) error "Unknown option: $arg"; usage; exit 1 ;;
    esac
done

# Detect OS / profile
#   omarchy    -> Omarchy owns the desktop, shell (bash), terminal and theming;
#                 we only layer personal settings on top.
#   standalone -> Arch/EndeavourOS/Manjaro or macOS: full zsh/alacritty/btop/tmux/nvim setup.
OS="$(uname -s)"
case "$OS" in
    Darwin) DISTRO="macOS" ;;
    Linux)
        ID="" ID_LIKE=""
        [ -f /etc/os-release ] && . /etc/os-release
        if [[ "$ID" == "omarchy" || -d /usr/share/omarchy ]]; then DISTRO="Omarchy"
        elif [[ "$ID $ID_LIKE" == *arch* || -f /etc/arch-release ]]; then DISTRO="Arch"
        else DISTRO="Linux"; fi
        ;;
    *) DISTRO="UNKNOWN" ;;
esac

# Stow packages per profile (directories under common/, omarchy/, standalone/), and the
# real directories stow links files into instead of folding them into one repo link
# (other tools write there too)
COMMON_PACKAGES=(git shell bin lazygit mise conda)
if [[ "$DISTRO" == "Omarchy" ]]; then
    PROFILE="omarchy"
    # Omarchy keeps owning ~/.bashrc and tmux.conf (its migrations edit them);
    # step 5b only adds one line to each that loads your files.
    PROFILE_PACKAGES=(tmux hypr starship ssh hooks)
    REAL_DIRS=(.local/bin .config/environment.d)
    # What Omarchy doesn't ship (dotfiles-check verifies the commands)
    OMARCHY_PACMAN=(stow git-delta ghq git-lfs ouch zsh wget)
else
    PROFILE="standalone"
    PROFILE_PACKAGES=(zsh git alacritty btop tmux nvim fastfetch zed)
    REAL_DIRS=(.local/bin .config/git)
fi

if $LIST; then
    printf 'common/%s\n' "${COMMON_PACKAGES[@]}"
    printf "$PROFILE/%s\n" "${PROFILE_PACKAGES[@]}"
    exit 0
fi

# Everything a run leaves behind lives in one place, matched by timestamp:
#   logs/install-<time>.log   what the run did (the last 10 are kept)
#   backups/<time>/           files it moved out of the way (never deleted automatically)
# Log everything to a file as well (read it later, or hand it to an AI agent).
# Passwords and passphrases are typed straight into the terminal, never into the log.
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles"
LOG_DIR="$STATE_DIR/logs"
LOG_FILE="$LOG_DIR/install-$TIMESTAMP.log"
BACKUP_DIR="$STATE_DIR/backups/$TIMESTAMP"
mkdir -p "$LOG_DIR"
ln -sfn "install-$TIMESTAMP.log" "$LOG_DIR/install-latest.log"
exec 3>&1 4>&2 # the terminal, for interactive steps and the final `exec zsh`
exec > >(tee -a "$LOG_FILE") 2>&1
TEE_PID=$!
# On any exit (also errors): let the log catch up before the prompt returns
trap 'exec 1>&3 2>&4; wait "$TEE_PID" 2>/dev/null || true' EXIT
info "Logging to $LOG_FILE (options: ${*:-none})"

# Move logs and backups from the earlier layout (~/dotfiles_backup_<time>/, logs
# directly in $STATE_DIR), then keep only the last 10 logs
shopt -s nullglob
for old in "$HOME"/dotfiles_backup_2* "$STATE_DIR"/install-2*.log; do
    case "$old" in
        *.log) new="$LOG_DIR/${old##*/}" ;;
        *) new="$STATE_DIR/backups/${old##*/dotfiles_backup_}" ;;
    esac
    if $DRY_RUN; then
        info "Would move $old to $new"
    else
        mkdir -p "$(dirname "$new")" && mv -n "$old" "$new" && info "Moved $old to $new"
    fi
done
if ! $DRY_RUN; then
    [ -L "$STATE_DIR/install-latest.log" ] && rm "$STATE_DIR/install-latest.log"
    logs=("$LOG_DIR"/install-2*.log)
    if (( ${#logs[@]} > 10 )); then rm -f "${logs[@]:0:${#logs[@]}-10}"; fi
fi
shopt -u nullglob

info "Detected OS: $OS ($DISTRO)"

# 0. Locate (or clone) the dotfiles
# Use the repo this script lives in; fall back to ~/.dotfiles for curl | bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd -P || true)"
if [[ -n "$SCRIPT_DIR" && -d "$SCRIPT_DIR/common" && -f "$SCRIPT_DIR/install.sh" ]]; then
    DOTFILES_DIR="$SCRIPT_DIR"
else
    DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
fi

if [ ! -d "$DOTFILES_DIR" ]; then
    if ! command -v git &> /dev/null && [[ "$DISTRO" == "Arch" || "$DISTRO" == "Omarchy" ]]; then
        info "Git not found. Installing git..."
        sudo pacman -S --needed --noconfirm git
    fi
    info "Cloning dotfiles to $DOTFILES_DIR..."
    git clone https://github.com/pichayakorn/.dotfiles.git "$DOTFILES_DIR"
fi
info "Using dotfiles at $DOTFILES_DIR (profile: $PROFILE)"

# 1. Packages
if ! $LINK_ONLY; then
    if [[ "$DISTRO" == "macOS" ]]; then
        # Custom cask appdir (e.g. an external SSD), asked once and kept in the
        # untracked ~/.zshrc.local
        LOCAL_ZSH="$HOME/.zshrc.local"
        if [[ -z "${HOMEBREW_CASK_OPTS:-}" ]] && grep -qs '^export HOMEBREW_CASK_OPTS=' "$LOCAL_ZSH"; then
            eval "$(grep '^export HOMEBREW_CASK_OPTS=' "$LOCAL_ZSH" | tail -n 1)"
        fi
        if [[ -z "${HOMEBREW_CASK_OPTS:-}" ]]; then
            printf '\033[0;36m[INPUT]\033[0m Custom directory for Homebrew Casks (e.g. external SSD)? Enter to keep /Applications: '
            read -r CUSTOM_APPDIR || CUSTOM_APPDIR=""
            if [ -n "$CUSTOM_APPDIR" ]; then
                export HOMEBREW_CASK_OPTS="--appdir=$CUSTOM_APPDIR"
                printf '\n# Homebrew Cask custom directory\nexport HOMEBREW_CASK_OPTS="--appdir=%s"\n' "$CUSTOM_APPDIR" >> "$LOCAL_ZSH"
                info "Casks go to $CUSTOM_APPDIR (saved in $LOCAL_ZSH)"
            fi
        fi

        if ! command -v brew &> /dev/null; then
            info "Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            for brew_bin in /opt/homebrew/bin/brew /usr/local/bin/brew; do
                if [ -x "$brew_bin" ]; then eval "$("$brew_bin" shellenv)"; break; fi
            done
        fi
        info "Installing packages from Brewfile..."
        brew bundle --file="$DOTFILES_DIR/Brewfile"
    elif [[ "$DISTRO" == "Arch" ]]; then
        info "Updating the system and installing packages..."
        sudo pacman -Syu --needed --noconfirm zsh git stow curl wget \
            neovim bat ripgrep fzf fd zoxide eza ouch fastfetch btop yt-dlp ffmpeg lazygit \
            git-delta tmux ghq github-cli git-lfs mise alacritty zed ttf-iosevkaterm-nerd discord
    elif [[ "$DISTRO" == "Omarchy" ]]; then
        # No -Syu: system upgrades go through `omarchy update`. Omarchy already ships
        # neovim, bat, rg, fzf, fd, zoxide, eza, btop, lazygit, tmux, mise, gh (via mise),
        # a terminal and fonts. zsh is only the interpreter for ~/.local/bin scripts
        # (dlmusic, yt-split); the login shell stays bash.
        info "Installing packages..."
        sudo pacman -S --needed --noconfirm "${OMARCHY_PACMAN[@]}"
    fi

    # 2. Oh My Zsh (standalone only; Omarchy uses bash)
    if [[ "$PROFILE" == "standalone" && ! -d "$HOME/.oh-my-zsh" ]]; then
        info "Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi

    # 3. AUR packages (Arch only; a failure here doesn't stop the setup).
    # pokeget comes from mise (prebuilt binary), see common/mise.
    if [[ "$DISTRO" == "Arch" ]]; then
        AUR_PACKAGES=(vscodium-bin)
        AUR_HELPER="$(command -v yay || command -v paru || true)"
        if [ -n "$AUR_HELPER" ]; then
            "$AUR_HELPER" -S --needed --noconfirm "${AUR_PACKAGES[@]}" || warn "AUR install failed: ${AUR_PACKAGES[*]}"
        elif command -v pamac &> /dev/null; then
            pamac install --no-confirm "${AUR_PACKAGES[@]}" || warn "AUR install failed: ${AUR_PACKAGES[*]}"
        else
            warn "AUR helper (yay/paru/pamac) not found. Skipping ${AUR_PACKAGES[*]}."
        fi
    fi

    # 4. Back up Neovim data once, before your config replaces another one
    # (standalone only; Omarchy keeps its own LazyVim)
    if [[ "$PROFILE" == "standalone" && "$(readlink -f "$HOME/.config/nvim" 2>/dev/null || true)" != "$DOTFILES_DIR"/* ]]; then
        for nvim_dir in "$HOME/.local/share/nvim" "$HOME/.local/state/nvim" "$HOME/.cache/nvim"; do
            if [ -d "$nvim_dir" ]; then
                warn "Backing up $nvim_dir to $nvim_dir.bak_$TIMESTAMP"
                mv "$nvim_dir" "$nvim_dir.bak_$TIMESTAMP"
            fi
        done
    fi
fi

if $DRY_RUN && [[ "$DISTRO" == "Omarchy" ]]; then
    missing_pkgs="$(pacman -T "${OMARCHY_PACMAN[@]}" || true)"
    if [ -n "$missing_pkgs" ]; then
        info "Would install packages: $(echo $missing_pkgs)"
    else
        info "Packages already installed: ${OMARCHY_PACMAN[*]}"
    fi
fi

HAVE_STOW=true
if ! command -v stow &> /dev/null; then
    if $DRY_RUN; then
        HAVE_STOW=false
        warn "GNU Stow is not installed yet; showing backups and hook lines, not stow's own preview"
    else
        error "GNU Stow is not installed. Install it first (pacman -S stow / brew install stow)."
        exit 1
    fi
fi

# 5. Apply Dotfiles
# Move any real file that would block stow into $BACKUP_DIR (never delete).
backup_conflicts() {
    local group_dir="$1"; shift
    local pkg rel target
    for pkg in "$@"; do
        while IFS= read -r rel; do
            rel="${rel#./}"
            target="$HOME/$rel"
            # Already resolves into this repo (file link or folded parent dir link)
            if [[ -e "$target" && "$(readlink -f "$target")" == "$DOTFILES_DIR"/* ]]; then
                continue
            fi
            if [[ -e "$target" || -L "$target" ]]; then
                if $DRY_RUN; then
                    warn "Would back up $target"
                else
                    warn "Backing up $target to $BACKUP_DIR/"
                    mkdir -p "$BACKUP_DIR/$(dirname "$rel")"
                    mv "$target" "$BACKUP_DIR/$rel"
                fi
            fi
        done < <(cd "$group_dir/$pkg" && find . \( -type f -o -type l \) -not -name '.DS_Store')
    done
}

stow_group() {
    local group="$1"; shift
    # .stowrc is only read from the current directory, so pass the ignores here
    local stow_args=(--dir="$DOTFILES_DIR/$group" --target="$HOME" --ignore='\.DS_Store' --restow)
    backup_conflicts "$DOTFILES_DIR/$group" "$@"
    if $DRY_RUN; then
        info "Would stow $group: $*"
        $HAVE_STOW || return 0
        stow --no --verbose=1 "${stow_args[@]}" "$@" 2>&1 | grep -v '^WARNING: in simulation mode' || true
    else
        info "Stowing $group: $*"
        stow "${stow_args[@]}" "$@"
    fi
}

if $DRY_RUN; then
    info "Would create $(printf '~/%s ' "${REAL_DIRS[@]}")(real dirs, files get linked into them)"
    info "Stow's simulation can't see the backups below, so it reports those files as conflicts; the real run moves them first"
else
    for dir in "${REAL_DIRS[@]}"; do mkdir -p "$HOME/$dir"; done
fi

stow_group common "${COMMON_PACKAGES[@]}"
stow_group "$PROFILE" "${PROFILE_PACKAGES[@]}"

# 5b. Hook personal files into the files Omarchy owns (real files, not symlinks)
ensure_line() {
    local file="$1" line="$2" comment="$3"
    if [ ! -f "$file" ]; then
        warn "$file not found; add this line yourself: $line"
    elif grep -qxF "$line" "$file"; then
        info "Already hooked up: $file"
    elif $DRY_RUN; then
        warn "Would add to $file: $line"
    else
        printf '\n%s\n%s\n' "$comment" "$line" >> "$file"
        info "Added to $file: $line"
    fi
}

if [[ "$PROFILE" == "omarchy" ]]; then
    ensure_line "$HOME/.bashrc" \
        '[[ -r ~/.config/shell/rc.sh ]] && source ~/.config/shell/rc.sh' \
        '# Personal shell config from dotfiles (aliases, functions, fzf)'
    # SSH agent for push/pull and signed commits (socket path: omarchy/ssh)
    if $DRY_RUN; then
        info "Would enable ssh-agent.socket (systemd user)"
    else
        systemctl --user enable --now ssh-agent.socket
    fi
    ensure_line "$HOME/.config/hypr/hyprland.lua" \
        'require("hypr.hachi")' \
        '-- Personal Hyprland settings from dotfiles'
    ensure_line "$HOME/.config/tmux/tmux.conf" \
        'source-file -q ~/.config/tmux/tmux.local.conf' \
        '# Personal tmux overrides from dotfiles'
fi

if $DRY_RUN; then
    success "Dry run complete. Nothing was changed."
    exit 0
fi

if [ -d "$BACKUP_DIR" ]; then info "Replaced files were saved in $BACKUP_DIR"; fi

# Per-machine git settings (signing key etc.), never tracked
if [ ! -f "$HOME/.gitconfig.local" ]; then
    cp "$DOTFILES_DIR/templates/gitconfig.local" "$HOME/.gitconfig.local"
    info "Created ~/.gitconfig.local (per-machine git settings; ssh-setup turns on signing there)"
fi

if ! $LINK_ONLY; then
    # 6. ZSH Plugins
    if [[ "$PROFILE" == "standalone" && -f "$HOME/.config/zsh/custom/scripts/download-plugins.sh" ]]; then
        info "Downloading ZSH plugins..."
        bash "$HOME/.config/zsh/custom/scripts/download-plugins.sh"
    fi

    # 7. Mise Install (from ~, so a project's mise.toml in the current folder doesn't count)
    if command -v mise &> /dev/null; then
        info "Running mise install..."
        (cd "$HOME" && mise install -y)
    fi
fi

# 8. SSH key for GitHub push/pull and commit signing (asks, since it needs a passphrase)
if [ -f "$HOME/.ssh/id_ed25519" ]; then
    info "SSH key exists; 'ssh-setup' re-checks its GitHub and signing setup anytime."
elif [ -r /dev/tty ] && { printf '\033[0;36m[INPUT]\033[0m Set up an SSH key for GitHub (push/pull + signed commits) now? [Y/n] '; read -r answer </dev/tty; [[ ! "$answer" =~ ^[Nn] ]]; }; then
    # Straight to the terminal: gh's browser login needs one, and it keeps the log clean
    if "$DOTFILES_DIR/common/bin/.local/bin/ssh-setup" --remote </dev/tty >&3 2>&4; then
        info "ssh-setup finished (its output went to the terminal only)"
    else
        warn "ssh-setup did not finish; run 'ssh-setup --remote' again later."
    fi
else
    info "No SSH key yet: run 'ssh-setup --remote' for GitHub push/pull and commit signing."
fi

# 9. Verify (some SSH agent items only pass after logging out and back in)
echo ""
info "Checking the setup..."
"$DOTFILES_DIR/common/bin/.local/bin/dotfiles-check" || warn "See the ✗ items above; rerun 'dotfiles-check' after logging out and back in."

# 10. Final Reminders
echo ""
success "Setup complete!"
if [[ "$PROFILE" == "omarchy" ]]; then
    info "Open a new terminal (or run 'source ~/.bashrc') to load your aliases."
    info "Log out and back in, then run 'dotfiles-check --online' to verify everything."
    info "After each 'omarchy update', a hook runs dotfiles-check and notifies you if anything needs a look."
else
    info "Please perform the following manual steps:"
    echo "1. Open Neovim (run 'nvim') to let Lazy.nvim install plugins."
    echo "2. Ensure your terminal is using 'IosevkaTerm Nerd Font'."
    echo ""

    # Automatically reload shell
    info "Reloading shell to apply changes..."
    exec 1>&3 2>&4 3>&- 4>&- # stop logging before handing over the terminal
    exec zsh -l
fi
