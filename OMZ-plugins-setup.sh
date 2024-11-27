#!/bin/zsh
# Script para instalar plugins do Oh My Zsh
clear
echo "[*] Instalando plugins do Oh My Zsh..."

# Lista de plugins a serem instalados
plugins=("zsh-autosuggestions" "zsh-syntax-highlighting" "zsh-completions")

for plugin in "${plugins[@]}"; do
    # Verifica se o plugin já está instalado
    if [ ! -d "$ZSH/custom/plugins/$plugin" ]; then
        echo "[*] Instalando plugin: $plugin..."
        git clone "https://github.com/zsh-users/$plugin.git" "$ZSH/custom/plugins/$plugin"
    else
        echo "[*] Plugin $plugin já está instalado."
    fi
done

# Atualizando o arquivo .zshrc para ativar os plugins
echo "[*] Configurando .zshrc..."
if ! grep -q "plugins=(" "$HOME/.zshrc"; then
    echo "plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-completions)" >> "$HOME/.zshrc"
else
    sed -i 's/plugins=(/plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-completions /' "$HOME/.zshrc"
fi

# Recarregar a configuração do Zsh
echo "[*] Recarregando o Zsh..."
source "$HOME/.zshrc"

echo "[*] Plugins instalados e configurados com sucesso!"
