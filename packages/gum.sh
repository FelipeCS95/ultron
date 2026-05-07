#!/bin/bash

# CLI para interfaces interativas em shell scripts (menus, inputs, confirmações)
PACKAGE_INFO=(gum)

install() {
  sudo mkdir -p /etc/apt/keyrings
  curl -fsSL https://repo.charm.sh/apt/gpg.key \
    | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
  echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" \
    | sudo tee /etc/apt/sources.list.d/charm.list
  sudo apt update || true
  sudo apt install -y gum
}
