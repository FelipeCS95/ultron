#!/bin/bash

ultron::backup() {
  local wong_path="$PROJECTS_PATH/wong"

  if [[ ! -f "$wong_path/backup.sh" ]]; then
    echo "Wong não encontrado em: $wong_path" >&2
    return 1
  fi

  bash "$wong_path/backup.sh"
}
