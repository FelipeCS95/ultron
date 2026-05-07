![Ultron logo](media/ultron_wallpaper.jpg)

# Ultron

Automação de sistema e gerenciamento de pacotes para Ubuntu/WSL.

Configs pessoais e segredos são gerenciados pelo [Wong](https://github.com/Kvothe62/wong) (repo privado separado).

## Instalação em uma máquina nova

### 1. Clonar o repo

Se o `git` não estiver instalado:

```shell
sudo apt update && sudo apt install -y git
```

```shell
mkdir -p ~/Documents/Projects
git clone https://github.com/Kvothe62/ultron.git ~/Documents/Projects/ultron
```

### 2. Escolher o que instalar

Abra `config/restore.sh` e descomente os pacotes que quer. É o único arquivo que você precisa editar antes de prosseguir — ele tem comentários explicando cada opção (browsers, editores, docker, etc.).

```shell
nano ~/Documents/Projects/ultron/config/restore.sh
```

### 3. Rodar o setup

```shell
~/Documents/Projects/ultron/install.sh
```

Isso instala as dependências base (git, zsh, oh-my-zsh, asdf…) e configura o shell.

### 4. Logout e login

Necessário para o zsh e oh-my-zsh entrarem em efeito.

### 5. Restaurar pacotes e configs

```shell
u restore
```

Instala tudo que foi configurado no passo 2.

---

Com um caminho de projetos customizado:

```shell
PROJECTS_PATH=~/meu/caminho bash -c \
  'git clone https://github.com/Kvothe62/ultron.git $PROJECTS_PATH/ultron && $PROJECTS_PATH/ultron/install.sh'
```

## Uso

```shell
u help              # Lista todos os comandos
u <nome_projeto>    # Navega para um projeto
u projects          # Navega para o diretório de projetos
u install <pkg>     # Instala um pacote
u remove <pkg>      # Remove um pacote
u backup            # Faz backup das configs pessoais (delega ao Wong)
u setup             # Setup completo do sistema
u restore           # Restaura pacotes e configs
```

## Chaves SSH em uma máquina nova

A recomendação é **gerar uma chave nova por máquina** e registrá-la no GitHub.
É mais seguro do que carregar a mesma chave em todas as máquinas — e leva menos de 5 minutos.

### 1. Gerar as chaves

```shell
# Chave pessoal
ssh-keygen -t ed25519 -C "seu@email.com" -f ~/.ssh/id_ed25519_personal

# Chave de trabalho (se necessário)
ssh-keygen -t ed25519 -C "voce@empresa.com" -f ~/.ssh/id_ed25519_work
```

### 2. Configurar `~/.ssh/config`

Crie ou edite `~/.ssh/config` para rotear cada conta para a chave certa.
O `IdentitiesOnly yes` impede o SSH agent de usar a chave errada quando há múltiplas carregadas.

```
# Conta pessoal — alias "github-personal"
Host github-personal
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519_personal
  IdentitiesOnly yes
  AddKeysToAgent yes

# Conta de trabalho — usa github.com diretamente
Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519_work
  IdentitiesOnly yes
  AddKeysToAgent yes
```

> Com essa config, repositórios pessoais usam `git@github-personal:Usuario/repo.git`
> e repositórios de trabalho usam `git@github.com:Empresa/repo.git`.

### 3. Registrar as chaves públicas no GitHub

```shell
cat ~/.ssh/id_ed25519_personal.pub  # copiar e adicionar em: GitHub → Settings → SSH keys
cat ~/.ssh/id_ed25519_work.pub      # idem, na conta de trabalho
```

### 4. Testar

```shell
ssh -T git@github-personal  # deve mostrar: Hi <usuario_pessoal>!
ssh -T git@github.com       # deve mostrar: Hi <usuario_trabalho>!
```

### 5. Clonar repos pessoais com o alias

```shell
# Ao invés de git@github.com:Kvothe62/...
git clone git@github-personal:Kvothe62/ultron.git
git clone git@github-personal:Kvothe62/wong.git
```

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

**Pacote com lógica especial** (repo externo, script customizado, etc.): crie um arquivo em `packages/`:

```bash
#!/bin/bash

PACKAGE_INFO=(nome-no-dpkg)   # quando difere do nome do arquivo
PACKAGE_KIND=pkg              # pkg | file | directory
REQUIRED_PACKAGES=(dep1 dep2) # dependências (opcional)

install() {
  # lógica de instalação
}

remove() { ... }  # opcional
config() { ... }  # opcional
```
