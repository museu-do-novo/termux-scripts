#!/bin/bash

## Este script automatiza o processo de baixar o comando SSH do MEGA e conectar ao servidor.

# Configurações
MEGA_FILE_PATH="/caminho/do/mega/ssh_command.txt"  # Caminho do arquivo no MEGA
LOCAL_FILE="/tmp/ssh_command.txt"                  # Arquivo local para salvar o comando SSH

# Função para baixar o arquivo do MEGA
download_from_mega() {
    echo "Baixando arquivo do MEGA..."
    if mega-get "$MEGA_FILE_PATH" "$LOCAL_FILE"; then
        echo "Arquivo baixado com sucesso: $LOCAL_FILE"
    else
        echo "Erro: Falha ao baixar o arquivo do MEGA."
        exit 1
    fi
}

# Função para extrair e executar o comando SSH
execute_ssh_command() {
    echo "Extraindo comando SSH..."
    if [ -f "$LOCAL_FILE" ]; then
        ssh_command=$(cat "$LOCAL_FILE")
        echo "Comando SSH encontrado: $ssh_command"
        echo "Conectando ao servidor..."
        eval "$ssh_command"
    else
        echo "Erro: Arquivo $LOCAL_FILE não encontrado."
        exit 1
    fi
}

# Função principal
main() {
    download_from_mega
    execute_ssh_command
}

# Executa a função principal
main
