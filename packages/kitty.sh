#!/bin/bash

PACKAGE_INFO=(~/.local/kitty.app/bin/kitty)
PACKAGE_KIND=file

install() {
  curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin

  mkdir -p ~/.local/bin
  ln -sf ~/.local/kitty.app/bin/kitty ~/.local/bin/kitty
  ln -sf ~/.local/kitty.app/bin/kitten ~/.local/bin/kitten

  sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator ~/.local/kitty.app/bin/kitty 60
  sudo update-alternatives --set x-terminal-emulator ~/.local/kitty.app/bin/kitty
  gsettings set org.gnome.desktop.default-applications.terminal exec kitty 2>/dev/null || true
}

config() {
  # Integração com GNOME: copia .desktop com paths absolutos
  mkdir -p ~/.local/share/applications
  sed "s|Exec=kitty|Exec=$HOME/.local/kitty.app/bin/kitty|g
       s|TryExec=kitty|TryExec=$HOME/.local/kitty.app/bin/kitty|g
       s|Icon=kitty|Icon=$HOME/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png|g" \
    ~/.local/kitty.app/share/applications/kitty.desktop \
    > ~/.local/share/applications/kitty.desktop
  cp ~/.local/kitty.app/share/applications/kitty-open.desktop \
     ~/.local/share/applications/kitty-open.desktop
  update-desktop-database ~/.local/share/applications 2>/dev/null || true

  # Terminal padrão do GNOME com caminho absoluto (necessário para Ctrl+Alt+T)
  gsettings set org.gnome.desktop.default-applications.terminal exec \
    "$HOME/.local/kitty.app/bin/kitty" 2>/dev/null || true
  gsettings set org.gnome.desktop.default-applications.terminal exec-arg \
    "" 2>/dev/null || true

  local wong="$PROJECTS_PATH/wong"
  if [[ -d "$wong/configs/kitty" ]]; then
    mkdir -p ~/.config/kitty
    cp -r "$wong/configs/kitty/." ~/.config/kitty/
    echo "  kitty config restaurada do Wong"
  fi
}
