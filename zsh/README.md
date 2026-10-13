# zsh
Zsh with oh-my-zsh and the Powerlevel10k prompt.
- **Files:** `.zshrc`, `.zshenv`, `.p10k.zsh` (stowed to `~`)
- **Customized:** 100k shared history, rich completion styles, emacs keymap with Home/End/Ctrl-arrows, git aliases (`gs`, `gco`, ...), safety aliases (`rm -i`), `cat`→`bat`, PATH for Go/Cargo/npm-global/opencode, nvm.
- **omz plugins:** git, zsh-autosuggestions, zsh-syntax-highlighting, colored-man-pages, extract, sudo, history, web-search, command-not-found, copyfile, copypath
- **Install:** apt (`zsh`), oh-my-zsh via its install script, p10k + two plugins via `git clone` into `~/.oh-my-zsh/custom`. See `install.sh`.
- **Secrets:** put them in `~/.zshrc.local` (gitignored, sourced at end of `.zshrc`). Template: `.zshrc.local.example`.
- **Manual:** log out/in after the default shell changes. Set a terminal font to a Nerd Font for p10k icons.
