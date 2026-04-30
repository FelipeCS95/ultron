#!/bin/bash
set -euo pipefail

echo "=== Ultron Bootstrap ==="

# Install git if not present
if ! command -v git &>/dev/null; then
  echo "Instalando git..."
  sudo apt update && sudo apt install -y git
fi

# Determine install path
PROJECTS_PATH="${PROJECTS_PATH:-$HOME/Documents/Projects}"
ULTRON_PATH="$PROJECTS_PATH/ultron"

if [[ -d "$ULTRON_PATH/.git" ]]; then
  echo "Ultron já existe em $ULTRON_PATH"
  echo "Atualizando..."
  git -C "$ULTRON_PATH" pull
else
  echo "Clonando ultron..."
  mkdir -p "$PROJECTS_PATH"
  git clone https://github.com/FelipeCS95/ultron.git "$ULTRON_PATH"
fi

echo ""
echo "Executando setup..."
# shellcheck source=/dev/null
source "$ULTRON_PATH/main.sh"
ultron setup

echo ""
echo "=== Ultron instalado ==="
echo "Faça logout e login, depois execute: u restore"
