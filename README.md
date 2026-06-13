# kandi-tmux

Portable tmux config backed by [`oh-my-tmux`](https://github.com/gpakosz/.tmux).

## Contents

- `tmux.conf.local`: the repo-managed `oh-my-tmux` local override
- `scripts/`: custom helper scripts referenced by the config
- `install.sh`: installs `oh-my-tmux` and symlinks this repo into `~/.config/tmux`
- `~/.tmux.conf`: legacy tmux config path is now also linked to the same oh-my-tmux entrypoint for compatibility
- `~/.tmux.conf.local`: legacy oh-my-tmux local override path is also linked so `~/.tmux.conf` loads this repo's customizations

## Install

```bash
git clone <repo-url> ~/Dev/kandi-tmux
cd ~/Dev/kandi-tmux
./install.sh
```

### macOS note

tmux uses `Ctrl+b` as the primary prefix and `Ctrl+a` as secondary (`prefix2`) in this setup.

The installer will:

- clone `oh-my-tmux` to `${XDG_DATA_HOME:-$HOME/.local/share}/tmux/oh-my-tmux` if needed
- back up any existing `~/.config/tmux/tmux.conf`, `~/.tmux.conf`, `~/.tmux.conf.local`, `tmux.conf.local`, and `scripts`
- symlink this repo's config into `~/.config/tmux`

After installation, start tmux normally. `oh-my-tmux` will handle TPM plugin installation from the plugin declarations in `tmux.conf.local`.

## Overrides

You can change the install target with environment variables:

```bash
TMUX_CONFIG_DIR=/some/path/tmux \
OH_MY_TMUX_DIR=/some/path/oh-my-tmux \
./install.sh
```
