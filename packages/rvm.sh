#!/bin/bash

REQUIRED_PACKAGES=(software_properties_common)

install() {
  sudo apt-add-repository -y ppa:rael-gc/rvm
  sudo apt-get update && sudo apt-get install -y rvm
  sudo usermod -a -G rvm "$USER"
}
