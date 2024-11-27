#!/bin/bash
# Script para configurar o Termux com ferramentas essenciais e Oh My Zsh
 cd
clear
echo "Iniciando configuração do Termux..."

# Lista de pacotes a serem instalados
packages=("x11-repo" "root-repo" "tur-repo" "python3" "git" "wget" "nmap" "netcat-openbsd" "termux-x11-nightly" "termux-api" "android-tools" "openssh" "btop" "zsh" "nodejs" "curl")

# Atualizando repositórios e pacotes
echo "[*] Atualizando pacotes..."
pkg update && pkg upgrade -y

# Instalando pacotes
for package in "${packages[@]}"; do
    echo "[*] Instalando: $package..."
    pkg install -y "$package"
    if [[ $? -ne 0 ]]; then
        echo "[!] Erro ao instalar $package. Abortando..."
        exit 1
    fi
done

# Configurando permissões de armazenamento
echo "[*] Configurando permissões de armazenamento..."
termux-setup-storage

# Mudando espelho de repositório
echo "[*] Alterando espelho de repositórios..."
termux-change-mirror

# Instalando Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "[*] Instalando Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo "[*] Oh My Zsh já está instalado."
fi

# Instalando plugins do Oh My Zsh
echo "[*] Instalando plugins do Oh My Zsh..."
plugins=("zsh-autosuggestions" "zsh-syntax-highlighting" "zsh-completions")

for plugin in "${plugins[@]}"; do
    if [ ! -d "$ZSH/custom/plugins/$plugin" ]; then
        echo "[*] Instalando plugin: $plugin..."
        git clone "https://github.com/zsh-users/$plugin.git" "$ZSH/custom/plugins/$plugin"
    else
        echo "[*] Plugin $plugin já está instalado."
    fi
done

# Atualizando .zshrc para ativar plugins
echo "[*] Configurando .zshrc..."
if ! grep -q "plugins=(" "$HOME/.zshrc"; then
    echo "plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-completions)" >> "$HOME/.zshrc"
else
    sed -i 's/plugins=(/plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-completions /' "$HOME/.zshrc"
fi

# Aplicando mudanças no Zsh
echo "[*] Aplicando mudanças no Zsh..."
source "$HOME/.zshrc"

echo "[*] Configuração concluída!"
