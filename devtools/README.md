# devtools
Runtimes and base packages (not a stow package; nothing is linked). Run with `./install.sh devtools`.
- Base apt packages: build tools, ripgrep, fd, bat, jq, git-lfs, python3, ...
- Node 24 via **nvm**, Rust via **rustup**, Go from the official tarball into `/usr/local/go`
- Go tools: gopls, buf, sqlc. npm global: vercel
- **Docker** from Docker's official apt repo; adds you to the `docker` group (re-login needed)
