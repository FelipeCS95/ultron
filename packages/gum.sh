#!/bin/bash

# CLI para interfaces interativas em shell scripts (menus, inputs, confirmações)
PACKAGE_INFO=(gum)

install() {
  sudo mkdir -p /etc/apt/keyrings
  curl -fsSL https://repo.charm.sh/apt/gpg.key \
    | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
  echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" \
    | sudo tee /etc/apt/sources.list.d/charm.list
  _ultron_spin "Atualizando repositórios..." sudo apt update || true
  _ultron_spin "Instalando gum..." sudo apt install -y gum
}
