#!/bin/bash

ultron::logo_title() {
  ultron::print_separator
  ultron::check_installed figlet && figlet -w "${COLUMNS:-80}" -c ultron || echo 'ultron'
  ultron::print_separator
}

ultron::print_separator() {
  printf '%*s\n' "${COLUMNS:-80}" '' | tr ' ' '#'
}

ultron::print_title() {
  local title="$*"
  local cols="${COLUMNS:-80}"
  local count=$(((cols - ${#title}) / 2 - 1))
  printf '%*s' "$count" '' | tr ' ' '#'
  echo -n " $title "
  printf '%*s' "$count" '' | tr ' ' '#'
  echo
}

ultron::get_theme() {
  echo "$ZSH_THEME"
}

ultron::change_theme() {
  local theme="$1"
  sed -i "/ZSH_THEME/c\ZSH_THEME=\"$theme\"" ~/.zshrc
  echo "Theme changed to '$theme'. Restart the terminal."
}
