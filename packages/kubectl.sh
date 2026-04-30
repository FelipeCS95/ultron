#!/bin/bash

# Instala o binário diretamente da release estável oficial.
# Vantagem: sem versão hardcoded na URL, sem repo apt pra manter.

PACKAGE_INFO=(/usr/local/bin/kubectl)
PACKAGE_KIND=file
REQUIRED_PACKAGES=(curl)

install() {
  local version
  version=$(curl -fsSL https://dl.k8s.io/release/stable.txt)
  curl -fsSL "https://dl.k8s.io/release/${version}/bin/linux/amd64/kubectl" -o /tmp/kubectl
  sudo install -o root -g root -m 0755 /tmp/kubectl /usr/local/bin/kubectl
  rm /tmp/kubectl
}
