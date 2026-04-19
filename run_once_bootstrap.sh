#!/bin/bash
# Bootstrap script for a fresh Mac
# Run with: curl -fsS <raw-gist-url> | bash
# Or just: bash bootstrap.sh

set -e

echo "=== Mac Bootstrap ==="

# --- Homebrew ---
if ! command -v brew &>/dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    echo "Homebrew already installed."
fi

# --- Formulae ---
echo "Installing brew formulae..."
brew install \
    act \
    aria2 \
    atuin \
    chezmoi \
    docker \
    dust \
    elixir \
    ffmpeg \
    fish \
    gh \
    htop \
    hyperfine \
    imagemagick \
    jq \
    mosh \
    neovim \
    nmap \
    pandoc \
    ripgrep \
    starship \
    tmux \
    tokei \
    websocat \
    wget \
    yt-dlp \
    7zip

# --- Casks ---
echo "Installing casks..."
brew install --cask \
    font-jetbrains-mono-nerd-font

# --- Set Fish as default shell ---
FISH_PATH="$(which fish)"
if ! grep -q "$FISH_PATH" /etc/shells; then
    echo "Adding fish to /etc/shells (requires sudo)..."
    echo "$FISH_PATH" | sudo tee -a /etc/shells
fi
if [ "$SHELL" != "$FISH_PATH" ]; then
    echo "Setting fish as default shell..."
    chsh -s "$FISH_PATH"
fi

# --- Fisher plugin manager ---
echo "Installing Fisher and plugins..."
fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher jorgebucaran/nvm.fish"

# --- Atuin daemon ---
echo "Starting atuin daemon..."
brew services start atuin

# --- macOS preferences ---
echo "Configuring macOS..."
# Dock: small icons
defaults write com.apple.dock tilesize -int 24
killall Dock

# --- Dotfiles via chezmoi ---
# Uncomment and set your repo once you've pushed your dotfiles:
# chezmoi init --apply your-github-user/dotfiles

echo ""
echo "=== Done ==="
echo "Next steps:"
echo "  1. Open Kitty (not Terminal.app)"
echo "  2. Generate SSH keys: ssh-keygen -t ed25519"
echo "  3. Push dotfiles: cd ~/.local/share/chezmoi && git remote add origin <repo> && git push"
echo "  4. On future machines: chezmoi init --apply your-github-user/dotfiles"
