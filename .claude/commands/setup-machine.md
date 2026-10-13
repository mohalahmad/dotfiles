---
description: Set up this machine from the dotfiles repo (install tools, link configs, verify)
argument-hint: "[tool ...]"
allowed-tools: Bash, Read, Edit, Write, Grep, Glob
---

You are setting up a fresh Linux machine from this dotfiles repo. Arguments (optional): `$ARGUMENTS` — a subset of tools. With no arguments, set up everything in the core list.

## 1. Pre-flight
- Read `README.md` and `install.sh`. Run `./install.sh --list` for the tool names.
- Check the OS (`cat /etc/os-release`), desktop (`$XDG_CURRENT_DESKTOP`), architecture, network (`curl -sI https://github.com | head -1`), and sudo access (`sudo -v`; if it needs a password, ask the user to run `! sudo -v`).
- Warn if this isn't Ubuntu/Pop!_OS/Debian-based. On COSMIC or non-GNOME desktops the `desktop` dconf step skips itself.
- Report which tools already exist (`zsh nvim wezterm code git stow btop conky claude go node cargo docker`) and which `~/.zshrc`, `~/.config/nvim`, `~/.wezterm.lua` already exist (they will be backed up to `~/.dotfiles-backup/<timestamp>/`, not overwritten).

## 2. Install
- Run `./install.sh $ARGUMENTS` (it is idempotent). Run it in the foreground; long steps (apt, fonts, nvim plugin sync) are expected.
- If a tool fails, read the error, fix the root cause (missing dependency, stale apt lists, repo/key URL changed, network), edit the relevant `install_<tool>` function in `install.sh` (helpers live at the top of it) if the script itself is wrong, and re-run just that tool: `./install.sh <tool>`. Do not skip failures silently, and do not use `--force` style flags or delete the user's existing files; backups are made by `stow_pkg`.
- Never commit or print secrets. Do not touch `~/.ssh` — tell the user to restore keys from their backup/password manager.

## 3. Verify
Run these and record pass/fail for each:
- Versions: `zsh --version`, `nvim --version | head -1`, `wezterm --version`, `code --version | head -1`, `git --version`, `gh --version | head -1`, `btop --version`, `conky --version | head -1`, `claude --version`, `node -v`, `go version`, `cargo --version`, `docker --version`.
- Links: for every stow package, `readlink` the main file (`~/.zshrc`, `~/.p10k.zsh`, `~/.wezterm.lua`, `~/.config/nvim/init.lua`, `~/.config/Code/User/settings.json`, `~/.config/btop/btop.conf`, `~/.config/conky/conky.conf`, `~/.claude/settings.json`) and confirm it points into this repo.
- Shell: `getent passwd $USER | cut -d: -f7` is zsh; `~/.oh-my-zsh/custom/themes/powerlevel10k` and both plugins exist; `zsh -ic 'echo ok'` prints `ok` without errors.
- Fonts: `fc-list | grep -ci "JetBrainsMono.*Nerd"` is > 0.
- Neovim: `nvim --headless "+Lazy! sync" +qa` exits cleanly.
- VS Code: every line of `vscode/extensions.txt` appears in `code --list-extensions`.
- Git: `git --version` and `gh --version` work (git config is not tracked; the user sets their identity).
- Desktop (GNOME only): `gsettings get org.gnome.desktop.interface gtk-theme` matches `desktop/dconf/desktop-interface.ini`.

## 4. Report
Give a concise table: tool → ✅/❌ with the version or error. Then list:
- What was fixed along the way (and any repo changes you made — offer to commit them, don't push).
- Remaining manual steps: restore `~/.ssh` keys, set `git config --global user.name/email`, `gh auth login`, `claude` login, fill `~/.zshrc.local` secrets, install the WinXP icon theme (see `desktop/README.md`), install GNOME extensions (Vitals etc.) via Extension Manager, set the terminal font to a Nerd Font, **log out and back in** for the default shell and docker group.
