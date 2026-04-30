![Ultron logo](media/ultron_wallpaper.jpg)

# Ultron

System automation and package management for Ubuntu/WSL.

Personal configs and secrets are managed by [Wong](https://github.com/FelipeCS95/wong) (separate private repo).

## Quick Install

```shell
git clone https://github.com/FelipeCS95/ultron.git ~/Documents/Projects/ultron
~/Documents/Projects/ultron/install.sh
```

Or with a custom path:

```shell
PROJECTS_PATH=~/my/path
git clone https://github.com/FelipeCS95/ultron.git $PROJECTS_PATH/ultron
$PROJECTS_PATH/ultron/install.sh
```

After setup, logout and login, then:

```shell
u restore
```

## Usage

```shell
u help              # List all commands
u <project_name>    # Navigate to a project
u projects          # Navigate to projects directory
u install <pkg>     # Install a package
u remove <pkg>      # Remove a package
u setup             # Full system setup
u restore           # Restore packages and configs
```

## Adding Packages

Create a file in `packages/` following the declarative format:

```bash
#!/bin/bash

PACKAGE_INFO=(package-name)       # dpkg name(s) to check (optional, defaults to filename)
PACKAGE_KIND=pkg                  # pkg|file|directory (optional, defaults to pkg)
REQUIRED_PACKAGES=(dep1 dep2)     # dependencies (optional)

install() {
  sudo apt-get install -y package-name
}

remove() {  # optional
  sudo apt-get remove -y package-name
}

config() {  # optional
  # post-install configuration
}
```
