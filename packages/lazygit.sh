#!/bin/bash

PACKAGE_INFO=(lazygit)

install() {
  local version
  version=$(curl -s https://api.github.com/repos/jesseduffield/lazygit/releases/latest \
    | grep '"tag_name"' | sed 's/.*"v\([^"]*\)".*/\1/')
  local url="https://github.com/jesseduffield/lazygit/releases/download/v${version}/lazygit_${version}_Linux_x86_64.tar.gz"
  local tmp
  tmp=$(mktemp -d)
  _ultron_spin "Baixando lazygit v${version}..." curl -L "$url" -o "$tmp/lazygit.tar.gz"
  tar -xf "$tmp/lazygit.tar.gz" -C "$tmp"
  sudo install "$tmp/lazygit" /usr/local/bin/lazygit
  rm -rf "$tmp"
}
