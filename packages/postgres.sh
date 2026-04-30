#!/bin/bash

PACKAGE_INFO=(postgresql)

install() {
  sudo install -d /usr/share/postgresql-common/pgdg
  sudo curl -o /usr/share/postgresql-common/pgdg/apt.postgresql.org.asc \
    --fail https://www.postgresql.org/media/keys/ACCC4CF8.asc
  echo "deb [signed-by=/usr/share/postgresql-common/pgdg/apt.postgresql.org.asc] https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" \
    | sudo tee /etc/apt/sources.list.d/pgdg.list
  sudo apt-get update
  sudo apt-get install -y postgresql
}

remove() {
  sudo apt-get remove -y postgresql
}
