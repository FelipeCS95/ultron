#!/bin/bash

PACKAGE_INFO=(terminator)

install() {
  sudo apt-get install -y terminator
  sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator "$(which terminator)" 50
  sudo update-alternatives --set x-terminal-emulator "$(which terminator)"
  gsettings set org.gnome.desktop.default-applications.terminal exec terminator 2>/dev/null || true
  gsettings set org.gnome.desktop.default-applications.terminal exec-arg "" 2>/dev/null || true
}
