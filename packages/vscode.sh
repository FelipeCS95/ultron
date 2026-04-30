#!/bin/bash

PACKAGE_INFO=(code)  # pkg_name seria "vscode"
REQUIRED_PACKAGES=(apt_transport_https)

install() {
  wget -qO- https://packages.microsoft.com/keys/microsoft.asc \
    | sudo gpg --dearmor -o /usr/share/keyrings/packages.microsoft.gpg
  echo "deb [arch=amd64,arm64,armhf signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" \
    | sudo tee /etc/apt/sources.list.d/vscode.list
  sudo apt update && sudo apt install -y code
}
