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

_ultron_current_starship_preset() {
  grep -m1 '^# preset:' ~/.config/starship.toml 2>/dev/null | sed 's/# preset: //' || echo "personalizado"
}

_ultron_current_kitty_theme() {
  local f=~/.config/kitty/current-theme.conf
  [[ -f "$f" ]] && grep -m1 '^## ' "$f" 2>/dev/null | sed 's/## //' || echo "padrão"
}

ultron::theme() {
  local target="${1:-}"

  if [[ -z "$target" ]]; then
    echo "Uso: u theme <alvo>"
    echo ""
    echo "Presets do starship ($(_ultron_current_starship_preset)):"
    starship preset --list 2>/dev/null | sed 's/^/  /' || echo "  (starship não encontrado)"
    echo ""
    echo "Tema visual do Kitty ($(_ultron_current_kitty_theme)):"
    echo "  u theme kitty"
    return 0
  fi

  if [[ "$target" == "kitty" ]]; then
    kitten themes
    return
  fi

  # add_newline precisa ficar no root do TOML (antes de qualquer [seção])
  local preset
  preset=$(starship preset "$target" 2>/dev/null) || {
    echo "Alvo desconhecido: $target" >&2
    echo "Use 'u theme' sem argumentos para ver as opções." >&2
    return 1
  }
  {
    echo "$preset" | head -1
    echo "# preset: $target"
    echo 'add_newline = false'
    echo "$preset" | tail -n +2
  } > ~/.config/starship.toml
  echo "Starship: preset '$target' aplicado. Abra um novo terminal para ver."
}
