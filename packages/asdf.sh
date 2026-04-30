#!/bin/bash

# asdf foi reescrito em Go (v0.16+). Agora é um binário standalone,
# não precisa mais de sourcing no .zshrc — só precisa estar no $PATH.
# Nota: remova o plugin "asdf" do oh-my-zsh no .zshrc do Wong (tentava
# sourcear o antigo ~/.asdf/asdf.sh que não existe mais).

PACKAGE_INFO=(/usr/local/bin/asdf)
PACKAGE_KIND=file
REQUIRED_PACKAGES=(curl)

install() {
  local tag
  tag=$(curl -fsSL "https://api.github.com/repos/asdf-vm/asdf/releases/latest" \
    | grep '"tag_name"' | cut -d'"' -f4)
  curl -fsSL "https://github.com/asdf-vm/asdf/releases/download/${tag}/asdf-${tag}-linux-amd64.tar.gz" \
    | sudo tar -xz -C /usr/local/bin asdf
  sudo chmod +x /usr/local/bin/asdf
}
