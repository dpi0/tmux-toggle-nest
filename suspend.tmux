#!/usr/bin/env bash

set -e

declare -r CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

tmux_option() {
  local -r option=$(tmux show-option -gqv "$1")
  local -r fallback="$2"
  echo "${option:-$fallback}"
}

declare -r key_config='@suspend_key'
declare -r suspended_options_config='@suspend_suspended_options'
declare -r on_resume_command_config='@suspend_on_resume_command'
declare -r on_suspend_command_config='@suspend_on_suspend_command'

declare -r default_suspended_options=" \
  @mode_indicator_custom_prompt:: ---- , \
  @mode_indicator_custom_mode_style::bg=brightblack\,fg=black \
"
declare -r default_on_resume_command=""
declare -r default_on_suspend_command=""

init_tmux_suspend() {
  local raw_key_option
  raw_key_option="$(tmux_option "$key_config" "x")"

  local bind_flags=""
  local key_table="prefix"
  local key=""

  # Check for global binding (-n)
  if [[ "${raw_key_option}" =~ ^-n[[:space:]]+(.+) ]]; then
    bind_flags="-n"
    key_table="root"
    key="${BASH_REMATCH[1]}"
  else
    key="${raw_key_option}"
  fi

  local suspended_options
  suspended_options="$(tmux_option "$suspended_options_config" "$default_suspended_options")"
  local on_resume_command
  on_resume_command="$(tmux_option "$on_resume_command_config" "$default_on_resume_command")"
  local on_suspend_command
  on_suspend_command="$(tmux_option "$on_suspend_command_config" "$default_on_suspend_command")"

  # Bind for suspend
  tmux bind-key ${bind_flags} -T${key_table} "$key" run-shell "$CURRENT_DIR/scripts/suspend.sh \"$on_suspend_command\" \"$suspended_options\""

  # Bind for resume (in suspended key-table)
  tmux bind-key -T suspended "$key" run-shell "$CURRENT_DIR/scripts/resume.sh \"$on_resume_command\""
}

init_tmux_suspend
