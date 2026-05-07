#!/bin/bash

totalpass::prepare() {
  (
    cd "$PROJECTS_PATH/totalpass" || return 1

    cp build/development/docker-compose.yml.example docker-compose.yml
    cp config/database.yml.sample config/database.yml
    cp .env.example .env
    cp .env.test.example .env.test

    dcb --no-cache
    ultron::up
    dce web bundle
    dce web rake db:setup
    dce web yarn install
  )
}

totalpass::clear() {
  ultron::clear
  rm -f docker-compose.yml config/database.yml .env .env.test
}

totalpass::console() {
  ultron::up
  dce web sh
}

totalpass::coverage() {
  ultron::coverage
}

totalpass::vpn() {
  echo "Command not implemented: vpn" >&2
  return 127
}

totalpass::bisect() {
  ultron::bisect "$@"
}

totalpass::dev() {
  ultron::dev totalpass "$@"
}
