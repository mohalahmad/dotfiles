#!/usr/bin/env bash
# Set up this machine from the dotfiles repo. Idempotent.
#   ./install.sh            # everything
#   ./install.sh zsh nvim   # selected tools
#   ./install.sh --list
set -euo pipefail
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="${BACKUP_DIR:-$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)}"
export DEBIAN_FRONTEND=noninteractive
SUDO=""; [ "$(id -u)" -ne 0 ] && SUDO="sudo"

log()  { echo $'\e[34m==>\e[0m' "$*"; }
ok()   { echo $'\e[32m ✓\e[0m' "$*"; }
skip() { echo $'\e[33m -\e[0m' "$* (already done, skipping)"; }
warn() { echo $'\e[33m !\e[0m' "$*" >&2; }
die()  { echo $'\e[31m ✗' "$*"$'\e[0m' >&2; exit 1; }
have() { command -v "$1" >/dev/null 2>&1; }

apt_update_once() { [ -n "${_APT_UPDATED:-}" ] || { $SUDO apt-get update -y && _APT_UPDATED=1; }; }
apt_install() {  # install only the missing packages
  local missing=() p
  for p in "$@"; do dpkg -s "$p" >/dev/null 2>&1 || missing+=("$p"); done
  [ ${#missing[@]} -eq 0 ] && { skip "apt: $*"; return 0; }
  apt_update_once; log "apt install: ${missing[*]}"; $SUDO apt-get install -y "${missing[@]}"
}
add_apt_repo() {  # name key_url keyring_path "deb line"
  [ -f "/etc/apt/sources.list.d/$1.list" ] && { skip "apt repo $1"; return 0; }
  log "adding apt repo $1"
  $SUDO install -d -m 0755 /etc/apt/keyrings
  curl -fsSL "$2" | $SUDO gpg --dearmor --yes -o "$3"
  echo "$4" | $SUDO tee "/etc/apt/sources.list.d/$1.list" >/dev/null
  _APT_UPDATED=""; apt_update_once
}
git_clone_once() { [ -d "$2" ] && skip "$2" || git clone --depth=1 "$1" "$2"; }

# Move conflicting existing files to $BACKUP_DIR, then symlink the package with stow.
stow_pkg() {
  local pkg="$1" out rel
  have stow || apt_install stow
  [ -d "$REPO/$pkg" ] || die "no such package: $pkg"
  out="$(stow --no-folding -n -d "$REPO" -t "$HOME" "$pkg" 2>&1 || true)"
  while IFS= read -r rel; do
    [ -z "$rel" ] && continue
    mkdir -p "$BACKUP_DIR/$(dirname "$rel")"
    mv "$HOME/$rel" "$BACKUP_DIR/$rel" && warn "backed up ~/$rel -> $BACKUP_DIR/$rel"
  done < <(echo "$out" | sed -nE 's/.*existing target (is neither a link nor a directory|is not owned by stow|exists and is not a symlink)[^:]*: (.*)$/\2/p; s/.*over existing target ([^ ]+) since.*/\1/p')
  stow --no-folding -R -d "$REPO" -t "$HOME" "$pkg" && ok "stowed $pkg"
}

# ---------------------------------------------------------------- tools
install_devtools() {
  log "dev tooling"
  apt_install build-essential curl wget git git-lfs unzip cmake ripgrep fd-find bat jq tree \
    python3-full python3-pip python3-venv
  if [ ! -d "$HOME/.nvm" ]; then curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | PROFILE=/dev/null bash; else skip "nvm"; fi
  export NVM_DIR="$HOME/.nvm"; . "$NVM_DIR/nvm.sh"
  if nvm ls 24 >/dev/null 2>&1; then skip "node 24"; else nvm install 24; fi
  if have cargo || [ -x "$HOME/.cargo/bin/cargo" ]; then skip "rust"; else curl -fsSL https://sh.rustup.rs | sh -s -- -y; fi
  if [ ! -x /usr/local/go/bin/go ]; then
    local gov; gov="$(curl -fsSL 'https://go.dev/VERSION?m=text' | head -1)"
    curl -fsSL "https://go.dev/dl/$gov.linux-$(dpkg --print-architecture).tar.gz" | $SUDO tar -C /usr/local -xzf - && ok "go $gov"
  else skip "go"; fi
  export PATH="$PATH:/usr/local/go/bin"
  local pkg b
  for pkg in golang.org/x/tools/gopls@latest github.com/bufbuild/buf/cmd/buf@latest github.com/sqlc-dev/sqlc/cmd/sqlc@latest; do
    b="$(basename "${pkg%@*}")"
    [ -x "$HOME/go/bin/$b" ] && skip "go: $b" || go install "$pkg" || warn "go install failed: $pkg"
  done
  npm ls -g --depth=0 2>/dev/null | grep -q ' vercel@' && skip "npm: vercel" || npm i -g vercel
  if ! have docker; then
    apt_install ca-certificates curl gpg
    . /etc/os-release
    add_apt_repo docker https://download.docker.com/linux/ubuntu/gpg /etc/apt/keyrings/docker.gpg \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu ${UBUNTU_CODENAME:-$VERSION_CODENAME} stable"
    apt_install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    $SUDO usermod -aG docker "$USER" && warn "re-login for the docker group"
  else skip "docker"; fi
}

install_git() {
  log "git"
  apt_install git git-lfs curl gpg
  if have gh; then skip "gh"; else
    add_apt_repo github-cli https://cli.github.com/packages/githubcli-archive-keyring.gpg /etc/apt/keyrings/githubcli-archive-keyring.gpg \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main"
    apt_install gh
  fi
}

install_zsh() {
  log "zsh"
  apt_install zsh git curl bat
  local omz="$HOME/.oh-my-zsh" c
  if [ -d "$omz" ]; then skip "oh-my-zsh"; else
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  fi
  c="$omz/custom"
  git_clone_once https://github.com/romkatv/powerlevel10k.git "$c/themes/powerlevel10k"
  git_clone_once https://github.com/zsh-users/zsh-autosuggestions "$c/plugins/zsh-autosuggestions"
  git_clone_once https://github.com/zsh-users/zsh-syntax-highlighting "$c/plugins/zsh-syntax-highlighting"
  stow_pkg zsh
  [ -f "$HOME/.zshrc.local" ] || { cp "$REPO/zsh/.zshrc.local.example" "$HOME/.zshrc.local"; ok "created ~/.zshrc.local"; }
  if [ "$(getent passwd "$USER" | cut -d: -f7)" != "$(command -v zsh)" ]; then
    $SUDO chsh -s "$(command -v zsh)" "$USER" && ok "default shell = zsh (re-login to apply)"
  else skip "default shell is zsh"; fi
}

install_fonts() {
  log "fonts"
  apt_install curl unzip fontconfig
  local d="$HOME/.local/share/fonts" ver="${NERD_FONTS_VERSION:-v3.3.0}" tmp
  mkdir -p "$d"
  if ls "$d" 2>/dev/null | grep -qi '^JetBrainsMonoNerdFont'; then skip "JetBrainsMono Nerd Font"; else
    tmp="$(mktemp -d)"
    curl -fsSL -o "$tmp/f.zip" "https://github.com/ryanoasis/nerd-fonts/releases/download/$ver/JetBrainsMono.zip" \
      && unzip -oq "$tmp/f.zip" -d "$d" -x '*.md' 'LICENSE*' 'OFL*' && ok "JetBrainsMono Nerd Font" || warn "font download failed"
    rm -rf "$tmp"
  fi
  fc-cache -f >/dev/null && ok "font cache refreshed"
}

install_nvim() {
  log "neovim"
  if ! have nvim; then
    apt_install software-properties-common
    grep -rqs "neovim-ppa/unstable" /etc/apt/sources.list.d/ || { $SUDO add-apt-repository -y ppa:neovim-ppa/unstable; _APT_UPDATED=""; apt_update_once; }
  fi
  apt_install neovim git ripgrep fd-find build-essential curl
  stow_pkg nvim
  if [ -d "$HOME/.local/share/nvim/lazy/lazy.nvim" ]; then skip "nvim plugins"; else
    nvim --headless "+Lazy! sync" +qa || warn "plugin sync failed; run :Lazy sync manually"
  fi
}

install_wezterm() {
  log "wezterm"
  if have wezterm; then skip "wezterm"; else
    apt_install curl gpg
    add_apt_repo wezterm https://apt.fury.io/wez/gpg.key /etc/apt/keyrings/wezterm-fury.gpg "deb [signed-by=/etc/apt/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *"
    apt_install wezterm
  fi
  install_fonts
  stow_pkg wezterm
}

install_vscode() {
  log "vscode"
  if have code; then skip "vscode"; else have snap || apt_install snapd; $SUDO snap install code --classic; fi
  stow_pkg vscode
  local installed ext; installed="$(code --list-extensions 2>/dev/null || true)"
  while IFS= read -r ext; do
    [ -z "$ext" ] && continue
    if echo "$installed" | grep -qix "$ext"; then skip "ext $ext"; else code --install-extension "$ext" >/dev/null && ok "ext $ext" || warn "failed: $ext"; fi
  done < "$REPO/vscode/extensions.txt"
}

install_btop()     { log btop;     apt_install btop;        stow_pkg btop; }
install_conky()    { log conky;    apt_install conky-all;   stow_pkg conky; }
install_neofetch() { log neofetch; apt_install neofetch;   stow_pkg neofetch; }

install_claude() {
  log "claude code"
  if have claude || [ -x "$HOME/.local/bin/claude" ]; then skip "claude"; else curl -fsSL https://claude.ai/install.sh | bash; fi
  stow_pkg claude
}

install_desktop() {
  log "desktop (GNOME)"
  if have dconf && [[ "${XDG_CURRENT_DESKTOP:-}" == *[Gg][Nn][Oo][Mm][Ee]* ]]; then
    local name path f
    while IFS='=' read -r name path; do
      [ -z "$name" ] && continue
      f="$REPO/desktop/dconf/$(echo "$name" | tr / -).ini"; [ -f "$f" ] || continue
      sed "s|@HOME@|$HOME|g" "$f" | dconf load "$path" && ok "dconf $path"
    done < "$REPO/desktop/dconf/paths.txt"
  else warn "not a GNOME session (${XDG_CURRENT_DESKTOP:-none}); skipping dconf settings"; fi
  stow_pkg desktop
  if [ -d "$HOME/.local/share/icons/WhiteSur" ]; then skip "WhiteSur icons"; else
    apt_install git sassc libglib2.0-dev-bin libxml2-utils
    local tmp; tmp="$(mktemp -d)"
    git clone --depth=1 https://github.com/vinceliuice/WhiteSur-icon-theme "$tmp/i" && (cd "$tmp/i" && ./install.sh -b) || warn "WhiteSur icons failed"
    git clone --depth=1 https://github.com/vinceliuice/WhiteSur-cursors "$tmp/c" && (cd "$tmp/c" && ./install.sh) || true
    rm -rf "$tmp"
  fi
  [ -d "$HOME/.icons/WinXPSVG-plasma5up-scalable-icontheme-blackysgate.de" ] || warn "MANUAL: WinXP icon theme not present (see desktop/README.md)"
  if [[ "${XDG_CURRENT_DESKTOP:-}" == *COSMIC* ]]; then
    # Vitals is GNOME-only; on COSMIC use the sysinfo panel applet instead.
    local applet=io.github.cosmic_utils.sysinfo-applet
    if flatpak info "$applet" >/dev/null 2>&1; then skip "COSMIC sysinfo applet"; else
      flatpak install -y --user cosmic "$applet" && ok "COSMIC sysinfo applet" || warn "COSMIC applet install failed"
    fi
    local wings="$HOME/.config/cosmic/com.system76.CosmicPanel.Panel/v1/plugins_wings"
    if [ ! -f "$wings" ]; then warn "MANUAL: add 'System Monitor' to the panel (COSMIC Settings > Desktop > Panel)"
    elif grep -q "$applet" "$wings"; then skip "applet in panel"
    else
      mkdir -p "$BACKUP_DIR" && cp "$wings" "$BACKUP_DIR/cosmic-plugins_wings"
      sed -i "0,/^], \[\$/s//&\n    \"$applet\",/" "$wings" && ok "added applet to the top panel"
    fi
  else
    gnome-extensions list 2>/dev/null | grep -qx 'Vitals@CoreCoding.com' || warn "MANUAL: install the Vitals GNOME extension via Extension Manager"
  fi
}

# ---------------------------------------------------------------- main
TOOLS=(devtools git zsh fonts nvim wezterm vscode btop conky neofetch claude desktop)
[ "${1:-}" = "--list" ] && { printf '%s\n' "${TOOLS[@]}"; exit 0; }

. /etc/os-release
case "${ID:-} ${ID_LIKE:-}" in *ubuntu*|*debian*|*pop*) ;; *) die "unsupported OS: ${PRETTY_NAME:-unknown} (needs Ubuntu/Pop!_OS/Debian)";; esac

targets=("$@"); [ ${#targets[@]} -eq 0 ] && targets=("${TOOLS[@]}")
log "OS: ${PRETTY_NAME}; backups -> $BACKUP_DIR"
[ -n "$SUDO" ] && { $SUDO -n true 2>/dev/null || $SUDO -v; }
apt_update_once
apt_install git curl stow ca-certificates gpg

failed=()
for t in "${targets[@]}"; do
  declare -F "install_$t" >/dev/null || { warn "unknown tool: $t"; failed+=("$t"); continue; }
  echo; log "━━ $t ━━"
  ( "install_$t" ) || { warn "$t failed"; failed+=("$t"); }
done
echo
[ ${#failed[@]} -eq 0 ] && ok "all done" || { warn "failed: ${failed[*]}"; exit 1; }
[ -d "$BACKUP_DIR" ] && warn "replaced configs were backed up to $BACKUP_DIR"
echo "Log out and back in to apply the default shell."
