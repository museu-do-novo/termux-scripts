#!/bin/bash
# Script para configurar o Termux com ferramentas essenciais e personalização

# Configurações iniciais
cd || exit
clear
echo -e "\033[1;32m[*] Iniciando configuração do Termux...\033[0m"

# Função para tratar erros
handle_error() {
    echo -e "\033[1;31m[!] Erro na linha $1: $2\033[0m"
    exit 1
}

trap 'handle_error $LINENO "$BASH_COMMAND"' ERR

# Configurar permissões de armazenamento
termux-setup-storage
sleep 2
clear

# Atualizar repositórios
echo -e "\033[1;33m[*] Configurando repositórios...\033[0m"
termux-change-repo <<< $'1\n1\nY\n'
pkg update -y && pkg upgrade -y
clear

# Listas de pacotes
termux_packages=(
    tmux x11-repo tesseract root-repo tur-repo
    python3 git wget nmap netcat-openbsd termux-x11-nightly
    termux-api android-tools openssh htop zsh nodejs curl
    aria2 axel ffmpeg libqrencode zbar proot-distro vim clang
    lsd ripgrep fzf rclone
)

python_packages=(
    yt-dlp instaloader pipx virtualenv requests
    pandas numpy youtube-search-python
)

apk_urls=(
    "https://f-droid.org/repo/com.termux.api_51.apk"
    "https://f-droid.org/repo/org.pocketworkstation.pckeyboard_1041001.apk"
    "https://f-droid.org/repo/org.videolan.vlc_13050736.apk"
    "https://f-droid.org/repo/com.termux.widget_13.apk"
    "https://f-droid.org/repo/com.fsck.k9_28000.apk"
)

# Função de instalação de pacotes
install_packages() {
    echo -e "\033[1;34m\n[*] Instalando pacotes do Termux...\033[0m"
    pkg install -y "${termux_packages[@]}"
}

# Função de instalação de pacotes Python
install_python_packages() {
    echo -e "\033[1;34m\n[*] Instalando pacotes Python...\033[0m"
    pip install --user --upgrade pip wheel
    pip install --user "${python_packages[@]}"
}

# Função para baixar APKs
download_apks() {
    local download_dir=~/storage/downloads/TermuxAPKs
    mkdir -p "$download_dir"
    
    echo -e "\033[1;34m\n[*] Baixando APKs...\033[0m"
    for url in "${apk_urls[@]}"; do
        filename=$(basename "$url")
        echo -e "\033[1;35m[*] Baixando: $filename\033[0m"
        wget -q --show-progress -O "$download_dir/$filename" "$url"
    done
}

# Instalar Oh My Zsh e plugins
install_ohmyzsh() {
    echo -e "\033[1;34m\n[*] Configurando ZSH...\033[0m"
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi

    # Configurar plugins
    plugins=(
        git zsh-autosuggestions zsh-syntax-highlighting
        colored-man-pages command-not-found tmux
    )

    # Clonar repositórios de plugins
    ZSH_CUSTOM="$ZSH/custom"
    mkdir -p "$ZSH_CUSTOM/plugins"
    for plugin in "${plugins[@]}"; do
        if [ ! -d "$ZSH_CUSTOM/plugins/$plugin" ]; then
            case $plugin in
                "zsh-autosuggestions")
                    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/$plugin"
                    ;;
                "zsh-syntax-highlighting")
                    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/$plugin"
                    ;;
            esac
        fi
    done

    # Configurar arquivo .zshrc
    sed -i "s/plugins=(.*)/plugins=(${plugins[*]})/g" ~/.zshrc
    echo -e "\n# Configurações personalizadas" >> ~/.zshrc
    echo 'export PATH=$PATH:~/../usr/bin:~/.local/bin' >> ~/.zshrc
    echo 'alias ll="lsd -l"' >> ~/.zshrc
    echo 'alias la="lsd -la"' >> ~/.zshrc
}

# Executar instalações
install_packages
install_python_packages
download_apks
install_ohmyzsh

# Mensagem final
echo -e "\033[1;32m\n[+] Configuração concluída com sucesso!\033[0m"
echo -e "\033[1;33m[!] APKs baixados em: ~/storage/downloads/TermuxAPKs\033[0m"
echo -e "\033[1;36m[*] Reinicie o Termux e execute: chsh -s zsh\033[0m"ß
