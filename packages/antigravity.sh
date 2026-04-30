#!/bin/bash

# IDE do Google compatível com extensões do VSCode.
# Docs: https://antigravity.google/download/linux
# Nota: settings provavelmente em ~/.config/Antigravity/User/ (padrão VSCode-fork)

PACKAGE_INFO=(antigravity)
REQUIRED_PACKAGES=(curl)

install() {
  sudo mkdir -p /etc/apt/keyrings
  curl -fsSL https://us-central1-apt.pkg.dev/doc/repo-signing-key.gpg \
    | sudo gpg --dearmor --yes -o /etc/apt/keyrings/antigravity-repo-key.gpg
  echo "deb [signed-by=/etc/apt/keyrings/antigravity-repo-key.gpg] https://us-central1-apt.pkg.dev/projects/antigravity-auto-updater-dev/ antigravity-debian main" \
    | sudo tee /etc/apt/sources.list.d/antigravity.list > /dev/null
  sudo apt update && sudo apt install -y antigravity
}

remove() {
  sudo apt-get remove -y antigravity --auto-remove
}

config() {
  command -v antigravity &>/dev/null || return

  local wong_path="$PROJECTS_PATH/wong"
  if [[ ! -d "$wong_path" ]]; then
    echo "  Wong não encontrado, pulando config do Antigravity"
    return
  fi

  local settings_src="$wong_path/configs/antigravity"
  local settings_dst="$HOME/.config/Antigravity/User"
  mkdir -p "$settings_dst"

  if [[ -f "$settings_src/settings.json" ]]; then
    cp "$settings_src/settings.json" "$settings_dst/"
    echo "  settings.json restaurado"
  fi

  if [[ -f "$settings_src/extensions.txt" ]]; then
    echo "  Instalando extensões..."
    while IFS= read -r ext; do
      [[ -z "$ext" ]] && continue
      antigravity --install-extension "$ext" --force 2>/dev/null || true
    done < "$settings_src/extensions.txt"
    echo "  Extensões instaladas"
  fi
}
