#!/bin/bash

echo "Creando symlink para Neovim (LazyVim)..."

# Borra configuración actual si existe
rm -rf ~/.config/nvim

# Crea symlink desde el repo
ln -s ~/Development/Dotfiles/nvim ~/.config/nvim

echo "¡Listo! Ejecuta nvim para que LazyVim se encargue de instalar plugins."
