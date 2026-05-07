#!/bin/bash

# Pacote renomeado de google-cloud-sdk para google-cloud-cli (>= 371.0.0)

PACKAGE_INFO=(google-cloud-cli)
REQUIRED_PACKAGES=(ca_certificates gnupg curl)

install() {
  curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg \
    | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
  echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" \
    | sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list
  _ultron_spin "Atualizando repositórios..." sudo apt-get update || true
  _ultron_spin "Instalando google-cloud-cli..." sudo apt-get install -y google-cloud-cli
}
