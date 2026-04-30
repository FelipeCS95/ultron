#!/bin/bash

REQUIRED_PACKAGES=(curl)

install() {
  sudo apt remove -y cmdtest yarn 2>/dev/null || true
  curl -fsSL https://dl.yarnpkg.com/debian/pubkey.gpg \
    | sudo gpg --dearmor -o /usr/share/keyrings/yarnpkg.gpg
  echo "deb [signed-by=/usr/share/keyrings/yarnpkg.gpg] https://dl.yarnpkg.com/debian/ stable main" \
    | sudo tee /etc/apt/sources.list.d/yarn.list
  sudo apt-get update && sudo apt-get install -y yarn
}

remove() {
  sudo apt-get remove -y yarn && sudo apt-get purge -y yarn
}
