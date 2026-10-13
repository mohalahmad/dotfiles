# dotfiles
Complete setup for my Linux machine (Ubuntu 24.04 / Pop!_OS, GNOME). Each directory is a [GNU Stow](https://www.gnu.org/software/stow/) package: `stow <dir>` symlinks it into `$HOME`.

| Dir | What | Install method |
|---|---|---|
| [zsh](zsh) | zsh, oh-my-zsh, Powerlevel10k, aliases | apt + curl + git clone |
| [nvim](nvim) | Neovim + LazyVim | neovim PPA |
| [wezterm](wezterm) | WezTerm (Nord) | apt repo |
| [vscode](vscode) | settings, keybindings, extensions | snap |
| [git](git) | install only (git, git-lfs, gh) | apt |
| [btop](btop) / [conky](conky) / [neofetch](neofetch) | CLI/system tools | apt / go |
| [claude](claude) | Claude Code settings | curl installer |
| [devtools](devtools) | nvm/Node, Rust, Go, Docker, base packages | scripts |
| [desktop](desktop) | GNOME dconf, themes, wallpapers | dconf |
| [fonts](fonts) | Nerd Fonts | downloaded |

## Quick start (new machine)
```sh
git clone <this repo> ~/Persoanl/projects/dotfiles && cd ~/Persoanl/projects/dotfiles
./install.sh            # everything (idempotent)
./install.sh zsh nvim   # only some tools
```
Or open Claude Code in the repo and run `/setup-machine`.

Each `<tool>/install.sh` (or `./install.sh <tool>`) runs just that tool. Existing configs are backed up to `~/.dotfiles-backup/<timestamp>/` before stow links them.

## Secrets
Not stored here: SSH keys, git identity, tokens, shell history, Claude/gh/gcloud credentials. Put per-machine secrets in `~/.zshrc.local` (template in `zsh/`).

## Manual steps
Restore `~/.ssh` and set up git identity (`git config --global user.name/email`); `gh auth login`; WinXP icon theme (see `desktop/README.md`); log out/in for the zsh shell change.

## Claude Code
`.claude/commands/setup-machine.md` defines `/setup-machine`: it runs the installer, fixes errors, verifies every tool, and reports what's left.
