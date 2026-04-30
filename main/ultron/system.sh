#!/bin/bash

ultron::kill_sessions() {
  tmux ls 2>/dev/null | grep -v attached | awk -F":" '{print $1}' | xargs -r -n 1 tmux kill-session -t
}

ultron::change_files_owner() {
  local path="${1:-.}"
  sudo chown -R "$(whoami)":"$(whoami)" "$path"
}
