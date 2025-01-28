#!/bin/bash
# Script para configurar o Termux com ferramentas essenciais e Oh My Zsh
cd
clear
echo "[*] Iniciando configuração do Termux..."

# Configurando permissões de armazenamento
echo "[*] Configurando permissões de armazenamento..."
termux-setup-storage
clear

# Mudando espelho de repositório
echo "[*] Alterando espelho de repositórios..."
sleep 2
termux-change-repo
clear

# Lista de pacotes a serem instalados
packages=("tmux" "x11-repo" "root-repo" "tur-repo" "python3" "git" "wget" "nmap" "netcat-openbsd" "termux-x11-nightly" "termux-api" "android-tools" "openssh" "htop" "zsh" "nodejs" "curl" "aria2" "axel" "ffmpeg" "libqrencode" "zbar")

# Atualizando repositórios e pacotes
echo "[*] Atualizando pacotes..."
pkg update && pkg upgrade -y
clear

# Instalando pacotes
for package in "${packages[@]}"; do
    echo "[*] Instalando: $package..."
    pkg install -y "$package"
    if [[ $? -ne 0 ]]; then
        echo "[!] Erro ao instalar $package. Abortando..."
        exit 1
    fi
    clear
done

# URLs e arquivos APK para download e instalação
termux_api_url="https://f-droid.org/repo/com.termux.api_51.apk"
hackers_keyboard_url="https://f-droid.org/repo/org.pocketworkstation.pckeyboard_1041001.apk"

# Array de URLs e destinos
download_urls=("$termux_api_url" "$hackers_keyboard_url")
apk_files=("~/storage/downloads/termux-api.apk" "~/storage/downloads/hackers-keyboard.apk")

# Baixando e instalando APKs
for i in "${!download_urls[@]}"; do
    echo "[*] Baixando: ${download_urls[i]}..."
    wget -O "${apk_files[i]}" "${download_urls[i]}"
    if [[ $? -ne 0 ]]; then
        echo "[!] Erro ao baixar o APK: ${download_urls[i]}"
        exit 1
    fi
done

clear
echo "Aplicativos essenciais salvos na pasta de download"

# Instalando Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "[*] Instalando Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo "[*] Oh My Zsh já está instalado."
fi

# script em zsh para adicionar os plugins
if [ -f "$PWD/termux-scripts/OMZ-plugins-setup.sh" ]; then
    echo "[*] Executando configuração de plugins para Oh My Zsh..."
    zsh "$PWD/termux-scripts/OMZ-plugins-setup.sh"
else
    echo "[!] Script de configuração de plugins não encontrado: OMZ-plugins-setup.sh"
fi

# Mensagem final
echo "[*] Configuração geral concluída!"
exit 0
