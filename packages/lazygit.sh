#!/bin/bash

PACKAGE_INFO=(lazygit)

install() {
  sudo add-apt-repository ppa:lazygit-team/release -y
  sudo apt update
  sudo apt install -y lazygit
}
