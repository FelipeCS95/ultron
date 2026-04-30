#!/bin/bash

install() {
  sudo apt-get install -y zsh
  chsh -s "$(which zsh)"
}
