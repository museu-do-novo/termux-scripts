#!/bin/bash
# Script para configurar o Termux com ferramentas essenciais e Oh My Zsh
cd
clear
echo "[*] Iniciando configuração do Termux..."
sleep 2

# Mudando espelho de repositório
echo "[*] Alterando espelho de repositórios..."
sleep 2
termux-change-repo
clear

# Atualizando repositórios e pacotes
echo "[*] Atualizando pacotes..."
sleep 2
pkg update && pkg upgrade -y
clear

# Configurando permissões de armazenamento
echo "[*] Configurando permissões de armazenamento..."
sleep 2
termux-setup-storage
clear

------------------------------------------------------------
echo "[*] Instalando pacotes..."
sleep 2
# Lista de pacotes a serem instalados
packages=("tmux" "x11-repo" "tesseract" "root-repo" \
"tur-repo" "python3" "git" "wget" "nmap" \
"netcat-openbsd" "termux-x11-nightly" "termux-api" \
"android-tools" "openssh" "htop" "zsh" "nodejs" \
"curl" "aria2" "axel" "ffmpeg" "libqrencode" "zbar")

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
------------------------------------------------------------
# Intalando pacotes do python
echo "[*] PYTHON: Instalando pacotes..."
sleep 2
python_packages=("yt-dlp" "instaloader")

# Instalando pacotes
for package in "${python_packages[@]}"; do
    echo "[*] Instalando: $package..."
    pip install "$package"
    if [[ $? -ne 0 ]]; then
        echo "[!] Erro ao instalar $package. Abortando..."
        exit 1
    fi
    clear


------------------------------------------------------------

# URLs dos APK para download
download_path="~/storage/downloads/"
download_urls=(\
"https://f-droid.org/repo/com.termux.api_51.apk" \
"https://f-droid.org/repo/org.pocketworkstation.pckeyboard_1041001.apk" \
"https://f-droid.org/repo/org.videolan.vlc_13050736.apk" \
)
wget -O "$download_path" "${download_urls[@]}"
if [[ $? -ne 0 ]]; then
    echo "[!] Erro de download!"
    exit 1
fi

------------------------------------------------------------

# Instalando Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "[*] Instalando Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo "[*] Oh My Zsh já está instalado."
fi

# script em zsh para adicionar os plugins
if [ -f ./OMZ-plugins-setup.sh ]; then
    echo "[*] Executando configuração de plugins para Oh My Zsh..."
    zsh ./OMZ-plugins-setup.sh
else
    echo "[!] Script de configuração de plugins não encontrado: OMZ-plugins-setup.sh"
fi

# Mensagem final
echo "[*] Configuração geral concluída!"
exit 0
