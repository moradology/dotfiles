# dotfiles

Managed with [chezmoi](https://chezmoi.io). Source lives at `~/.local/share/chezmoi` (chezmoi's default).

## Layout

| Path in repo | Deploys to | Notes |
|---|---|---|
| `dot_tmux.conf` | `~/.tmux.conf` | Local tmux config |
| `dot_config/kitty/kitty.conf` | `~/.config/kitty/kitty.conf` | Kitty terminal |
| `dot_config/fish/` | `~/.config/fish/` | Fish shell (private) |
| `dot_config/starship.toml` | `~/.config/starship.toml` | Prompt |
| `run_once_bootstrap.sh` | runs once on `chezmoi apply` | Installs packages |
| `remote/hermes.tmux.conf` | *(not deployed locally)* | Reference copy of hermes tmux config, ignored by chezmoi |

## Day-to-day

```sh
chezmoi status           # show drift
chezmoi diff             # preview what apply would do
chezmoi re-add           # pull current on-disk state back into source
chezmoi apply            # push source to home
chezmoi cd               # jump into the source repo
```

## Remote (hermes) sync

The hermes tmux config isn't a local dotfile, so chezmoi ignores it. To push it:

```sh
scp -o RemoteCommand=none ~/.local/share/chezmoi/remote/hermes.tmux.conf hermes:~/.tmux.conf
ssh -o RemoteCommand=none hermes 'tmux source-file ~/.tmux.conf'
```

## Bootstrap on a fresh machine

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply <your-github-username>/dotfiles
```
