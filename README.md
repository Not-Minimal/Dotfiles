# Dotfiles + LazyVim + Terminal Tools Install Guide

Este README te guía para instalar tus dotfiles, LazyVim, y herramientas esenciales de terminal (incluyendo tmux, zsh, Oh My Zsh y la fuente MesloLGS NF) en una nueva máquina Linux o macOS.

---

## Requisitos Previos

- Acceso a una terminal con permisos de usuario (sudo)
- Conexión a Internet

---

## Instalación Paso a Paso

### 1. Instalar dependencias básicas

**Linux (Ubuntu/Debian):**

```bash
sudo apt update
sudo apt install -y git neovim curl unzip ripgrep fd-find python3 python3-pip golang-go tmux zsh fonts-powerline wget
```

**macOS (con Homebrew):**

```bash
brew update
brew install git neovim curl unzip ripgrep fd python3 go tmux zsh wget
brew tap homebrew/cask-fonts
brew install --cask font-meslo-lg-nerd-font
```

### 2. Instalar Node.js

**Linux:**

```bash
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs
```

**macOS:**

```bash
brew install node
```

### 3. Instalar la fuente MesloLGS NF (Nerd Font)

**Linux:**

```bash
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts
wget -O "MesloLGS NF Regular.ttf" "https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Meslo/L/Regular/MesloLGS%20NF%20Regular.ttf"
wget -O "MesloLGS NF Bold.ttf" "https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Meslo/L/Bold/MesloLGS%20NF%20Bold.ttf"
wget -O "MesloLGS NF Italic.ttf" "https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Meslo/L/Italic/MesloLGS%20NF%20Italic.ttf"
wget -O "MesloLGS NF Bold Italic.ttf" "https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Meslo/L/Bold-Italic/MesloLGS%20NF%20Bold%20Italic.ttf"
fc-cache -fv
cd ~
```

Luego, selecciona la fuente "MesloLGS NF" en la configuración de tu terminal.

**macOS:**  
Ya está instalada con el comando anterior de Homebrew. Solo selecciona "MesloLGS NF" en tu terminal.

### 4. Cambiar la shell por defecto a Zsh

```bash
chsh -s $(which zsh)
```

Cierra y vuelve a abrir la terminal para que el cambio surta efecto.

### 5. Instalar Oh My Zsh

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

### 6. Clonar tus dotfiles

```bash
git clone https://github.com/Not-Minimal/Dotfiles.git ~/Dotfiles
```

### 7. Hacer backup de la configuración previa (si existe)

```bash
mv ~/.config/nvim ~/.config/nvim.backup.$(date +%s) 2>/dev/null || true
mv ~/.tmux.conf ~/.tmux.conf.backup.$(date +%s) 2>/dev/null || true
mv ~/.zshrc ~/.zshrc.backup.$(date +%s) 2>/dev/null || true
```

### 8. Copiar configuraciones desde tus dotfiles

```bash
mkdir -p ~/.config
cp -r ~/Dotfiles/nvim ~/.config/nvim
cp ~/Dotfiles/tmux.conf ~/.tmux.conf 2>/dev/null || true
cp ~/Dotfiles/zshrc ~/.zshrc 2>/dev/null || true
```

_Ajusta los nombres de archivo según la estructura de tu repositorio._

### 9. Iniciar Neovim

```bash
nvim
```

La primera vez, los plugins se instalarán automáticamente.

### 10. Iniciar tmux

```bash
tmux
```

---

## Instalación Automática con Script

Puedes usar el siguiente script para automatizar todo el proceso (incluida la instalación de la fuente MesloLGS NF en Linux):

