### Tmux hjkl pane navigator

This is a simple Tmux plugin that enables seamless navigation between Tmux panes and Neovim splits using the same keybindings.

By using `Ctrl + h`, `Ctrl + j`, `Ctrl + k`, and `Ctrl + l`, you can move between Tmux panes or Neovim splits without needing to use the Tmux prefix key. The plugin intelligently detects if you are inside a Neovim session and passes the keybindings through, otherwise it navigates Tmux panes.

---

### Installation

This plugin is designed to be installed using the [Tmux Plugin Manager (TPM)](https://github.com/tmux-plugins/tpm).

1. Add the plugin to your `~/.tmux.conf` file:

    ```sh
    set -g @plugin 'codxse/tmux-hjkl-pane-navigator.git'
    ```

2. Reload your Tmux environment by running `tmux source-file ~/.tmux.conf` in your terminal.

3. Press your Tmux prefix (`Ctrl+b` by default) followed by `I` (capital `i`) to fetch and install the plugin.

---

### Usage

Once installed, the following keybindings are active:

- `Ctrl + h`: Navigate to the pane/split on the left.
- `Ctrl + j`: Navigate to the pane/split below.
- `Ctrl + k`: Navigate to the pane/split above.
- `Ctrl + l`: Navigate to the pane/split on the right.
- `Ctrl + \`: Navigate to the last active pane/split.

The plugin will automatically detect if you are in a Neovim session and handle the navigation accordingly. You do not need to use your Tmux prefix key for these commands.
