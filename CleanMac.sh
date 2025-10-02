#!/bin/bash

echo "Limpiando caché de usuario..."
rm -rf ~/Library/Caches/*

echo "Limpiando caché del sistema..."
sudo rm -rf /Library/Caches/*

echo "Limpiando logs del sistema..."
sudo rm -rf /private/var/log/*

echo "Limpiando iconos de Dock/Finder..."
sudo find /private/var/folders/ -name com.apple.dock.iconcache -exec rm {} \;
sudo find /private/var/folders/ -name com.apple.iconservices -exec rm -rf {} \;

echo "Flushing DNS cache..."
sudo dscacheutil -flushcache
sudo killall -HUP mDNSResponder

echo "Reiniciando Finder y Dock..."
killall Dock
killall Finder

echo "✅ Limpieza terminada"
