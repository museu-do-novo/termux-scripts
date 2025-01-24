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

termux-api_url="https://f-droid.org/repo/com.termux.api_51.apk"
termux-api_apk=$TMPDIR/termux-api.apk
hackers-keyboard_url="https://f-droid.org/repo/org.pocketworkstation.pckeyboard_1041001.apk"
hackers-keyboard_apk=$TMPDIR/hackers-keyboard.apk

download_apks=("$termux-api_url" "$hackers-keyboard_url")qq
install_apks=("$termux-api_apk" "$hackers-keyboard_apk")


echo "[*] Download: termux-api.apk..."
wget -o "$apiapkfile" "$termuxapiurl" 

termux-toast "[*] Instalando apk: termux-api"
sleep 2
termux-toast "[!] Abra o instalador!"
sleep 2
termux-open "$apiapkfile"


# Instalando Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "[*] Instalando Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo "[*] Oh My Zsh já está instalado."
fi

# script em zsh para adicionar os plugins
zsh $PWD/termux-scripts/OMZ-plugins-setup.sh

# Mensagem final
echo "[*] Configuração geral concluída!"
exit 0
