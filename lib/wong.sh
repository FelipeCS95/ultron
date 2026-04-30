#!/bin/bash

# Inteligência de backup e restore pessoal via Wong.
# Wong (https://github.com/FelipeCS95/wong) armazena apenas dados:
# dotfiles, configs de editor, chaves públicas, notas.

_wong_backup_editor() {
  local cmd="$1" config_dir="$2" wong_dir="$3"
  command -v "$cmd" &>/dev/null || return 0
  echo "  $cmd..."
  mkdir -p "$wong_dir"
  ultron::check_file "$config_dir/settings.json" \
    && cp "$config_dir/settings.json" "$wong_dir/"
  "$cmd" --list-extensions > "$wong_dir/extensions.txt"
}

_wong_restore_editor() {
  local cmd="$1" config_dir="$2" wong_dir="$3"
  command -v "$cmd" &>/dev/null || return 0
  mkdir -p "$config_dir"
  ultron::check_file "$wong_dir/settings.json" \
    && cp "$wong_dir/settings.json" "$config_dir/"
  ultron::check_file "$wong_dir/extensions.txt" || return 0
  while IFS= read -r ext; do
    [[ -z "$ext" ]] && continue
    "$cmd" --install-extension "$ext" --force 2>/dev/null || true
  done < "$wong_dir/extensions.txt"
}

ultron::backup() {
  local wong="$PROJECTS_PATH/wong"
  ultron::check_directory "$wong" \
    || { echo "Wong não encontrado em: $wong" >&2; return 1; }

  echo "=== Backup ==="

  # Dotfiles
  echo "Dotfiles..."
  for file in .gitconfig .zshrc .vimrc; do
    ultron::check_file ~/"$file" \
      && cp ~/"$file" "$wong/dotfiles/" \
      && echo "  $file"
  done

  # SSH (somente config e chaves públicas)
  echo "SSH..."
  mkdir -p "$wong/dotfiles/.ssh"
  ultron::check_file ~/.ssh/config      && cp ~/.ssh/config      "$wong/dotfiles/.ssh/"
  ultron::check_file ~/.ssh/known_hosts && cp ~/.ssh/known_hosts "$wong/dotfiles/.ssh/"
  for pub in ~/.ssh/*.pub; do
    ultron::check_file "$pub" && cp "$pub" "$wong/dotfiles/.ssh/"
  done

  # Editores
  echo "Editores..."
  _wong_backup_editor code        "$HOME/.config/Code/User"        "$wong/configs/vscode"
  _wong_backup_editor antigravity "$HOME/.config/Antigravity/User" "$wong/configs/antigravity"

  # Terminator
  if ultron::check_file ~/.config/terminator/config; then
    echo "  terminator..."
    mkdir -p "$wong/configs/terminator"
    cp ~/.config/terminator/config "$wong/configs/terminator/"
  fi

  echo "=== Backup concluído ==="
}

ultron::restore_personal() {
  local wong="$PROJECTS_PATH/wong"
  if ! ultron::check_directory "$wong"; then
    echo "Wong não encontrado em $wong, pulando configs pessoais"
    return 0
  fi

  echo "Restaurando configs pessoais..."

  # Dotfiles
  for file in .gitconfig .zshrc .vimrc; do
    ultron::check_file "$wong/dotfiles/$file" \
      && cp "$wong/dotfiles/$file" ~/ \
      && echo "  $file"
  done

  # SSH
  mkdir -p ~/.ssh && chmod 700 ~/.ssh
  if ultron::check_file "$wong/dotfiles/.ssh/config"; then
    cp "$wong/dotfiles/.ssh/config" ~/.ssh/
    chmod 600 ~/.ssh/config
    echo "  SSH config"
  fi
  ultron::check_file "$wong/dotfiles/.ssh/known_hosts" \
    && cp "$wong/dotfiles/.ssh/known_hosts" ~/.ssh/

  # Chave SSH
  if ultron::check_file ~/.ssh/id_ed25519; then
    chmod 600 ~/.ssh/id_ed25519
  else
    echo ""
    echo "Nenhuma chave SSH encontrada. Opções:"
    echo "  1) Gerar nova chave ed25519"
    echo "  2) Pular (copie manualmente depois)"
    read -rp "Escolha [1/2]: " choice
    case "$choice" in
      1)
        read -rp "Email para a chave: " email
        ssh-keygen -t ed25519 -C "$email"
        echo "Chave pública (adicione no GitHub):"
        cat ~/.ssh/id_ed25519.pub
        ;;
      *) echo "Pulando. Depois: chmod 600 ~/.ssh/id_ed25519" ;;
    esac
  fi

  # Editores
  echo "Editores..."
  _wong_restore_editor code        "$HOME/.config/Code/User"        "$wong/configs/vscode"
  _wong_restore_editor antigravity "$HOME/.config/Antigravity/User" "$wong/configs/antigravity"

  # Terminator
  if ultron::check_file "$wong/configs/terminator/config"; then
    mkdir -p ~/.config/terminator
    cp "$wong/configs/terminator/config" ~/.config/terminator/
    echo "  terminator"
  fi
}
