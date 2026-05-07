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
        if [ -f /etc/arch-release ]; then
            DISTRO="Arch"
        elif [ -f /etc/debian_version ]; then
            DISTRO="Debian"
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
elif [[ "$DISTRO" == "Debian" ]]; then
    info "Updating Apt and installing prerequisites..."
    sudo apt update && sudo apt install -y zsh git stow curl wget ca-certificates gnupg
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
    brew install neovim bat ripgrep fzf fd zoxide eza ouch fastfetch btop yt-dlp ffmpeg lazygit tmux ghq hub git-lfs mise uv pnpm
    brew install --cask alacritty zed vscodium
    # Font
    brew tap homebrew/cask-fonts || true
    brew install --cask font-iosevka-nerd-font || true
elif [[ "$DISTRO" == "Arch" ]]; then
    sudo pacman -S --noconfirm neovim bat ripgrep fzf fd zoxide eza ouch fastfetch btop yt-dlp ffmpeg lazygit tmux ghq hub git-lfs mise uv alacritty zed pnpm
    # Check for AUR helper
    if command -v yay &> /dev/null; then
        yay -S --noconfirm vscodium-bin pokeget-rs
    elif command -v paru &> /dev/null; then
        paru -S --noconfirm vscodium-bin pokeget-rs
    else
        warn "AUR helper (yay/paru) not found. Skipping vscodium-bin and pokeget-rs."
    fi
elif [[ "$DISTRO" == "Debian" ]]; then
    # Install available packages via apt
    info "Installing tools via apt..."
    # Core packages
    sudo apt install -y neovim bat ripgrep fzf fd-find zoxide btop ffmpeg tmux git-lfs || warn "Some core packages could not be installed."
    
    # Extra packages available in newer Ubuntu (24.04+ / Noble / Resolute)
    info "Installing extra tools (Ubuntu 24.04+)..."
    sudo apt install -y eza lazygit fastfetch yt-dlp hub alacritty || warn "Extra tools could not be installed via apt. They might not be available in your repository version."
    
    # Install Zed editor via official script
    if ! command -v zed &> /dev/null; then
        info "Installing Zed editor..."
        curl -f https://zed.dev/install.sh | sh
    fi

    # Install Mise
    if ! command -v mise &> /dev/null; then
        info "Installing Mise..."
        curl https://mise.jdx.dev/install.sh | sh
    fi

    # Install Uv
    if ! command -v uv &> /dev/null; then
        info "Installing Uv..."
        curl -LsSf https://astral.sh/uv/install.sh | sh
    fi

    # Install Pnpm
    if ! command -v pnpm &> /dev/null; then
        info "Installing Pnpm..."
        curl -fsSL https://get.pnpm.io/install.sh | sh -
    fi

    # Install Ouch (via cargo if available)
    if ! command -v ouch &> /dev/null; then
        if command -v cargo &> /dev/null; then
            info "Installing Ouch via cargo..."
            cargo install ouch
        else
            warn "Ouch not found and cargo not available. Skipping Ouch installation."
        fi
    fi

    # Install GHQ (via go if available)
    if ! command -v ghq &> /dev/null; then
        if command -v go &> /dev/null; then
            info "Installing GHQ via go..."
            go install github.com/x-motemen/ghq@latest
        else
            warn "GHQ not found and go not available. Skipping GHQ installation."
        fi
    fi

    # Install VSCodium
    if ! command -v codium &> /dev/null; then
        info "Installing VSCodium..."
        wget -qO - https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg | gpg --dearmor | sudo dd of=/usr/share/keyrings/vscodium-archive-keyring.gpg
        echo 'deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/vscodium-archive-keyring.gpg ] https://download.vscodium.com/debs vscodium main' | sudo tee /etc/apt/sources.list.d/vscodium.list
        sudo apt update && sudo apt install -y codium || warn "Failed to install VSCodium via custom repository."
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
    # Ensure mise is in path for the current session
    if [[ "$DISTRO" == "Debian" ]]; then
        export PATH="$HOME/.local/bin:$PATH"
    fi
    mise install -y
fi

# 8. Final Reminders
echo ""
success "Setup complete!"
info "Please perform the following manual steps:"
echo "1. Open Neovim (run 'nvim') to let Lazy.nvim install plugins."
echo "2. Ensure your terminal is using 'IosevkaTerm Nerd Font'."
echo ""
warn "Note: If you encounter 'stow' conflicts, you may need to manually remove or move conflicting files in your home directory."

# Automatically reload shell
echo ""
info "Reloading shell to apply changes..."
exec zsh -l
