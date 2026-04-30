#!/bin/bash

PACKAGE_INFO=(google-chrome-stable)  # pkg_name seria "chrome"

install() {
  wget -qO- https://dl.google.com/linux/linux_signing_key.pub \
    | sudo gpg --dearmor -o /usr/share/keyrings/google-chrome.gpg
  echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome.gpg] https://dl.google.com/linux/chrome/deb/ stable main" \
    | sudo tee /etc/apt/sources.list.d/google-chrome.list
  sudo apt-get update && sudo apt install -y google-chrome-stable
  xdg-settings set default-web-browser google-chrome.desktop 2>/dev/null || true
}

remove() {
  sudo apt-get remove -y google-chrome-stable --auto-remove
}
