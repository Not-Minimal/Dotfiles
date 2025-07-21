#!/usr/bin/env bash

set -e

# Detectar sistema operativo de forma confiable
if [ -z "$OSTYPE" ]; then
  OSTYPE=$(uname | tr '[:upper:]' '[:lower:]')-gnu
fi

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  echo "🟢 Sistema operativo detectado: Linux"

  echo "📦 Instalando paquetes básicos..."
  sudo apt update
  sudo apt install -y git neovim curl unzip ripgrep fd-find python3 python3-pip golang-go tmux zsh fonts-powerline wget

  echo "📦 Instalando Node.js 20..."
  curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
  sudo apt install -y nodejs

  echo "🔤 Instalando fuente MesloLGS NF..."
  mkdir -p ~/.local/share/fonts
  cd ~/.local/share/fonts
  wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/Meslo.zip
  unzip Meslo.zip -d Meslo
  cp Meslo/*.ttf .
  rm -rf Meslo Meslo.zip
  fc-cache -fv
  cd ~
  FONT_MSG="ℹ️ Abre la configuración de tu terminal y selecciona la fuente 'MesloLGS NF' para una mejor experiencia visual."

elif [[ "$OSTYPE" == "darwin"* ]]; then
  echo "🟢 Sistema operativo detectado: macOS"
  brew update
  brew install git neovim curl unzip ripgrep fd python3 go tmux zsh wget
  brew tap homebrew/cask-fonts
  brew install --cask font-meslo-lg-nerd-font
  FONT_MSG="ℹ️ Abre la configuración de tu terminal y selecciona la fuente 'MesloLGS NF' para una mejor experiencia visual."

else
  echo "❌ Sistema operativo no soportado"
  exit 1
fi

# Cambiar shell por defecto a zsh
if [ "$SHELL" != "$(which zsh)" ]; then
  echo "💡 Cambiando el shell por defecto a Zsh..."
  chsh -s "$(which zsh)"
  echo "✅ Shell cambiado a Zsh. Reinicia tu terminal para aplicar los cambios."
fi

# Instalar Oh My Zsh si no existe
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "🚀 Instalando Oh My Zsh..."
  RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# Clonar Dotfiles si no existe
if [ ! -d "$HOME/Dotfiles" ]; then
  echo "📂 Clonando repositorio de Dotfiles..."
  git clone https://github.com/Not-Minimal/Dotfiles.git "$HOME/Dotfiles"
fi

# Respaldar configuraciones existentes
echo "🧠 Haciendo backup de configuraciones previas..."
[ -d "$HOME/.config/nvim" ] && mv "$HOME/.config/nvim" "$HOME/.config/nvim.backup.$(date +%s)"
[ -f "$HOME/.tmux.conf" ] && mv "$HOME/.tmux.conf" "$HOME/.tmux.conf.backup.$(date +%s)"
[ -f "$HOME/.zshrc" ] && mv "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%s)"

# Copiar nuevos dotfiles
echo "📄 Aplicando configuraciones desde Dotfiles..."
mkdir -p "$HOME/.config"
[ -d "$HOME/Dotfiles/nvim" ] && cp -r "$HOME/Dotfiles/nvim" "$HOME/.config/nvim"
[ -f "$HOME/Dotfiles/tmux.conf" ] && cp "$HOME/Dotfiles/tmux.conf" "$HOME/.tmux.conf"
[ -f "$HOME/Dotfiles/zshrc" ] && cp "$HOME/Dotfiles/zshrc" "$HOME/.zshrc"

echo ""
echo "✅ Instalación finalizada correctamente."
echo "$FONT_MSG"
echo "📝 Abre Neovim con 'nvim' y tmux con 'tmux'."
echo "🎉 ¡Disfruta tu entorno personalizado!"
