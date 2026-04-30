#!/bin/bash
set -euo pipefail

echo "=== Ultron Bootstrap ==="

# Install git if not present
if ! command -v git &>/dev/null; then
  echo "Installing git..."
  sudo apt update && sudo apt install -y git
fi

# Determine install path
PROJECTS_PATH="${PROJECTS_PATH:-$HOME/Documents/Projects}"
ULTRON_PATH="$PROJECTS_PATH/ultron"

if [[ -d "$ULTRON_PATH/.git" ]]; then
  echo "Ultron already exists at $ULTRON_PATH"
  echo "Pulling latest..."
  git -C "$ULTRON_PATH" pull
else
  echo "Cloning ultron..."
  mkdir -p "$PROJECTS_PATH"
  git clone https://github.com/FelipeCS95/ultron.git "$ULTRON_PATH"
fi

echo ""
echo "Running setup..."
# shellcheck source=/dev/null
source "$ULTRON_PATH/main.sh"
ultron setup

echo ""
echo "=== Ultron installed ==="
echo "Logout and login, then run: u restore"
