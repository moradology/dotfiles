#!/bin/bash
# Bootstrap script for a fresh Mac.
# One-liner on a clean machine:
#   sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply moradology/dotfiles

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
    uv \
    websocat \
    wget \
    yt-dlp \
    7zip

# --- Casks ---
echo "Installing casks..."
brew install --cask \
    font-jetbrains-mono-nerd-font \
    kitty \
    bettertouchtool

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

# --- Tmux Plugin Manager + plugins ---
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    echo "Installing TPM..."
    git clone --depth=1 https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi
echo "Installing tmux plugins..."
TMUX_PLUGIN_MANAGER_PATH="$HOME/.tmux/plugins/" "$HOME/.tmux/plugins/tpm/bin/install_plugins" || true

# --- macOS preferences ---
echo "Configuring macOS..."
# Dock: small icons
defaults write com.apple.dock tilesize -int 24
killall Dock || true

# Disable "Swipe between pages" two-finger horizontal gesture so BetterTouchTool
# can capture 2-finger swipes for tmux window navigation.
defaults write NSGlobalDomain AppleEnableSwipeNavigateWithScrolls -bool false

# Trackpad: ensure 3-finger drag is off (interferes with BTT 3-finger gestures).
# Comment out if you rely on 3-finger drag.
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool false
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool false

# Disable macOS "Select previous/next input source" hotkeys (defaults Ctrl+Space
# and Cmd+Option+Space). Frees Ctrl+Space for tmux prefix use.
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 60 '{
  enabled = 0;
  value = { parameters = (32, 49, 262144); type = "standard"; };
}'
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 61 '{
  enabled = 0;
  value = { parameters = (32, 49, 786432); type = "standard"; };
}'
killall cfprefsd 2>/dev/null || true

# Note: trackpad defaults usually need a logout/login to fully apply.

# --- Load user LaunchAgents (e.g. capslock → ctrl remap) ---
if [ -d "$HOME/Library/LaunchAgents" ]; then
    for agent in "$HOME"/Library/LaunchAgents/com.local.*.plist; do
        [ -f "$agent" ] || continue
        echo "Loading $agent..."
        launchctl load -w "$agent" 2>/dev/null || true
    done
fi

# --- Import BetterTouchTool preset (gestures) ---
BTT_PRESET="$HOME/.local/share/chezmoi/btt/Default.bttpreset"
if [ -f "$BTT_PRESET" ] && [ -d "/Applications/BetterTouchTool.app" ]; then
    echo "Opening BTT preset for import (confirm import in the BTT dialog)..."
    open -a BetterTouchTool "$BTT_PRESET" || true
fi

echo ""
echo "=== Done ==="
echo "Next steps:"
echo "  1. Open Kitty (not Terminal.app)"
echo "  2. Generate an SSH key for GitHub:   ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_github"
echo "  3. Add the public key at https://github.com/settings/keys"
echo "  4. For remote hosts (e.g. hermes), run ssh-copy-id once per host"
echo "  5. Launch BetterTouchTool and import your gesture config (not tracked in dotfiles)"
