#!/bin/bash
## Este script automatiza a captura da URL do Ngrok, formata um comando SSH ou VNC e envia o comando para o MEGA.
## wget https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz; sudo tar -xvzf ~/Downloads/ngrok-v3-stable-linux-amd64.tgz -C /usr/local/bin; ngrok config add-authtoken 2uCQM6nOeevl755qLdoV10oFTlY_6bH6STVBVopi3LtouVwEH
## wget https://mega.nz/linux/repo/Debian_12/amd64/megacmd-Debian_12_amd64.deb && sudo apt install "$PWD/megacmd-Debian_12_amd64.deb"
## Este script automatiza a captura da URL do Ngrok, formata um comando SSH e envia o comando para o MEGA.
## Dependências: ngrok (instale a partir do site), mega-cmd (instale a partir do site), jq.
## no receptor pode usar esse comando para manter uma sessao ssh sempre ativa mesmo com os urls do ngrok mudando:
## lembrando que a conta do mega deve estar logada nos dois dispositivos
## Uso: ./script.sh [--ssh | --vnc]
## Exemplo: ./script.sh --ssh
## No receptor, use: while true; do $(mega-cat ssh_command.txt); done
## ou: while true; do $(mega-cat vnc_command.txt); done
# ============================================================================================================

# Configurações
WHOIAM=$(whoami)                             # Usuário atual
TMPDIR=${TMPDIR:-/tmp}                       # Diretório temporário
COMMAND_OUTPUT="$TMPDIR/ngrok.log"           # Arquivo de log do Ngrok
MEGA_UPLOAD_PATH="${MEGA_UPLOAD_PATH:-/}"    # Caminho no MEGA (pode ser sobrescrito por variável de ambiente)
USER="$WHOIAM"                               # Usuário SSH (pode ser sobrescrito por variável de ambiente)
SSH_PORT="${SSH_PORT:-8022}"                   # Porta SSH local (pode ser sobrescrito por variável de ambiente)
LOOP_INTERVAL="${LOOP_INTERVAL:-69}"         # Intervalo entre execuções do loop (em segundos)
VNC_PORT="${VNC_PORT:-5901}"                 # Porta VNC local (pode ser sobrescrito por variável de ambiente)

# VARIAVES DE CONTROLE:
MODE="ssh"                                   # Modo padrão (ssh ou vnc)
SSH_COMMAND_FILE="$TMPDIR/ssh_command.txt"   # Arquivo para o comando SSH
VNC_COMMAND_FILE="$TMPDIR/vnc_command.txt"   # Arquivo para o comando VNC

# ============================================================================================================

# Função para iniciar o Ngrok
start_ngrok() {
    pkill ngrok
    echo "Iniciando Ngrok na porta $1..."
    nohup ngrok tcp "$1" > "$COMMAND_OUTPUT" 2>&1 &
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
    ssh_command="ssh $USER@$host -p $port"
    echo "$ssh_command" > "$SSH_COMMAND_FILE"
    echo "Comando SSH formatado: $ssh_command"
}

# Função para formatar o comando VNC
format_vnc_command() {
    echo "Formatando comando VNC..."
    host=$(echo "$url" | awk -F'://' '{print $2}' | awk -F':' '{print $1}')
    port=$(echo "$url" | awk -F':' '{print $NF}')
    vnc_command="vncviewer $host:$port"
    echo "$vnc_command" > "$VNC_COMMAND_FILE"
    echo "Comando VNC formatado: $vnc_command"
}

# Função para enviar o arquivo para o MEGA
upload_to_mega() {
    local file_to_upload="$1"
    echo "Enviando arquivo para o MEGA..."
    mega-put "$file_to_upload" "$MEGA_UPLOAD_PATH" &&
    echo "Arquivo enviado para o MEGA: $file_to_upload" ||
    echo "Erro: Falha ao enviar arquivo para o MEGA."
}

# Função principal
main() {
    clear
    if [ "$MODE" == "ssh" ]; then
        start_ngrok "$SSH_PORT" &&
        capture_ngrok_url &&
        format_ssh_command &&
        upload_to_mega "$SSH_COMMAND_FILE"
    elif [ "$MODE" == "vnc" ]; then
        start_ngrok "$VNC_PORT" &&
        capture_ngrok_url &&
        format_vnc_command &&
        upload_to_mega "$VNC_COMMAND_FILE"
    else
        echo "Modo inválido. Use --ssh ou --vnc."
        return 1
    fi
}

# ============================================================================================================

# Processamento de argumentos
if [ "$1" == "--ssh" ]; then
    MODE="ssh"
elif [ "$1" == "--vnc" ]; then
    MODE="vnc"
else
    echo "Uso: $0 [--ssh | --vnc]"
    exit 1
fi

# Executa a função principal em loop
while true; do
    main
    sleep "$LOOP_INTERVAL"
done
