# .my-bash-setup

Personal bash terminal setup for Debian/Ubuntu machines: [starship](https://starship.rs) prompt, a handful of `.bashrc` customizations, and `.inputrc` readline bindings (Up/Down arrow do history-substring-search instead of plain history cycling).

## Install

```bash
git clone git@github.com:pcsdelacruz/.my-bash-setup.git ~/.my-bash-setup
cd ~/.my-bash-setup
./install.sh
```

Then open a new shell (or `source ~/.bashrc`).

## What it does

- Installs the `starship` binary into `~/.local/bin` (official installer, non-interactive) if not already present.
- Symlinks `starship.toml` → `~/.config/starship.toml`.
- Symlinks `inputrc` → `~/.inputrc`.
- Symlinks `bash_aliases` → `~/.bash_aliases` (PATH addition, `py3` alias, kubectl shortcut aliases, `starship init` hook). Stock Debian `.bashrc` already sources `~/.bash_aliases` if present, so `~/.bashrc` itself is left untouched. If a machine's `.bashrc` lacks that hook, the installer appends a small guarded block to add it.
- Appends a guarded kubectl block to `~/.bashrc` (`KUBECONFIG` env var, `kubectl` completion, `alias k='kubectl'`) if not already present.
- Never runs on a fresh machine blindly: if any target file already exists and isn't already the correct symlink, it's backed up first as `<file>.bak.<timestamp>` before being replaced.

Safe to re-run any time (e.g. after `git pull`) — every step is a no-op once already applied.

## Updating

- Config changes: `git pull` — since files are symlinked, changes are live immediately.
- Upgrading the starship binary itself: remove `~/.local/bin/starship` and re-run `./install.sh`.
