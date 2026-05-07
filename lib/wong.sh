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
  local extensions
  extensions=$("$cmd" --list-extensions 2>/dev/null)
  if [[ -n "$extensions" ]]; then
    echo "$extensions" > "$wong_dir/extensions.txt"
  else
    echo "    Aviso: $cmd --list-extensions retornou vazio — extensions.txt não atualizado." >&2
  fi
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

  # NeoVIM (somente config — plugins ficam em ~/.local/share/nvim, não fazer backup)
  if [[ -d ~/.config/nvim ]]; then
    echo "  nvim..."
    mkdir -p "$wong/configs/nvim"
    cp -r ~/.config/nvim/. "$wong/configs/nvim/"
  fi

  # Kitty
  if [[ -d ~/.config/kitty ]]; then
    echo "  kitty..."
    mkdir -p "$wong/configs/kitty"
    cp -r ~/.config/kitty/. "$wong/configs/kitty/"
  fi

  # Starship
  if ultron::check_file ~/.config/starship.toml; then
    echo "  starship..."
    mkdir -p "$wong/configs/starship"
    cp ~/.config/starship.toml "$wong/configs/starship/"
  fi

  # tmux
  if ultron::check_file ~/.tmux.conf; then
    echo "  tmux..."
    cp ~/.tmux.conf "$wong/dotfiles/"
  fi

  # Terminator
  if ultron::check_file ~/.config/terminator/config; then
    echo "  terminator..."
    mkdir -p "$wong/configs/terminator"
    cp ~/.config/terminator/config "$wong/configs/terminator/"
  fi

  echo "=== Backup concluído ==="
}

_wong_clone() {
  local wong="$1"

  # Garante chave SSH pessoal
  if ! ultron::check_file ~/.ssh/id_ed25519_personal; then
    echo ""
    echo "Chave SSH pessoal não encontrada (~/.ssh/id_ed25519_personal)."
    read -rp "Gerar agora? [y/N] " gen
    if [[ "${gen,,}" == "y" ]]; then
      read -rp "Email para a chave: " email
      ssh-keygen -t ed25519 -C "$email" -f ~/.ssh/id_ed25519_personal
      echo ""
      echo "Adicione esta chave no GitHub (conta FelipeCS95 > Settings > SSH keys):"
      cat ~/.ssh/id_ed25519_personal.pub
      echo ""
      read -rp "Pressione Enter após registrar a chave no GitHub..."
    else
      echo "Pulando clone do Wong."
      return 1
    fi
  fi

  echo "Clonando Wong..."
  # Tenta alias SSH (funciona se ~/.ssh/config já tem github-personal).
  # Se não, usa a chave explicitamente — necessário no primeiro setup,
  # quando o config do Wong ainda não foi restaurado.
  git clone "$WONG_REPO" "$wong" 2>/dev/null \
    || GIT_SSH_COMMAND="ssh -i ~/.ssh/id_ed25519_personal -o StrictHostKeyChecking=accept-new" \
       git clone "git@github.com:FelipeCS95/wong.git" "$wong" \
    || { echo "Falha ao clonar. Tente manualmente: git clone $WONG_REPO" >&2; return 1; }
}

ultron::restore_personal() {
  local wong="$PROJECTS_PATH/wong"

  if ! ultron::check_directory "$wong"; then
    echo ""
    echo "Wong não encontrado em $wong."
    read -rp "Clonar agora? [y/N] " answer
    if [[ "${answer,,}" == "y" ]]; then
      _wong_clone "$wong" || return 0
    else
      echo "Pulando configs pessoais."
      return 0
    fi
  fi

  echo "Restaurando configs pessoais..."

  # Dotfiles
  for file in .gitconfig .zshrc .vimrc; do
    ultron::check_file "$wong/dotfiles/$file" \
      && cp "$wong/dotfiles/$file" ~/ \
      && echo "  $file"
  done

  # SSH config e known_hosts
  mkdir -p ~/.ssh && chmod 700 ~/.ssh
  if ultron::check_file "$wong/dotfiles/.ssh/config"; then
    cp "$wong/dotfiles/.ssh/config" ~/.ssh/
    chmod 600 ~/.ssh/config
    echo "  SSH config"
  fi
  ultron::check_file "$wong/dotfiles/.ssh/known_hosts" \
    && cp "$wong/dotfiles/.ssh/known_hosts" ~/.ssh/

  # Editores
  echo "Editores..."
  _wong_restore_editor code        "$HOME/.config/Code/User"        "$wong/configs/vscode"
  _wong_restore_editor antigravity "$HOME/.config/Antigravity/User" "$wong/configs/antigravity"

  # NeoVIM
  if [[ -d "$wong/configs/nvim" ]]; then
    mkdir -p ~/.config/nvim
    cp -r "$wong/configs/nvim/." ~/.config/nvim/
    echo "  nvim"
  fi

  # Kitty
  if [[ -d "$wong/configs/kitty" ]]; then
    mkdir -p ~/.config/kitty
    cp -r "$wong/configs/kitty/." ~/.config/kitty/
    echo "  kitty"
  fi

  # Starship
  if ultron::check_file "$wong/configs/starship/starship.toml"; then
    mkdir -p ~/.config
    cp "$wong/configs/starship/starship.toml" ~/.config/starship.toml
    echo "  starship"
  fi

  # tmux
  if ultron::check_file "$wong/dotfiles/.tmux.conf"; then
    cp "$wong/dotfiles/.tmux.conf" ~/
    echo "  .tmux.conf"
  fi

  # Terminator
  if ultron::check_file "$wong/configs/terminator/config"; then
    mkdir -p ~/.config/terminator
    cp "$wong/configs/terminator/config" ~/.config/terminator/
    echo "  terminator"
  fi
}
