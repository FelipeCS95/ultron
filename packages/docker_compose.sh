#!/bin/bash

PACKAGE_INFO=(docker-compose-plugin)  # pkg_name seria "docker_compose"
REQUIRED_PACKAGES=(docker)

install() {
  _ultron_spin "Instalando Docker Compose..." sudo apt-get install -y docker-compose-plugin
}

remove() {
  sudo apt-get remove -y docker-compose-plugin
}
