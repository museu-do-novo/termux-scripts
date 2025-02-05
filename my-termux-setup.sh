#!/bin/bash
# Script para configurar o Termux com ferramentas essenciais e Oh My Zsh

# Função para mensagens coloridas
echo_color() {
    local color_code=""
    case $1 in
        red) color_code="\e[31m";;       # Erros
        green) color_code="\e[32m";;     # Sucesso
        yellow) color_code="\e[33m";;    # Avisos
        blue) color_code="\e[34m";;      # Informação
        magenta) color_code="\e[35m";;   # Destaque 1
        cyan) color_code="\e[36m";;      # Destaque 2
        white) color_code="\e[37m";;     # Texto normal
        *) color_code="\e[0m";;          # Padrão (sem cor)
    esac
    echo -e "${color_code}$2\e[0m"
}

cd
clear
echo_color "cyan" "[*] Iniciando configuração do Termux..."
chmod +x ./*.sh
sleep 2

# Mudando espelho de repositório
echo_color "cyan" "[*] Alterando espelho de repositórios..."
sleep 2
termux-change-repo
clear

# Atualizando repositórios e pacotes
echo_color "cyan" "[*] Atualizando pacotes..."
sleep 2
pkg update && pkg upgrade -y
clear

# Configurando permissões de armazenamento
echo_color "cyan" "[*] Configurando permissões de armazenamento..."
sleep 2
termux-setup-storage
clear

# ------------------------------------------------------------
echo_color "magenta" "------------------------------------------------------------"
echo_color "cyan" "[*] Instalando pacotes..."
sleep 2

# Lista de pacotes a serem instalados
packages=("tmux" "x11-repo" "tesseract" "root-repo" \
"tur-repo" "python3" "git" "wget" "nmap" \
"netcat-openbsd" "termux-x11-nightly" "termux-api" \
"android-tools" "openssh" "htop" "zsh" "nodejs" \
"curl" "aria2" "axel" "ffmpeg" "libqrencode" "zbar")

# Instalando pacotes
for package in "${packages[@]}"; do
    echo_color "cyan" "[*] Instalando: $package..."
    pkg install -y "$package"
    if [[ $? -ne 0 ]]; then
        echo_color "red" "[!] Erro ao instalar $package. Abortando..."
        exit 1
    fi
    clear
done

# ------------------------------------------------------------
# Instalando pacotes do python
echo_color "cyan" "[*] PYTHON: Instalando pacotes..."
sleep 2
python_packages=("yt-dlp" "instaloader")

for package in "${python_packages[@]}"; do
    echo_color "cyan" "[*] Instalando: $package..."
    pip install "$package"
    if [[ $? -ne 0 ]]; then
        echo_color "red" "[!] Erro ao instalar $package. Abortando..."
        exit 1
    fi
    clear
done

# ------------------------------------------------------------
# URLs dos APK para download
echo_color "magenta" "------------------------------------------------------------"
download_path="~/storage/downloads/"
download_urls=(\
"https://f-droid.org/repo/com.termux.api_51.apk" \
"https://f-droid.org/repo/org.pocketworkstation.pckeyboard_1041001.apk" \
"https://f-droid.org/repo/org.videolan.vlc_13050736.apk" \
)

echo_color "cyan" "[*] Baixando APKs..."
wget -P "$download_path" "${download_urls[@]}"
if [[ $? -ne 0 ]]; then
    echo_color "red" "[!] Erro de download!"
    exit 1
fi

# ------------------------------------------------------------
# Instalando Oh My Zsh
echo_color "magenta" "------------------------------------------------------------"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo_color "cyan" "[*] Instalando Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo_color "cyan" "[*] Oh My Zsh já está instalado."
fi

# Script em zsh para adicionar os plugins
if [ -f ~/termux-scripts/OMZ-plugins-setup.sh ]; then
    echo_color "cyan" "[*] Executando configuração de plugins para Oh My Zsh..."
    zsh -c 'zsh ~/termux-scripts/OMZ-plugins-setup.sh'
else
    echo_color "red" "[!] Script de configuração de plugins não encontrado: OMZ-plugins-setup.sh"
    exit 1
fi

# Mensagem final
echo_color "green" "[*] Configuração geral concluída!"
exit 0
