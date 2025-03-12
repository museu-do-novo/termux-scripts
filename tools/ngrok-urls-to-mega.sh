#!/bin/bash
## wget https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz; sudo tar -xvzf ~/Downloads/ngrok-v3-stable-linux-amd64.tgz -C /usr/local/bin; ngrok config add-authtoken 2uCQM6nOeevl755qLdoV10oFTlY_6bH6STVBVopi3LtouVwEH
## wget https://mega.nz/linux/repo/Debian_12/amd64/megacmd-Debian_12_amd64.deb && sudo apt install "$PWD/megacmd-Debian_12_amd64.deb"
## Este script automatiza a captura da URL do Ngrok, formata um comando SSH e envia o comando para o MEGA.
## Dependências: ngrok (instale a partir do site), mega-cmd (instale a partir do site), jq.
## no receptor pode usar esse comando para manter uma sessao ssh sempre ativa mesmo com os urls do ngrok mudando:
## while true; do $(mega-cat ssh_command.txt); done
## lembrando que a conta do mega deve estar logada nos dois dispositivos
# ============================================================================================================

# Configurações
COMMAND_OUTPUT="$TMPDIR/ngrok.log"
SSH_COMMAND_FILE="$TMPDIR/ssh_command.txt"
MEGA_UPLOAD_PATH="${MEGA_UPLOAD_PATH:-/}"    # Caminho no MEGA (pode ser sobrescrito por variável de ambiente)
SSH_USER="${SSH_USER:-u0_a544}"              # Usuário SSH (pode ser sobrescrito por variável de ambiente)
MY_PORT="${MY_PORT:-8022}"                   # Porta SSH local (pode ser sobrescrito por variável de ambiente)
LOOP_INTERVAL="${LOOP_INTERVAL:-1500}"       # Intervalo entre execuções do loop (em segundos)

# ============================================================================================================
# Função para iniciar o Ngrok
start_ngrok() {
    pkill ngrok
    echo "Iniciando Ngrok na porta $MY_PORT..."
    nohup ngrok tcp "$MY_PORT" > "$COMMAND_OUTPUT" 2>&1 &
    sleep 5  # Aguarda o Ngrok inicializar
}

# Função para capturar a URL do Ngrok
capture_ngrok_url() {
    echo "Capturando URL do Ngrok..."
    url=$(curl -s http://localhost:4040/api/tunnels | jq -r '.tunnels[0].public_url')
    if [ -z "$url" ]; then
        echo "Erro: Não foi possível capturar a URL do Ngrok."
        return 1
    fi
    echo "URL capturada: $url"
}

# Função para formatar o comando SSH
format_ssh_command() {
    echo "Formatando comando SSH..."
    host=$(echo "$url" | awk -F'://' '{print $2}' | awk -F':' '{print $1}')
    port=$(echo "$url" | awk -F':' '{print $NF}')
    ssh_command="ssh $SSH_USER@$host -p $port"
    echo "$ssh_command" > "$SSH_COMMAND_FILE"
    echo "Comando SSH formatado: $ssh_command"
}

# Função para enviar o arquivo para o MEGA
upload_to_mega() {
    echo "Enviando arquivo para o MEGA...";
    mega-put "$SSH_COMMAND_FILE" "$MEGA_UPLOAD_PATH" &&
    echo "Arquivo enviado para o MEGA: $SSH_COMMAND_FILE" ||
    echo "Erro: Falha ao enviar arquivo para o MEGA.";
    return 1;
}

# ============================================================================================================

# Função principal
main() {
    clear;
    start_ngrok &&
    capture_ngrok_url &&
    format_ssh_command &&
    upload_to_mega;
}

# Executa a função principal em loop
while true; do
    main
    sleep "$LOOP_INTERVAL"
done
