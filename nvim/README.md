# nvim
Neovim with [LazyVim](https://www.lazyvim.org). Stowed to `~/.config/nvim`.
- **Customized:** `lua/config/*` (lazy bootstrap, options, keymaps, autocmds), `lazyvim.json` extras, `lazy-lock.json` pins. The LazyVim example plugin file was left out.
- **Install:** neovim from the `ppa:neovim-ppa/unstable` PPA (apt). Plugins install themselves on first launch (`nvim --headless "+Lazy! sync" +qa`).
- **Manual:** none. Needs `git`, `ripgrep`, `fd-find`, a Nerd Font.
