#!/bin/bash

PACKAGE_INFO=(~/.asdf)
PACKAGE_KIND=directory

install() {
  rm -rf ~/.asdf
  git clone https://github.com/asdf-vm/asdf.git ~/.asdf
}
