#!/bin/bash

PACKAGE_INFO=(/snap/bin/slack)
PACKAGE_KIND=file

install() {
  sudo snap install slack
}

config() {
  local src="/var/lib/snapd/desktop/applications/slack_slack.desktop"
  local dst="$HOME/.local/share/applications/slack_slack.desktop"
  mkdir -p "$HOME/.local/share/applications"
  sed 's|/snap/bin/slack|/snap/bin/slack --ozone-platform=x11|g' "$src" > "$dst"
  update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
}
