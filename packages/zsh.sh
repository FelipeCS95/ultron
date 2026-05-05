#!/bin/bash

PACKAGE_INFO=(zsh)

install() {
  sudo apt-get install -y zsh
  sudo chsh -s "$(which zsh)" "$USER"
}
