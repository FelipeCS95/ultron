#!/bin/bash

config() {
  mkdir -p ~/.oh-my-zsh/custom
  echo "source ${ULTRON_PATH}/main.sh" > ~/.oh-my-zsh/custom/aliases.zsh
}
