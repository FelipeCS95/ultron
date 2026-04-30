#!/bin/bash

PROJECTS_PATH=$(
  (
    script_dir=$(dirname "${BASH_SOURCE[0]-$0}")
    default_path="${script_dir%/ultron*}"

    if [ -z "$default_path" ] || [ ! -d "$default_path" ]; then
      echo "$HOME/Documents/Projects"
    else
      echo "$default_path"
    fi
  )
)
ULTRON_PATH=$PROJECTS_PATH/ultron

. "$ULTRON_PATH/lib/ultron.sh"
