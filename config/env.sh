#!/bin/bash

if grep -qi microsoft /proc/version 2>/dev/null; then
  PROJECT_SYSTEM_PATH="wsl.localhost/Ubuntu"
else
  PROJECT_SYSTEM_PATH=""
fi
GID=$(id -g)
WONG_REPO="git@github-personal:FelipeCS95/wong.git"
