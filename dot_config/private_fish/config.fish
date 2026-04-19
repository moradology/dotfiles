export PATH="$HOME/.local/bin:$PATH"

if status is-interactive
    export NVM_DIR="$HOME/.nvm"
    starship init fish | source
    atuin init fish | source

    # Use Kitty's SSH kitten (copies terminfo, better experience on remote hosts)
    abbr --add s "kitten ssh"
end
