![Ultron logo](media/ultron_wallpaper.jpg)

# Ultron

Framework bash para setup e gerenciamento de ambiente de desenvolvimento no Ubuntu/WSL.

Inclui instalação de pacotes, uma stack de desenvolvimento moderna, e integração com o [Wong](https://github.com/Kvothe62/wong) (repo privado com dotfiles e configs pessoais).

## Stack incluída

| Ferramenta | Papel |
|---|---|
| **Kitty** | Terminal com GPU, session files, Ctrl+Alt+T |
| **tmux** | Multiplexador (fallback para SSH e ambientes sem Kitty) |
| **NeoVIM + LazyVIM** | Editor com LSP, fuzzy finder, git integrado |
| **Starship** | Prompt informativo, troca de tema via `u theme` |
| **zsh + oh-my-zsh** | Shell com autosuggestions, syntax highlighting, fzf |
| **gum** | UI interativa nos comandos do Ultron |
| **lazygit** | Git visual dentro do nvim (`<Space>gg`) e no terminal |

---

## Instalação em uma máquina nova

### 1. Clonar o repo

```shell
sudo apt update && sudo apt install -y git
mkdir -p ~/Documents/Projects
git clone https://github.com/Kvothe62/ultron.git ~/Documents/Projects/ultron
```

### 2. Rodar o setup

```shell
~/Documents/Projects/ultron/install.sh
```

Instala as dependências base (git, zsh, oh-my-zsh, asdf) e configura o shell.

### 3. Logout e login

Necessário para o zsh e oh-my-zsh entrarem em efeito.

### 4. Restaurar pacotes e configs

```shell
u restore
```

Abre um menu interativo para selecionar o que instalar. Os pacotes configurados em `config/restore.sh` já vêm pré-selecionados — ajuste e confirme. Ao final, oferece clonar o Wong e restaurar configs pessoais.

---

Com caminho de projetos customizado:

```shell
PROJECTS_PATH=~/meu/caminho bash -c \
  'git clone https://github.com/Kvothe62/ultron.git $PROJECTS_PATH/ultron && $PROJECTS_PATH/ultron/install.sh'
```

---

## Uso

### Navegação

```shell
u projects            # cd para o diretório de projetos
u <nome_projeto>      # cd para $PROJECTS_PATH/<nome>
```

### Pacotes

```shell
u install             # abre filtro fuzzy para escolher o pacote
u install <pkg>       # instala um pacote específico
u remove <pkg>        # remove um pacote
u config <pkg>        # aplica config pós-install de um pacote
```

### Ambiente de desenvolvimento

```shell
u dev                 # abre ambiente para o projeto do diretório atual
u dev <projeto>       # abre ambiente para o projeto especificado
u dev <projeto> <profile>  # passa profile para u console (docker compose --profile)
```

Abre 4 abas no Kitty: **editor** (nvim) · **console** (docker) · **claude** · **shell**.
Detecta automaticamente se está dentro do Kitty. Fallback: session file (nova janela) ou tmux (SSH).

### Temas

```shell
u theme               # menu interativo: escolhe entre presets do starship ou tema do Kitty
u theme <preset>      # aplica preset diretamente (ex: u theme tokyo-night)
u theme kitty         # abre kitten themes para o visual do terminal
```

### Sistema

```shell
u setup               # setup completo (dependências base)
u restore             # restaura pacotes e configs (interativo com gum)
u backup              # salva dotfiles e configs no Wong
u up [profile]        # docker compose up
u down                # docker compose down
u console [profile]   # docker compose up + exec web sh
u clear               # remove containers, imagens e volumes (pede confirmação)
```

---

## Ambiente de desenvolvimento — `u dev`

O `u dev` monta o ambiente de trabalho de um projeto com um comando:

```shell
u dev <projeto>           # abre o projeto especificado
u dev <projeto> staging   # com docker profile "staging"
u dev .                   # projeto = diretório atual
```

Quando o Kitty está com `allow_remote_control yes` (default da config incluída), abre as abas na janela atual. Se não, abre uma nova janela do Kitty. Em SSH, usa tmux.

Para um projeto novo, crie `projects/<projeto>/functions.sh` com:
```bash
<projeto>::dev() { ultron::dev <projeto> "$@"; }
```

O diretório `projects/` fica no `.gitignore` — é pessoal e fica no Wong.

---

## Adicionando pacotes

**Pacote simples** (só `apt` ou `snap`): adicione uma linha em `config/apt.sh` ou `config/snap.sh`:

```bash
# config/apt.sh
APT_PACKAGES=(
  ...
  meu_pacote             # quando nome_ultron == nome_apt
  meu_pacote:nome-real   # quando os nomes diferem
)
```

**Pacote com lógica especial** (repo externo, script customizado, etc.): crie `packages/nome.sh`:

```bash
#!/bin/bash

PACKAGE_INFO=(nome-no-dpkg)   # quando difere do nome do arquivo
PACKAGE_KIND=pkg              # pkg | file | directory
REQUIRED_PACKAGES=(dep1 dep2) # dependências (opcional)

install() {
  _ultron_spin "Instalando nome..." sudo apt install -y nome
}

config() { ... }  # opcional — chamado por u config <pkg> e no u restore
```

Use `_ultron_spin "título..." comando args` para operações longas. Ele exibe um spinner e pre-autentica o sudo automaticamente quando necessário.

---

## Chaves SSH em uma máquina nova

A recomendação é **gerar uma chave nova por máquina** e registrá-la no GitHub.

### 1. Gerar as chaves

```shell
ssh-keygen -t ed25519 -C "seu@email.com" -f ~/.ssh/id_ed25519_personal
ssh-keygen -t ed25519 -C "voce@empresa.com" -f ~/.ssh/id_ed25519_work
```

### 2. Configurar `~/.ssh/config`

```
Host github-personal
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519_personal
  IdentitiesOnly yes
  AddKeysToAgent yes

Host github-work
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519_work
  IdentitiesOnly yes
  AddKeysToAgent yes
```

### 3. Registrar no GitHub e testar

```shell
cat ~/.ssh/id_ed25519_personal.pub  # GitHub pessoal → Settings → SSH keys
cat ~/.ssh/id_ed25519_work.pub      # GitHub de trabalho → Settings → SSH keys

ssh -T git@github-personal  # Hi Kvothe62!
ssh -T git@github-work      # Hi <usuario_trabalho>!
```

### 4. Clonar repos com o alias correto

```shell
git clone git@github-personal:Kvothe62/ultron.git
git clone git@github-personal:Kvothe62/wong.git
```
