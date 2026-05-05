#!/bin/bash

# =============================================================================
# EDITE ESTE ARQUIVO antes de rodar: ./install.sh
# Descomente os pacotes que quer instalar.
# Para ver os disponíveis: ls packages/ && cat config/apt.sh config/snap.sh
# =============================================================================

RESTORE_PACKAGES=(
  # --- Essenciais ---
  htop
  vim

  # --- Fontes e terminal ---
  powerfonts
  terminator

  # --- Navegador (escolha um) ---
  chrome
  # brave

  # --- Editor de código (escolha um ou mais) ---
  # vscode
  # antigravity   # IDE do Google, compatível com extensões VSCode

  # --- Dev: linguagens e runtimes ---
  # rvm          # Ruby (via PPA)
  asdf         # Version manager universal

  # --- Dev: banco de dados ---
  # postgres
  # redis

  # --- Dev: containers ---
  docker
  docker_compose

  # --- Dev: cloud e infra ---
  # kubectl
  # sdk_cloud    # Google Cloud CLI

  # --- Comunicação ---
  # slack
  # telegram
  # postman

  # --- Outros ---
  # figlet
  # ngrok
  # graphviz     # PDFs de schema de banco (gem erd)
  # libpq_dev    # gem pg
  # yarn
)

RESTORE_CONFIGS=(
  ultron
  vscode        # sincroniza settings e extensões via Wong
  # antigravity   # sincroniza settings e extensões via Wong
  # slack         # corrige lançamento no GNOME/Wayland (override do .desktop)
)
