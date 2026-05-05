#!/bin/bash

# Pacotes instaláveis via apt sem lógica especial.
# Formato: nome_ultron ou nome_ultron:nome-apt (quando diferem)
APT_PACKAGES=(
  git
  curl
  wget
  vim
  htop
  figlet
  gnupg
  graphviz
  redis
  snapd
  gitk
  libpq_dev:libpq-dev
  libreadline_dev:libreadline-dev
  build_essential:build-essential
  ca_certificates:ca-certificates
  apt_transport_https:apt-transport-https
  software_properties_common:software-properties-common
  gnome_tweaks:gnome-tweaks
  lsb_release:lsb-release
  powerfonts:fonts-powerline
)
