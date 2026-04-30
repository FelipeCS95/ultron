#!/bin/bash

PACKAGE_INFO=(brave-browser)  # pkg_name seria "brave", mas dpkg tem "brave-browser"
REQUIRED_PACKAGES=(apt_transport_https)

install() {
  sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg \
    https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" \
    | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
  sudo apt update && sudo apt install -y brave-browser
}

remove() {
  sudo apt-get remove -y brave-browser brave-keyring --auto-remove
}
