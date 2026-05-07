#!/bin/bash

REQUIRED_PACKAGES=(software_properties_common)

install() {
  sudo apt-add-repository -y ppa:rael-gc/rvm
  _ultron_spin "Atualizando repositórios..." sudo apt-get update || true
  _ultron_spin "Instalando rvm..." sudo apt-get install -y rvm
  sudo usermod -a -G rvm "$USER"
}
