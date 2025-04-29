# Tmux Toggle Nest

Plugin that lets you suspend **local tmux session**, so that you can work with
**nested remote tmux session** painlessly.

## Changes made in this fork:

- Add better parsing of `@suspend_key` for global keybindings with `-n`, modifiers (`-C` or `-M`) and prefix binds `Prefix + KEY`.
- Add ability to use custom keybindings instead of just a single key.
- Change default keybinding for toggling to `Prefix + x`

**Demo**:

![Tmux Suspend Demo GIF](screenshots/tmux-suspend-demo.gif)

## Usage

With the default keybinding,

Press `Prefix + x` to suspend your local tmux session. In suspeded state, you can only
interact with the currently active pane (which will be running the remote tmux session).

Press `Prefix + x` again in suspended state to resume local tmux session.

_**Note**_: If you have [**tmux-mode-indicator**](https://github.com/dpi0/tmux-mode-indicator)
plugin installed, it'll automatically show indicator for the suspended state.

## Installation

### Installation with [Tmux Plugin Manager](https://github.com/tmux-plugins/tpm)

Add this repository as a TPM plugin in your `.tmux.conf` file:

```conf
set -g @plugin 'dpi0/tmux-toggle-nest'
```

Press `prefix + I` in Tmux environment to install it.

### Manual Installation

Clone this repository:

```bash
git clone https://github.com/dpi0/tmux-toggle-nest.git ~/.tmux/plugins/tmux-toggle-nest
```

Add this line in your `.tmux.conf` file:

```conf
run-shell ~/.tmux/plugins/tmux-toggle-nest/suspend.tmux
```

Reload Tmux configuration file with:

```sh
tmux source-file ~/.tmux.conf
```

## Configuration Options

The following configuration options are available:

### `@suspend_key`

Key used to suspend/resume local tmux session. Default `Prefix + x`

```conf
set -g @suspend_key 'x'
```

To set custom keybindings:

| Goal                          | Example .tmux.conf line        | Behavior                         |
| :---------------------------- | :----------------------------- | :------------------------------- |
| Use `Prefix + x` (Default)    | `set -g @suspend_key 'x'`      | Press Prefix + x to suspend      |
| Use `Alt+x` (without Prefix)  | `set -g @suspend_key '-n M-x'` | Press Alt+x directly to suspend  |
| Use `Ctrl+s` (without Prefix) | `set -g @suspend_key '-n C-s'` | Press Ctrl+s directly to suspend |
| Use `Prefix + Ctrl+a`         | `set -g @suspend_key 'C-a'`    | Press Prefix + Ctrl+a to suspend |

### `@suspend_suspended_options`

Comma-seperated list of items denoting options to set for suspended state.
These options will be automatically reverted when session is resumed.

```conf
set -g @suspend_suspended_options " \
  @mode_indicator_custom_prompt:: ---- , \
  @mode_indicator_custom_mode_style::bg=brightblack\\,fg=black, \
"
```

The syntax of each item is `#{option_name}:#{option_flags}:#{option_value}`.

| Item Segment      | Description                                                                |
| ----------------- | -------------------------------------------------------------------------- |
| `#{option_name}`  | name of the option.                                                        |
| `#{option_flags}` | flags accepted by `set-option`, can be left empty.                         |
| `#{option_value}` | value of the option, commas (`,`) inside value need to be escaped as `\\,` |

For example:

```conf
# remove colors from status line for suspended state
set -g @suspend_suspended_options " \
  status-left-style::bg=brightblack\\,fg=black bold dim, \
  window-status-current-style:gw:bg=brightblack\\,fg=black, \
  window-status-last-style:gw:fg=brightblack, \
  window-status-style:gw:bg=black\\,fg=brightblack, \
  @mode_indicator_custom_prompt:: ---- , \
  @mode_indicator_custom_mode_style::bg=brightblack\\,fg=black, \
"
```

### `@suspend_on_suspend_command` and `@suspend_on_resume_command`

These options can be set to arbritary commands to run when session is
suspended (`@suspend_on_suspend_command`) or resumed (`@suspend_on_resume_command`).

```conf
set -g @suspend_on_resume_command ""
set -g @suspend_on_suspend_command ""
```

For example, you can do the same thing that the default value of `@suspend_suspended_options`
does using these options instead:

```conf
set -g @suspend_suspended_options ""

set -g @suspend_on_resume_command "tmux \
  set-option -uq '@mode_indicator_custom_prompt' \\; \
  set-option -uq '@mode_indicator_custom_mode_style'"

set -g @suspend_on_suspend_command "tmux \
  set-option -q '@mode_indicator_custom_prompt' ' ---- ' \\; \
  set-option -q '@mode_indicator_custom_mode_style' 'bg=brightblack,fg=black'"
```

As you can see, it's more convenient to use `@suspend_suspended_options` for setting
and reverting options.
