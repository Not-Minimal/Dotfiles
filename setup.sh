#!/usr/bin/env bash

set -e

# =====================
# UNIVERSAL DOTFILES SETUP SCRIPT
# =====================
# Compatible: Ubuntu, Debian, Linux genérico, macOS (Intel/Apple Silicon)
# Instala: herramientas de desarrollo, shell, fuentes, docker, node, etc.
# Autor: Not-Minimal

# --- FUNCIONES AUXILIARES ---
msg() { echo -e "\033[1;32m$1\033[0m"; }
err() { echo -e "\033[1;31m$1\033[0m" >&2; }

# --- DETECCIÓN DE SISTEMA ---
OS=""
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
  else
    OS="linux"
  fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
  OS="macos"
else
  err "❌ Sistema operativo no soportado ($OSTYPE)"; exit 1
fi

msg "🟢 Sistema detectado: $OS"

# --- ASEGURAR SUDO ---
if ! command -v sudo &>/dev/null; then
  if [[ "$OS" == "debian" || "$OS" == "ubuntu" ]]; then
    su -c 'apt update && apt install -y sudo'
  else
    err "❌ sudo no está instalado y no puedo instalarlo automáticamente en este sistema."; exit 1
  fi
fi

# --- ASEGURAR CURL/WGET ---
if ! command -v curl &>/dev/null && ! command -v wget &>/dev/null; then
  if [[ "$OS" == "debian" || "$OS" == "ubuntu" ]]; then
    sudo apt update && sudo apt install -y curl wget
  elif [[ "$OS" == "macos" ]]; then
    /bin/bash -c "$(/usr/bin/which curl || /usr/bin/which wget) -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"
  fi
fi

# --- ACTUALIZAR SISTEMA E INSTALAR PAQUETES ---
if [[ "$OS" == "ubuntu" || "$OS" == "debian" ]]; then
  msg "📦 Actualizando sistema y paquetes..."
  sudo apt update && sudo apt upgrade -y
  sudo apt install -y git neovim vim curl wget unzip ripgrep fd-find python3 python3-pip golang-go tmux htop iftop build-essential fonts-powerline fonts-firacode fonts-jetbrains-mono fonts-hack-ttf ca-certificates gnupg lsb-release software-properties-common

  # Node.js 20
  msg "📦 Instalando Node.js 20, yarn, pnpm..."
  curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
  sudo apt install -y nodejs
  sudo npm install -g yarn pnpm

  # Docker
  msg "🐳 Instalando Docker y Docker Compose..."
  sudo apt remove -y docker docker-engine docker.io containerd runc || true
  sudo apt install -y ca-certificates curl gnupg
  sudo install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/$(. /etc/os-release && echo "$ID")/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  echo "\
deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/$(. /etc/os-release && echo "$ID") $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt update
  sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  sudo usermod -aG docker "$USER"

  # fd alias
  if ! command -v fd &>/dev/null && command -v fdfind &>/dev/null; then
    sudo ln -sf $(which fdfind) /usr/local/bin/fd
  fi

  # Nerd Fonts (MesloLGS NF)
  msg "🔤 Instalando fuente MesloLGS NF..."
  mkdir -p ~/.local/share/fonts
  cd ~/.local/share/fonts
  wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/Meslo.zip
  unzip -o Meslo.zip -d Meslo
  cp Meslo/*.ttf .
  rm -rf Meslo Meslo.zip
  fc-cache -fv
  cd ~
  FONT_MSG="ℹ️ Abre la configuración de tu terminal y selecciona la fuente 'MesloLGS NF' para una mejor experiencia visual."

elif [[ "$OS" == "macos" ]]; then
  # Homebrew
  if ! command -v brew &>/dev/null; then
    msg "🍺 Instalando Homebrew..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$($(command -v brew) shellenv)"
  fi
  msg "📦 Actualizando Homebrew y paquetes..."
  brew update
  brew install git neovim vim curl wget unzip ripgrep fd python go tmux zsh htop iftop node yarn pnpm docker docker-compose
  brew tap homebrew/cask-fonts
  brew install --cask font-meslo-lg-nerd-font font-fira-code font-jetbrains-mono font-hack-nerd-font
  FONT_MSG="ℹ️ Abre la configuración de tu terminal y selecciona la fuente 'MesloLGS NF' para una mejor experiencia visual."

  # --- CAMBIAR SHELL POR DEFECTO A ZSH ---
  if [ "$SHELL" != "$(which zsh)" ]; then
    msg "💡 Intentando cambiar el shell por defecto a Zsh..."
    CHSH_OK=0
    if command -v sudo &>/dev/null; then
      if sudo chsh -s "$(which zsh)" "$USER"; then
        msg "✅ Shell cambiado a Zsh para el usuario $USER. Reinicia tu terminal o reconéctate para aplicar los cambios."
        CHSH_OK=1
      fi
    fi
    if [ $CHSH_OK -eq 0 ]; then
      if chsh -s "$(which zsh)"; then
        msg "✅ Shell cambiado a Zsh. Reinicia tu terminal o reconéctate para aplicar los cambios."
        CHSH_OK=1
      fi
    fi
    if [ $CHSH_OK -eq 0 ]; then
      err "⚠️  No se pudo cambiar el shell por defecto automáticamente (puede requerir contraseña o permisos de root)."
      msg "ℹ️  Si usas SSH o no tienes contraseña, puedes añadir esto al final de tu ~/.bashrc para usar Zsh automáticamente:"
      echo 'if command -v zsh >/dev/null 2>&1; then exec zsh; fi'
    fi
  fi

  # --- INSTALAR OH MY ZSH ---
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    msg "🚀 Instalando Oh My Zsh..."
    RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  fi

  # --- COPIAR ZSHRC ---
  if [ -f "$HOME/Dotfiles/zshrc" ]; then
    cp "$HOME/Dotfiles/zshrc" "$HOME/.zshrc"
  fi

else
  err "❌ Sistema operativo no soportado para instalación automática."; exit 1
fi

# --- CLONAR DOTFILES ---
if [ ! -d "$HOME/Dotfiles" ]; then
  msg "📂 Clonando repositorio de Dotfiles..."
  git clone https://github.com/Not-Minimal/Dotfiles.git "$HOME/Dotfiles"
fi

# --- BACKUP DE CONFIGURACIONES PREVIAS ---
msg "🧠 Haciendo backup de configuraciones previas..."
[ -d "$HOME/.config/nvim" ] && mv "$HOME/.config/nvim" "$HOME/.config/nvim.backup.$(date +%s)"
[ -f "$HOME/.tmux.conf" ] && mv "$HOME/.tmux.conf" "$HOME/.tmux.conf.backup.$(date +%s)"
[ -f "$HOME/.zshrc" ] && mv "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%s)"

# --- COPIAR NUEVOS DOTFILES ---
msg "📄 Aplicando configuraciones desde Dotfiles..."
mkdir -p "$HOME/.config"
[ -d "$HOME/Dotfiles/nvim" ] && cp -r "$HOME/Dotfiles/nvim" "$HOME/.config/nvim"
[ -f "$HOME/Dotfiles/tmux.conf" ] && cp "$HOME/Dotfiles/tmux.conf" "$HOME/.tmux.conf"
# [ -f "$HOME/Dotfiles/zshrc" ] && cp "$HOME/Dotfiles/zshrc" "$HOME/.zshrc"  # <-- Esto ya se hace solo en macOS

# --- FINAL ---
echo ""
msg "✅ Instalación finalizada correctamente."
echo "$FONT_MSG"
echo "📝 Abre Neovim con 'nvim' y tmux con 'tmux'."
echo "🐳 Si usas Docker, cierra sesión y vuelve a entrar para usar Docker sin sudo."
echo "🎉 ¡Disfruta tu entorno personalizado!"
