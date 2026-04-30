#!/bin/bash

ultron::logo_title() {
  ultron::print_title
  ultron::check_installed figlet && figlet -w "$COLUMNS" -c ultron || echo 'ultron'
  ultron::print_title
}

ultron::print_title() {
  local title="$*"
  local count=$(((COLUMNS - ${#title}) / 2 - 1))
  printf %${count}s | tr " " "#"
  echo -n " $title "
  printf %${count}s | tr " " "#"
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
