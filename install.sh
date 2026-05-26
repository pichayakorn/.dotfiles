#!/usr/bin/env bash

# Stop on error and undefined variables
set -eu

# Set colors for output
SET_COLOR_RESET='\033[0m'
SET_COLOR_CYAN='\033[0;36m'
SET_COLOR_YELLOW='\033[1;33m'
SET_COLOR_RED='\033[0;31m'
SET_COLOR_GREEN='\033[0;32m'

# Utility functions
info() { echo -e "${SET_COLOR_CYAN}[INFO]${SET_COLOR_RESET} $1"; }
warn() { echo -e "${SET_COLOR_YELLOW}[WARN]${SET_COLOR_RESET} $1"; }
error() { echo -e "${SET_COLOR_RED}[ERROR]${SET_COLOR_RESET} $1"; }
success() { echo -e "${SET_COLOR_GREEN}[SUCCESS]${SET_COLOR_RESET} $1"; }

# Detect OS
OS="$(uname -s)"
case "$OS" in
    Linux*)
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            if [[ "$ID" == "arch" || "${ID_LIKE:-}" == *"arch"* || "$ID" == "manjaro" || "$ID" == "omarchy" || "$ID" == "endeavouros" ]]; then
                DISTRO="Arch"
            else
                DISTRO="Linux"
            fi
        elif [ -f /etc/arch-release ]; then
            DISTRO="Arch"
        else
            DISTRO="Linux"
        fi
        ;;
    Darwin*)
        DISTRO="macOS"
        ;;
    *)
        DISTRO="UNKNOWN"
        ;;
esac

info "Detected OS: $OS ($DISTRO)"

# 0. Clone Dotfiles if not present
# This allows running the script via curl | bash
DOTFILES_DIR="$HOME/.dotfiles"
if [ ! -d "$DOTFILES_DIR" ]; then
    # Ensure git is installed for cloning
    if ! command -v git &> /dev/null; then
        info "Git not found. Installing git prerequisites..."
        if [[ "$DISTRO" == "Arch" ]]; then
            sudo pacman -Syu --noconfirm git
        fi
    fi
    info "Cloning dotfiles to $DOTFILES_DIR..."
    git clone https://github.com/pichayakorn/.dotfiles.git "$DOTFILES_DIR"
fi

# 1. Install Prerequisites & Package Managers
if [[ "$DISTRO" == "macOS" ]]; then
    # Ask for custom cask appdir
    echo -e "${SET_COLOR_CYAN}[INPUT]${SET_COLOR_RESET} Do you want to specify a custom directory for Homebrew Casks? (e.g., for external SSD)"
    echo -e "Default is /Applications. Press Enter to skip or type the path:"
    read -r CUSTOM_APPDIR || CUSTOM_APPDIR=""
    if [ -n "$CUSTOM_APPDIR" ]; then
        export HOMEBREW_CASK_OPTS="--appdir=$CUSTOM_APPDIR"
        info "Homebrew Casks will be installed to: $CUSTOM_APPDIR"
        
        # Persist this setting in the zsh config
        ZSH_CONFIG="$DOTFILES_DIR/.config/zsh/custom/config.zsh"
        if [ -f "$ZSH_CONFIG" ]; then
            if ! grep -q "HOMEBREW_CASK_OPTS" "$ZSH_CONFIG"; then
                echo -e "\n# Homebrew Cask custom directory\nexport HOMEBREW_CASK_OPTS=\"--appdir=$CUSTOM_APPDIR\"" >> "$ZSH_CONFIG"
                info "Persisted HOMEBREW_CASK_OPTS to $ZSH_CONFIG"
            else
                # Update existing value
                sed -i '' "s|HOMEBREW_CASK_OPTS=.*|HOMEBREW_CASK_OPTS=\"--appdir=$CUSTOM_APPDIR\"|" "$ZSH_CONFIG"
                info "Updated HOMEBREW_CASK_OPTS in $ZSH_CONFIG"
            fi
        fi
    fi

    if ! command -v brew &> /dev/null; then
        info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        if [[ -f /opt/homebrew/bin/brew ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [[ -f /usr/local/bin/brew ]]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    fi
elif [[ "$DISTRO" == "Arch" ]]; then
    info "Updating Pacman and installing prerequisites..."
    sudo pacman -Syu --noconfirm zsh git stow curl wget
fi

# 2. Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    info "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    info "Oh My Zsh already installed."
fi

# 3. Install Tools
info "Installing tools for $DISTRO..."
if [[ "$DISTRO" == "macOS" ]]; then
    brew install neovim bat ripgrep fzf fd zoxide eza ouch fastfetch btop yt-dlp ffmpeg lazygit git-delta tmux ghq hub git-lfs mise uv pnpm
    brew install --cask alacritty zed vscodium discord
    # Font
    brew tap homebrew/cask-fonts || true
    brew install --cask font-iosevka-nerd-font || true
elif [[ "$DISTRO" == "Arch" ]]; then
    sudo pacman -S --noconfirm neovim bat ripgrep fzf fd zoxide eza ouch fastfetch btop yt-dlp ffmpeg lazygit git-delta tmux ghq hub git-lfs mise uv alacritty zed pnpm ttf-iosevkaterm-nerd discord
    # Check for AUR helper (yay, paru, or pamac)
    if command -v yay &> /dev/null; then
        yay -S --noconfirm vscodium-bin pokeget-rs
    elif command -v paru &> /dev/null; then
        paru -S --noconfirm vscodium-bin pokeget-rs
    elif command -v pamac &> /dev/null; then
        pamac install --no-confirm vscodium-bin pokeget-rs
    else
        warn "AUR helper (yay/paru/pamac) not found. Skipping vscodium-bin and pokeget-rs."
    fi
fi

# 4. Backup Neovim Data (Recommended)
info "Checking for existing Neovim data to backup..."
for nvim_dir in "$HOME/.local/share/nvim" "$HOME/.local/state/nvim" "$HOME/.cache/nvim"; do
    if [ -d "$nvim_dir" ]; then
        warn "Backing up $nvim_dir to ${nvim_dir}.bak"
        rm -rf "${nvim_dir}.bak"
        mv "$nvim_dir" "${nvim_dir}.bak"
    fi
done

# 5. Apply Dotfiles
# If the script was run remotely, we need to cd into the cloned dir
cd "$DOTFILES_DIR"

# Backup existing config if they are not symlinks
BACKUP_DIR="$HOME/dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

# List of common files to check for backup
FILES_TO_CHECK=(".zshrc" ".gitconfig" ".config/nvim" ".config/alacritty" ".config/tmux" ".config/zsh")

for file in "${FILES_TO_CHECK[@]}"; do
    if [[ -e "$HOME/$file" && ! -L "$HOME/$file" ]]; then
        warn "Backing up existing $HOME/$file to $BACKUP_DIR/"
        cp -RL "$HOME/$file" "$BACKUP_DIR/"
        rm -rf "$HOME/$file"
    fi
done

# Run stow
stow .

# 6. ZSH Plugins
info "Downloading ZSH plugins..."
if [ -f "$DOTFILES_DIR/.config/zsh/custom/scripts/download-plugins.sh" ]; then
    bash "$DOTFILES_DIR/.config/zsh/custom/scripts/download-plugins.sh"
fi

# 7. Mise Install
if command -v mise &> /dev/null; then
    info "Running mise install..."
    mise install -y
fi

# 8. Final Reminders
echo ""
success "Setup complete!"
info "Please perform the following manual steps:"
echo "1. Open Neovim (run 'nvim') to let Lazy.nvim install plugins."
echo "2. Ensure your terminal is using 'IosevkaTerm Nerd Font' (ttf-iosevkaterm-nerd)."
echo ""
warn "Note: If you encounter 'stow' conflicts, you may need to manually remove or move conflicting files in your home directory."

# Automatically reload shell
echo ""
info "Reloading shell to apply changes..."
exec zsh -l
