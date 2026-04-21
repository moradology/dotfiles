export PATH="$HOME/.local/bin:$PATH"

# Rust toolchain (cargo, rustc, rustup) — set up by rustup-init
if test -f ~/.cargo/env.fish
    source ~/.cargo/env.fish
end

if status is-interactive
    # Auto-attach tmux for interactive SSH/mosh logins.
    # Skipped for local terminals ($SSH_CONNECTION unset) and non-interactive ssh cmd.
    if test -z "$TMUX"; and test -n "$SSH_CONNECTION"; and type -q tmux
        exec tmux new-session -A -s main
    end

    export NVM_DIR="$HOME/.nvm"
    starship init fish | source
    atuin init fish | source

    # Use Kitty's SSH kitten (copies terminfo, better experience on remote hosts)
    abbr --add s "kitten ssh"
end
