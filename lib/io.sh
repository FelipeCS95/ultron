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

_ultron_apply_starship_preset() {
  local target="$1" reset="${2:-false}"

  # Salva o config atual como .bak do preset corrente antes de trocar
  if [[ -f ~/.config/starship.toml ]]; then
    local current_preset
    current_preset=$(_ultron_current_starship_preset)
    cp ~/.config/starship.toml "$HOME/.config/starship-${current_preset}.bak"
  fi

  # Restaura .bak se já existe customização salva para o alvo (a menos que reset)
  local target_bak="$HOME/.config/starship-${target}.bak"
  if [[ -f "$target_bak" && "$reset" == false ]]; then
    cp "$target_bak" ~/.config/starship.toml
    echo "Starship: preset '$target' restaurado do backup. Abra um novo terminal para ver."
    return 0
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
    echo "$preset" | tail -n +2 | grep -v '^add_newline'
  } > ~/.config/starship.toml
  echo "Starship: preset '$target' aplicado. Abra um novo terminal para ver."
}

ultron::theme() {
  local target="${1:-}"

  if [[ -z "$target" ]]; then
    if command -v gum &>/dev/null; then
      local current_starship current_kitty category
      current_starship=$(_ultron_current_starship_preset)
      current_kitty=$(_ultron_current_kitty_theme)

      category=$(printf 'starship\nkitty' | gum choose \
        --header "Starship: $current_starship  ·  Kitty: $current_kitty") || return 0

      if [[ "$category" == "kitty" ]]; then
        kitten themes
        return
      fi

      target=$(starship preset --list 2>/dev/null | gum choose \
        --header "Preset atual: $current_starship" --height 15) || return 0
    else
      echo "Uso: u theme <alvo>"
      echo ""
      echo "Presets do starship ($(_ultron_current_starship_preset)):"
      starship preset --list 2>/dev/null | sed 's/^/  /' || echo "  (starship não encontrado)"
      echo ""
      echo "Tema visual do Kitty ($(_ultron_current_kitty_theme)):"
      echo "  u theme kitty"
      return 0
    fi
  fi

  if [[ "$target" == "kitty" ]]; then
    kitten themes
    return
  fi

  _ultron_apply_starship_preset "$target"
}

ultron::theme_reset() {
  local target="${1:-}"

  if [[ -z "$target" ]]; then
    if command -v gum &>/dev/null; then
      local current_starship
      current_starship=$(_ultron_current_starship_preset)
      target=$(starship preset --list 2>/dev/null | gum choose \
        --header "Reset para preset limpo (atual: $current_starship)" --height 15) || return 0
    else
      echo "Uso: u theme_reset <preset>"
      echo ""
      echo "Presets disponíveis:"
      starship preset --list 2>/dev/null | sed 's/^/  /' || echo "  (starship não encontrado)"
      return 0
    fi
  fi

  _ultron_apply_starship_preset "$target" true
}
