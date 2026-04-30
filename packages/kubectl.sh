#!/bin/bash

REQUIRED_PACKAGES=(apt_transport_https ca_certificates curl)

install() {
  curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key \
    | sudo gpg --dearmor -o /usr/share/keyrings/kubernetes-apt-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /" \
    | sudo tee /etc/apt/sources.list.d/kubernetes.list
  sudo apt-get update && sudo apt-get install -y kubectl
}
