$()$(
  bash
  #!/usr/bin/env bash

  set -e

  # Detect OS
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "Detected Linux"
    PKG_INSTALL="sudo apt update && sudo apt install -y git neovim curl unzip ripgrep fd-find python3 python3-pip golang-go tmux zsh fonts-powerline wget"
    NODE_INSTALL="curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - && sudo apt install -y nodejs"
    # Install MesloLGS NF Nerd Font
    echo "Instalando fuente MesloLGS NF..."
    mkdir -p ~/.local/share/fonts
    cd ~/.local/share/fonts
    wget -O "MesloLGS NF Regular.ttf" "https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Meslo/L/Regular/MesloLGS%20NF%20Regular.ttf"
    wget -O "MesloLGS NF Bold.ttf" "https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Meslo/L/Bold/MesloLGS%20NF%20Bold.ttf"
    wget -O "MesloLGS NF Italic.ttf" "https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Meslo/L/Italic/MesloLGS%20NF%20Italic.ttf"
    wget -O "MesloLGS NF Bold Italic.ttf" "https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Meslo/L/Bold-Italic/MesloLGS%20NF%20Bold%20Italic.ttf"
    fc-cache -fv
    cd ~
    FONT_MSG="Abre la configuración de tu terminal y selecciona la fuente 'MesloLGS NF' para una mejor experiencia visual."
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Detected macOS"
    PKG_INSTALL="brew update && brew install git neovim curl unzip ripgrep fd python3 go tmux zsh wget && brew tap homebrew/cask-fonts && brew install --cask font-meslo-lg-nerd-font"
    NODE_INSTALL="brew install node"
    FONT_MSG="Abre la configuración de tu terminal y selecciona la fuente 'MesloLGS NF' para una mejor experiencia visual."
  else
    echo "Unsupported OS"
    exit 1
  fi

  # Install packages
  eval $PKG_INSTALL

  # Install Node.js
  eval $NODE_INSTALL

  # Change default shell to zsh
  if [ "$SHELL" != "$(which zsh)" ]; then
    chsh -s "$(which zsh)"
    echo "Shell cambiada a zsh. Reinicia tu terminal para aplicar los cambios."
  fi

  # Install Oh My Zsh
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Instalando Oh My Zsh..."
    RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  fi

  # Clone dotfiles
  if [ ! -d "$HOME/Dotfiles" ]; then
    git clone https://github.com/Not-Minimal/Dotfiles.git "$HOME/Dotfiles"
  fi

  # Backup existing configs
  [ -d "$HOME/.config/nvim" ] && mv "$HOME/.config/nvim" "$HOME/.config/nvim.backup.$(date +%s)"
  [ -f "$HOME/.tmux.conf" ] && mv "$HOME/.tmux.conf" "$HOME/.tmux.conf.backup.$(date +%s)"
  [ -f "$HOME/.zshrc" ] && mv "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%s)"

  # Copy configs from dotfiles
  mkdir -p "$HOME/.config"
  [ -d "$HOME/Dotfiles/nvim" ] && cp -r "$HOME/Dotfiles/nvim" "$HOME/.config/nvim"
  [ -f "$HOME/Dotfiles/tmux.conf" ] && cp "$HOME/Dotfiles/tmux.conf" "$HOME/.tmux.conf"
  [ -f "$HOME/Dotfiles/zshrc" ] && cp "$HOME/Dotfiles/zshrc" "$HOME/.zshrc"

  echo "Instalación finalizada."
  echo "$FONT_MSG"
  echo "Abre Neovim con 'nvim' y tmux con 'tmux'."
  echo "¡Disfruta tu entorno personalizado!"
)$()
