#!/bin/bash

PACKAGE_INFO=(awsvpnclient)

install() {
  wget -qO- https://d20adtppz83p9s.cloudfront.net/GTK/latest/debian-repo/awsvpnclient_public_key.asc \
    | sudo tee /etc/apt/trusted.gpg.d/awsvpnclient_public_key.asc > /dev/null
  echo "deb [arch=amd64] https://d20adtppz83p9s.cloudfront.net/GTK/latest/debian-repo ubuntu main" \
    | sudo tee /etc/apt/sources.list.d/aws-vpn-client.list
  _ultron_spin "Atualizando repositórios..." sudo apt-get update || true
  _ultron_spin "Instalando awsvpnclient..." sudo apt-get install -y awsvpnclient
}

remove() {
  sudo apt-get remove -y awsvpnclient --auto-remove
  sudo rm -f /etc/apt/trusted.gpg.d/awsvpnclient_public_key.asc \
             /etc/apt/sources.list.d/aws-vpn-client.list
}
