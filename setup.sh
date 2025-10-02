#!/usr/bin/env bash

set -e

# =====================
# UNIVERSAL Dotfiles-main SETUP SCRIPT
# =====================
# Compatible: Ubuntu, Debian, Linux genérico, macOS (Intel/Apple Silicon)
# Instala: herramientas de desarrollo, shell, fuentes, docker, node, etc.
# Autor: Not-Minimal

# --- FUNCIONES AUXILIARES ---
msg() { echo -e "\033[1;32m$1\033[0m"; }
err() { echo -e "\033[1;31m$1\033[0m" >&2; }

# --- FUNCIONES DE VERIFICACIÓN DE VERSIONES ---
ver_ge() { # ver_ge <version1> <version2> ; return 0 si version1 >= version2
  [ "$(printf '%s\n' "$1" "$2" | sort -V | head -n1)" = "$2" ]
}

check_neovim_version() {
  if command -v nvim &>/dev/null; then
    NVIM_VER=$(nvim --version | head -n1 | awk '{print $2}')
    if ver_ge "$NVIM_VER" "0.9.0"; then
      msg "✅ Neovim $NVIM_VER detectado."
    else
      err "❌ Neovim $NVIM_VER detectado, pero se requiere >= 0.9.0."
      return 1
    fi
  else
    err "❌ Neovim no está instalado."
    return 1
  fi
}

check_git_version() {
  if command -v git &>/dev/null; then
    GIT_VER=$(git --version | awk '{print $3}')
    if ver_ge "$GIT_VER" "2.19.0"; then
      msg "✅ Git $GIT_VER detectado."
    else
      err "❌ Git $GIT_VER detectado, pero se requiere >= 2.19.0."
      return 1
    fi
  else
    err "❌ Git no está instalado."
    return 1
  fi
}

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
  err "❌ Sistema operativo no soportado ($OSTYPE)"
  exit 1
fi

msg "🟢 Sistema detectado: $OS"

# --- ASEGURAR SUDO ---
if ! command -v sudo &>/dev/null; then
  if [[ "$OS" == "debian" || "$OS" == "ubuntu" ]]; then
    su -c 'apt update && apt install -y sudo'
  else
    err "❌ sudo no está instalado y no puedo instalarlo automáticamente en este sistema."
    exit 1
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
  sudo apt install -y git curl wget unzip ripgrep fd-find python3 python3-pip gcc g++ make cmake pkg-config libtool libtool-bin autoconf automake tmux htop iftop build-essential fonts-powerline fonts-firacode fonts-jetbrains-mono fonts-hack-ttf ca-certificates gnupg lsb-release software-properties-common fzf docker.io

  # Node.js 20
  msg "📦 Instalando Node.js 20..."
  curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
  sudo apt install -y nodejs

  # Instalar yarn y pnpm globalmente con npm
  msg "📦 Instalando yarn y pnpm globalmente con npm..."
  sudo npm install -g yarn pnpm

  # Instalar lazygit desde binario oficial
  msg "📦 Instalando lazygit desde binario oficial..."
  LAZYGIT_VERSION=$(curl -s https://api.github.com/repos/jesseduffield/lazygit/releases/latest | grep tag_name | cut -d '"' -f4)
  curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION#v}_Linux_x86_64.tar.gz"
  tar xf lazygit.tar.gz lazygit
  sudo install lazygit /usr/local/bin
  rm lazygit lazygit.tar.gz

  # Instalar la última versión de Neovim desde binario oficial
  msg "🟢 Instalando la última versión de Neovim..."
  NVIM_URL="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz"
  curl -LO "$NVIM_URL"
  sudo rm -rf /opt/nvim
  sudo mkdir -p /opt/nvim
  sudo tar -C /opt/nvim --strip-components=1 -xzf nvim-linux-x86_64.tar.gz
  sudo ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim
  rm nvim-linux-x86_64.tar.gz

  # fd alias
  if ! command -v fd &>/dev/null && command -v fdfind &>/dev/null; then
    sudo ln -sf $(which fdfind) /usr/local/bin/fd
  fi

  # Nerd Fonts (MesloLGS NF v3+)
  msg "🔤 Instalando fuente MesloLGS NF v3+..."
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
  brew install git neovim curl wget unzip ripgrep fd python go tmux zsh htop iftop node yarn pnpm docker docker-compose lazygit fzf gcc cmake pkg-config libtool autoconf automake
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
  if [ -f "$HOME/Developments/Dotfiles-main/zshrc" ]; then
    cp "$HOME/Developments/Dotfiles-main/zshrc" "$HOME/.zshrc"
  fi

else
  err "❌ Sistema operativo no soportado para instalación automática."
  exit 1
fi

# --- VERIFICAR VERSIONES DE NEOVIM Y GIT ---
check_neovim_version || err "⚠️  Por favor, instala manualmente Neovim >= 0.9.0."
check_git_version || err "⚠️  Por favor, instala manualmente Git >= 2.19.0."


# --- BACKUP DE CONFIGURACIONES PREVIAS ---
msg "🧠 Haciendo backup de configuraciones previas..."
[ -d "$HOME/.config/nvim" ] && mv "$HOME/.config/nvim" "$HOME/.config/nvim.backup.$(date +%s)"
[ -f "$HOME/.tmux.conf" ] && mv "$HOME/.tmux.conf" "$HOME/.tmux.conf.backup.$(date +%s)"
[ -f "$HOME/.zshrc" ] && mv "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%s)"

# --- COPIAR NUEVOS Dotfiles-main ---
msg "📄 Aplicando configuraciones desde Dotfiles-main..."
mkdir -p "$HOME/.config"
[ -d "$HOME/Developments/Dotfiles-main/nvim" ] && cp -r "$HOME/Developments/Dotfiles-main/nvim" "$HOME/.config/nvim"
[ -f "$HOME/Developments/Dotfiles-main/tmux.conf" ] && cp "$HOME/Developments/Dotfiles-main/tmux.conf" "$HOME/.tmux.conf"
[ -f "$HOME/Developments/Dotfiles-main/zshrc" ] && cp "$HOME/Developments/Dotfiles-main/zshrc" "$HOME/.zshrc"  # <-- Esto ya se hace solo en macOS

# --- FINAL ---
echo ""
msg "✅ Instalación finalizada correctamente."
echo "$FONT_MSG"
echo "📝 Abre Neovim con 'nvim' y tmux con 'tmux'."
echo "🐳 Si usas Docker, cierra sesión y vuelve a entrar para usar Docker sin sudo."
echo "🎉 ¡Disfruta tu entorno personalizado!"
