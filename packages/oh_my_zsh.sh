#!/bin/bash

PACKAGE_INFO=(~/.oh-my-zsh)
PACKAGE_KIND=directory

install() {
  sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}
