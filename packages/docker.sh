#!/bin/bash

PACKAGE_INFO=(docker-ce docker-ce-cli containerd.io)
REQUIRED_PACKAGES=(ca_certificates curl)

install() {
  sudo apt-get remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true
  curl -fsSL https://get.docker.com | sudo sh  # método oficial do Docker; executa script remoto sem verificação de hash
  sudo usermod -aG docker "$USER"
}

remove() {
  sudo apt-get purge -y docker-ce docker-ce-cli containerd.io
  sudo rm -rf /var/lib/docker
  sudo rm -rf /var/lib/containerd
}
