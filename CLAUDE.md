# Ultron — Contexto para o Claude Code

## O que é este projeto

**Ultron** (público) é um framework bash para automatizar setup e gerenciamento de pacotes no Ubuntu/WSL, incluindo uma stack de desenvolvimento moderna (Kitty + tmux + NeoVIM + Starship).
**Wong** (privado, `~/Documents/Projects/wong`) é o repositório de dados pessoais do dono: dotfiles, configs de editor, chaves públicas, notas. **Wong não tem scripts** — toda inteligência fica no Ultron.

Os dois repos pertencem à conta GitHub pessoal `Kvothe62`, acessada via alias SSH `github-personal`.

---

## Arquitetura

```
main.sh              Entrypoint: define PROJECTS_PATH e ULTRON_PATH, sourcia lib/ultron.sh
install.sh           Bootstrap standalone (curl-pipeable para máquina nova)
lib/
  ultron.sh          Define ultron() e alias u=. Guard _ULTRON_INIT evita recursão no subshell.
  check.sh           ultron::check_file, check_directory, check_installed, check_function; _pkg_is_installed
  install.sh         ultron::install — tenta packages/*.sh, depois config/apt.sh, depois config/snap.sh
                     _ultron_spin — wrapper de gum spin com pre-auth sudo; _ultron_list_packages
  remove.sh          ultron::remove
  config.sh          ultron::config — executa config() do package file
  setup.sh           ultron::setup — lê config/setup.sh e instala
  restore.sh         ultron::restore — interativo com gum (multi-select); fallback lê config/restore.sh
  wong.sh            ultron::backup e ultron::restore_personal — toda lógica de backup/restore pessoal
  execution.sh       ultron::execute_function — despacha comandos, busca em projects/ pelo diretório atual
  io.sh              ultron::print_title, ultron::print_separator, ultron::logo_title, ultron::theme
  text.sh            ultron::uppercase, ultron::lowercase, ultron::normalize_project_name; _pkg_normalize
  system.sh          ultron::kill_sessions, ultron::change_files_owner
  project.sh         ultron::dev, ultron::up/down/console/clear/coverage/bisect
projects/
  totalpass.sh       Env vars do projeto TotalPass
  totalpass/
    functions.sh     totalpass::prepare, clear, etc. — delegam para ultron:: onde possível
packages/            arquivos com lógica especial de instalação (repos externos, scripts customizados, config de integração)
config/
  apt.sh             APT_PACKAGES — pacotes simples via apt (formato: chave ou chave:nome-apt)
  snap.sh            SNAP_PACKAGES — pacotes simples via snap
  setup.sh           SETUP_DEPENDENCIES + SETUP_PACKAGES + SETUP_CONFIGS (listas para u setup)
  restore.sh         RESTORE_PACKAGES + RESTORE_CONFIGS — defaults do u restore interativo
  helpers.sh         Completions do shell (_ultron_completion)
  completions.sh     ULTRON_COMPLETIONS — args com tab completion por comando
  env.sh             PROJECT_SYSTEM_PATH (auto-detectado: WSL vs Linux nativo), UID, GID, WONG_REPO
```

---

## Sistema de pacotes

**Pacote simples** → linha em `config/apt.sh` ou `config/snap.sh`. Sem arquivo.

**Pacote especial** → arquivo em `packages/nome.sh`:
```bash
PACKAGE_INFO=(nome-no-dpkg)   # obrigatório quando difere do nome do arquivo (ex: chrome → google-chrome-stable)
PACKAGE_KIND=pkg               # pkg | file | directory
REQUIRED_PACKAGES=(dep1 dep2)  # resolvidas recursivamente antes de instalar

install() { ... }
remove()  { ... }  # opcional
config()  { ... }  # opcional — chamado por u config <pkg>
```

O instalador verifica se já está instalado antes de rodar via `_pkg_is_installed` (em `lib/check.sh`), que lê `PACKAGE_KIND` e `PACKAGE_INFO` do subshell. Aceita parâmetro `any` para o modo de remoção (`check_any_installed`) vs o padrão `all` para instalação (`check_all_installed`). PACKAGE_INFO resolve o "como checar" para casos não-dpkg (ex: `~/.oh-my-zsh` com `PACKAGE_KIND=directory`).

`ultron::check_installed` tenta `dpkg` primeiro, depois `command -v` — detecta binários instalados via asdf, kubectl manual, etc.

---

## Gum — UX interativa

[gum](https://github.com/charmbracelet/gum) é uma dependência opcional que adiciona UI interativa sem reescrever o framework em outra linguagem. Quando ausente, todos os comandos caem para o comportamento original em texto.

**`_ultron_spin "título" comando args`** (em `lib/install.sh`) — wrapper de `gum spin`:
- Se o primeiro argumento do comando for `sudo`, roda `sudo true` antes do spinner para pre-autenticar (evita que o gum spin suprima o prompt de senha)
- Usado em `apt install`, `snap install`, `git clone` e downloads pesados nos packages
- NÃO usado em `curl | sh` (scripts interativos que precisam de output visível)

**Onde gum é usado:**
- `u install` sem argumento → `gum filter` sobre todos os pacotes disponíveis
- `u restore` → `gum choose --no-limit` com pré-seleção dos defaults de `config/restore.sh`
- `u clear` → `gum confirm` no lugar do `read -rp`
- `u theme` sem argumento → menu em dois níveis: starship (lista de presets) ou kitty (`kitten themes`)
- `u install <pkg>` e `u restore` → spinners durante operações longas

---

## Despacho de comandos (`u <cmd>`)

1. `u projects` → `cd $PROJECTS_PATH`
2. `u <nome>` onde nome é um diretório → `cd $PROJECTS_PATH/<nome>`
3. Qualquer outro → subshell: sourcia `lib/*.sh`, chama `ultron::execute_function`
   - `execute_function` tenta `${project_name}::${cmd}` (funções do projeto atual) antes de `ultron::${cmd}`
   - `project_name` = nome do diretório atual normalizado (ex: `totalpass`)
   - Busca em `projects/<project_name>/` — importado automaticamente se existir

---

## Comandos de ambiente de desenvolvimento

**`ultron::dev [projeto] [profile]`** (em `lib/project.sh`):
- Sem argumentos ou `.`: usa diretório atual como projeto
- Com nome: abre `$PROJECTS_PATH/<nome>`
- `profile` opcional é repassado para `u console` (docker compose --profile)
- Dentro do Kitty com `allow_remote_control yes`: abre 4 abas na janela atual
  - `<projeto>: editor` → nvim
  - `<projeto>: console` → `u console [profile]`
  - `<projeto>: claude` → claude
  - `<projeto>: shell` → shell vazio
- Fallback 1: `kitty --session /tmp/ultron-dev-<projeto>.session --detach` (nova janela)
- Fallback 2: tmux (SSH ou ambiente sem Kitty)
- `totalpass::dev` delega para `ultron::dev totalpass "$@"`

**`ultron::theme [preset|kitty]`** (em `lib/io.sh`):
- Sem argumento + gum: menu em dois níveis (starship vs kitty)
- Com preset: aplica via `starship preset`, insere `add_newline = false` e `# preset: <nome>` no root do TOML (antes de seções)
- Com `kitty`: abre `kitten themes`
- Sem gum: lista presets em texto

---

## Decisões de arquitetura (não reverter sem motivo)

- **Wong é puro dado** — sem scripts. Ultron lê os arquivos de Wong, não delega para ele.
- **`_ULTRON_INIT` guard** em `lib/ultron.sh` — impede `u kill_sessions` de rodar infinitamente quando lib/*.sh são sourciados no subshell.
- **`if [[ "$project_name" != "ultron" ]]`** em `execution.sh` — impede reimportar lib/ultron.sh quando o diretório atual se chama "ultron".
- **Funções simples em package files** — `install()`, `remove()`, `config()` sem namespace. Rodam em subshell isolado, sem conflito.
- **`_pkg_is_installed` em `lib/check.sh`** — lê `PACKAGE_KIND`/`PACKAGE_INFO` do contexto do subshell (já setados via `source "$pkg_file"`). Não recebe o arquivo como parâmetro; depende do estado do subshell.
- **`_pkg_normalize` em `lib/text.sh`** — converte nome de pacote para nome de arquivo (`-` → `_`, lowercase). Usada em install, remove e config.
- **`ultron::print_separator`** para linha cheia de `#`; **`ultron::print_title "TEXTO"`** para linha com título. Não chamar `print_title` sem argumento.
- **`config/restore.sh` é o arquivo de defaults** — define pré-seleção do `u restore` interativo. Não é mais necessário editar antes de restaurar.
- **`install.sh` não usa `set -euo pipefail`** — o flag `-e` encerra o script quando qualquer comando retorna não-zero; o prompt de senha do sudo dispara isso e fecha o terminal. Scripts de bootstrap interativos não devem usar `-e`.
- **`${_ULTRON_INIT:-}` em vez de `$_ULTRON_INIT`** — a forma sem `:-` quebra quando bash roda com `-u` (variável não declarada = erro). O `:-` é defensivo e necessário.
- **`packages/zsh.sh` chama `chsh`** — o instalador do oh-my-zsh usa `CHSH=no` delegando a mudança de shell para cá. Não reverter esse `CHSH=no`.
- **`config()` em packages para integração com GNOME** — quando um pacote precisa de ajuste de desktop (ex: slack no Wayland), `config()` cria um override em `~/.local/share/applications/` que sobrevive a `snap refresh`. Chamar com `u config <pkg>` ou via `RESTORE_CONFIGS`.
- **`add_newline` no root do TOML do starship** — presets do starship terminam em seções `[palettes.*]`; qualquer chave adicionada depois é interpretada como campo dessa seção. O `add_newline = false` precisa ficar na segunda linha do arquivo, antes de qualquer `[seção]`.
- **Session files do Kitty em `/tmp/`** — gerados dinamicamente por `_ultron_dev_kitty_session` com projeto e profile. Não são persistidos.
- **`${project}` com chaves em tab titles do Kitty** — zsh interpreta `$project:editor` como `$project` + modificador `:e` (extensão), resultando em string vazia + "ditor". Sempre usar `${project}`.
- **`sudo true` antes do gum spin** — `sudo -v` falha quando variáveis de ambiente do sudo já estão setadas no subshell. `sudo true` autentica sem flags e sem conflito.
- **`curl | sh` sem spinner** — instaladores como kitty, docker, oh-my-zsh e starship precisam de output visível e possível input interativo. Não envolver com gum spin.

---

## Convenções

- Commits em **português**
- Prefixo `ultron::` para todas as funções públicas do framework
- Funções auxiliares privadas com `_` sem namespace (ex: `_wong_backup_editor`, `_ultron_spin`)
- Sem arquivos desnecessários: abstrações só quando há 3+ usos reais
- `u backup` → `ultron::backup` em `lib/wong.sh`
- `u restore` → `ultron::restore` (interativo com gum) + `ultron::restore_personal` automático no final

---

## Fluxo de máquina nova

```
1. git clone https://github.com/Kvothe62/ultron.git ~/Documents/Projects/ultron
2. ~/Documents/Projects/ultron/install.sh
3. logout + login
4. u restore   ← interativo: seleciona pacotes e configs com gum, depois clona Wong
```

O clone do Wong acontece dentro de `ultron::restore_personal` (lib/wong.sh).
Detalhe: se ~/.ssh/config ainda não existe (vem do próprio Wong), o clone usa
`GIT_SSH_COMMAND` com a chave explícita. Após o clone, o SSH config é restaurado.
URL do repo configurada em `config/env.sh` → `WONG_REPO`.

## SSH (duas contas GitHub)

`github-work` → chave de trabalho (`~/.ssh/id_ed25519_work`)
`github-personal` → chave pessoal (`~/.ssh/id_ed25519_personal`)
Ambas com `IdentitiesOnly yes` em `~/.ssh/config`.
Repos pessoais usam `git@github-personal:Kvothe62/...`
