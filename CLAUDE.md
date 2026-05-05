# Ultron — Contexto para o Claude Code

## O que é este projeto

**Ultron** (público) é um framework bash para automatizar setup e gerenciamento de pacotes no Ubuntu/WSL.
**Wong** (privado, `~/Documents/Projects/wong`) é o repositório de dados pessoais do dono: dotfiles, configs de editor, chaves públicas, notas. **Wong não tem scripts** — toda inteligência fica no Ultron.

Os dois repos pertencem à conta GitHub pessoal `FelipeCS95`, acessada via alias SSH `github-personal`.

---

## Arquitetura

```
main.sh              Entrypoint: define PROJECTS_PATH e ULTRON_PATH, sourcia lib/ultron.sh
install.sh           Bootstrap standalone (curl-pipeable para máquina nova)
lib/
  ultron.sh          Define ultron() e alias u=. Guard _ULTRON_INIT evita recursão no subshell.
  check.sh           ultron::check_file, check_directory, check_installed, check_function; _pkg_is_installed
  install.sh         ultron::install — tenta packages/*.sh, depois config/apt.sh, depois config/snap.sh
  remove.sh          ultron::remove
  config.sh          ultron::config — executa config() do package file
  setup.sh           ultron::setup — lê config/setup.sh e instala
  restore.sh         ultron::restore — lê config/restore.sh, instala, chama ultron::restore_personal
  wong.sh            ultron::backup e ultron::restore_personal — toda lógica de backup/restore pessoal
  execution.sh       ultron::execute_function — despacha comandos, busca em projects/ pelo diretório atual
  io.sh              ultron::print_title, ultron::print_separator, ultron::logo_title, ultron::change_theme
  text.sh            ultron::uppercase, ultron::lowercase, ultron::normalize_project_name; _pkg_normalize
  system.sh          ultron::kill_sessions, ultron::change_files_owner
  project.sh         ultron::up/down/console/clear/coverage/bisect (wrappers Docker para qualquer projeto)
projects/
  totalpass.sh       Env vars do projeto TotalPass
  totalpass/
    functions.sh     totalpass::prepare, clear, etc. — delegam para ultron:: onde possível
packages/            arquivos com lógica especial de instalação (repos externos, scripts customizados, config de integração)
config/
  apt.sh             APT_PACKAGES — pacotes simples via apt (formato: chave ou chave:nome-apt)
  snap.sh            SNAP_PACKAGES — pacotes simples via snap
  setup.sh           SETUP_DEPENDENCIES + SETUP_PACKAGES + SETUP_CONFIGS (listas para u setup)
  restore.sh         RESTORE_PACKAGES + RESTORE_CONFIGS — EDITAR AQUI antes de rodar install.sh
  helpers.sh         Completions do shell (_ultron_completion)
  completions.sh     ULTRON_COMPLETIONS — args com tab completion por comando
  env.sh             PROJECT_SYSTEM_PATH (auto-detectado: WSL vs Linux nativo), UID, GID
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

## Despacho de comandos (`u <cmd>`)

1. `u projects` → `cd $PROJECTS_PATH`
2. `u <nome>` onde nome é um diretório → `cd $PROJECTS_PATH/<nome>`
3. Qualquer outro → subshell: sourcia `lib/*.sh`, chama `ultron::execute_function`
   - `execute_function` tenta `${project_name}::${cmd}` (funções do projeto atual) antes de `ultron::${cmd}`
   - `project_name` = nome do diretório atual normalizado (ex: `totalpass`)
   - Busca em `projects/<project_name>/` — importado automaticamente se existir

---

## Decisões de arquitetura (não reverter sem motivo)

- **Wong é puro dado** — sem scripts. Ultron lê os arquivos de Wong, não delega para ele.
- **`_ULTRON_INIT` guard** em `lib/ultron.sh` — impede `u kill_sessions` de rodar infinitamente quando lib/*.sh são sourciados no subshell.
- **`if [[ "$project_name" != "ultron" ]]`** em `execution.sh` — impede reimportar lib/ultron.sh quando o diretório atual se chama "ultron".
- **Funções simples em package files** — `install()`, `remove()`, `config()` sem namespace. Rodam em subshell isolado, sem conflito.
- **`_pkg_is_installed` em `lib/check.sh`** — lê `PACKAGE_KIND`/`PACKAGE_INFO` do contexto do subshell (já setados via `source "$pkg_file"`). Não recebe o arquivo como parâmetro; depende do estado do subshell.
- **`_pkg_normalize` em `lib/text.sh`** — converte nome de pacote para nome de arquivo (`-` → `_`, lowercase). Usada em install, remove e config.
- **`ultron::print_separator`** para linha cheia de `#`; **`ultron::print_title "TEXTO"`** para linha com título. Não chamar `print_title` sem argumento.
- **config/restore.sh é o arquivo de configuração do usuário** — deve ter todas as opções comentadas para o usuário escolher antes de rodar install.sh.
- **`install.sh` não usa `set -euo pipefail`** — o flag `-e` encerra o script quando qualquer comando retorna não-zero; o prompt de senha do sudo dispara isso e fecha o terminal. Scripts de bootstrap interativos não devem usar `-e`.
- **`${_ULTRON_INIT:-}` em vez de `$_ULTRON_INIT`** — a forma sem `:-` quebra quando bash roda com `-u` (variável não declarada = erro). O `:-` é defensivo e necessário.
- **`packages/zsh.sh` chama `chsh`** — o instalador do oh-my-zsh usa `CHSH=no` delegando a mudança de shell para cá. Não reverter esse `CHSH=no`.
- **`config()` em packages para integração com GNOME** — quando um pacote precisa de ajuste de desktop (ex: slack no Wayland), `config()` cria um override em `~/.local/share/applications/` que sobrevive a `snap refresh`. Chamar com `u config <pkg>` ou via `RESTORE_CONFIGS`.

---

## Convenções

- Commits em **português**
- Prefixo `ultron::` para todas as funções públicas do framework
- Funções auxiliares privadas com `_` sem namespace (ex: `_wong_backup_editor`)
- Sem arquivos desnecessários: abstrações só quando há 3+ usos reais
- `u backup` → `ultron::backup` em `lib/wong.sh`
- `u restore` → `ultron::restore` + `ultron::restore_personal` automático no final

---

## Fluxo de máquina nova

```
1. git clone https://github.com/FelipeCS95/ultron.git ~/Documents/Projects/ultron
2. nano ~/Documents/Projects/ultron/config/restore.sh   # escolher pacotes
3. ~/Documents/Projects/ultron/install.sh
4. logout + login
5. u restore
   → instala pacotes e configs do sistema
   → oferece: gerar chave SSH pessoal → clonar Wong → restaurar configs pessoais
```

O clone do Wong acontece dentro de `ultron::restore_personal` (lib/wong.sh).
Detalhe: se ~/.ssh/config ainda não existe (vem do próprio Wong), o clone usa
`GIT_SSH_COMMAND` com a chave explícita. Após o clone, o SSH config é restaurado.
URL do repo configurada em `config/env.sh` → `WONG_REPO`.

## SSH (duas contas GitHub)

`github.com` → chave TotalPass (`~/.ssh/id_ed25519`)
`github-personal` → chave pessoal (`~/.ssh/id_ed25519_personal`)
Ambas com `IdentitiesOnly yes` em `~/.ssh/config`.
Repos pessoais usam `git@github-personal:FelipeCS95/...`
