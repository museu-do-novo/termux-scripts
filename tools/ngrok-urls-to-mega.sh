#!/bin/bash
## Este script automatiza a captura da URL do Ngrok, formata um comando SSH ou VNC e envia o comando para o MEGA. (util para contas gratuitas do ngrok)

# ============================================================================================================

# SETUP:

#  comando para baixar e setar o ngrok:
## wget https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz; sudo tar -xvzf ~/Downloads/ngrok-v3-stable-linux-amd64.tgz -C /usr/local/bin; ngrok config add-authtoken 2uCQM6nOeevl755qLdoV10oFTlY_6bH6STVBVopi3LtouVwEH

# comando para baixar e setar o megacli (lembre de logar sua conta)
## wget https://mega.nz/linux/repo/Debian_12/amd64/megacmd-Debian_12_amd64.deb && sudo apt install "$PWD/megacmd-Debian_12_amd64.deb"

# ============================================================================================================

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
VERSION="1.1"
WHOIAM=$(whoami)                                                     # Usuário atual
TMPDIR=${TMPDIR:-/tmp}                                               # Diretório temporário
COMMAND_OUTPUT="$TMPDIR/ngrok.log"                                   # Arquivo de log do Ngrok
MEGA_UPLOAD_PATH="${MEGA_UPLOAD_PATH:-/}"                            # Caminho no MEGA
USER="$WHOIAM"                                                       # Usuário SSH
SSH_PORT=22
#SSH_PORT="${SSH_PORT:-8022}"                                         # Porta SSH local
VNC_PORT="${VNC_PORT:-5901}"                                         # Porta VNC local
LOOP_INTERVAL="${LOOP_INTERVAL:-30}"                                 # Intervalo entre verificações
CLEANING_UP=true                                                     # Controle de limpeza

# Arquivos temporários
SSH_COMMAND_FILE="$TMPDIR/ssh_command.txt"                           # Comando SSH
VNC_COMMAND_FILE="$TMPDIR/vnc_command.txt"                           # Comando VNC

# ============================================================================================================
# Funções

# Mostra ajuda
show_help() {
    echo "Uso: $0 [OPÇÃO]"
    echo "Opções:"
    echo "  --ssh     Configura túnel SSH (padrão)"
    echo "  --vnc     Configura túnel VNC"
    echo "  --version Mostra versão do script"
    echo "  --help    Mostra esta ajuda"
    exit 0
}

# Verifica dependências
check_dependencies() {
    local missing=()

    command -v ngrok >/dev/null 2>&1 || missing+=("ngrok")
    command -v mega-cmd >/dev/null 2>&1 || missing+=("mega-cmd")
    command -v jq >/dev/null 2>&1 || missing+=("jq")

    if [ ${#missing[@]} -gt 0 ]; then
        echo "Erro: Dependências ausentes: ${missing[*]}"
        echo "Instale com:"
        echo "  ngrok: wget https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz && sudo tar -xvzf ngrok-v3-stable-linux-amd64.tgz -C /usr/local/bin"
        echo "  mega-cmd: wget https://mega.nz/linux/repo/Debian_12/amd64/megacmd-Debian_12_amd64.deb && sudo apt install ./megacmd-Debian_12_amd64.deb"
        echo "  jq: sudo apt install jq"
        exit 1
    fi
}

# Limpeza ao encerrar
cleanup() {
    if [ "$CLEANING_UP" = true ]; then
        return
    fi

    echo -e "\n[$(date +'%T')] Encerrando script..."
    pkill -f "ngrok tcp" 2>/dev/null

    [ -f "$SSH_COMMAND_FILE" ] && rm -f "$SSH_COMMAND_FILE"
    [ -f "$VNC_COMMAND_FILE" ] && rm -f "$VNC_COMMAND_FILE"
    [ -f "$COMMAND_OUTPUT" ] && rm -f "$COMMAND_OUTPUT"

    echo "[$(date +'%T')] Recursos limpos."
    CLEANING_UP=false

    exit 0
}

# Inicia Ngrok
start_ngrok() {
    local port=$1
    echo "[$(date +'%T')] Iniciando Ngrok na porta $port..."

    pkill -f "ngrok tcp" 2>/dev/null
    nohup ngrok tcp "$port" > "$COMMAND_OUTPUT" 2>&1 &

    sleep 5
    if ! curl -s --retry 3 --retry-delay 1 --max-time 5 http://localhost:4040/api/tunnels >/dev/null; then
        echo "[$(date +'%T')] Erro: Ngrok não iniciou corretamente"
        return 1
    fi
    return 0
}

# Captura URL do Ngrok
capture_ngrok_url() {
    echo "[$(date +'%T')] Capturando URL do Ngrok..."
    url=$(curl -s --max-time 5 http://localhost:4040/api/tunnels | jq -r '.tunnels[0].public_url')

    if [ -z "$url" ] || [ "$url" == "null" ]; then
        echo "[$(date +'%T')] Erro: Não foi possível capturar a URL"
        return 1
    fi
    echo "[$(date +'%T')] URL capturada: $url"
    return 0
}

# Formata comando SSH
format_ssh_command() {
    echo "[$(date +'%T')] Formatando comando SSH..."
    host=$(echo "$url" | awk -F'://' '{print $2}' | awk -F':' '{print $1}')
    port=$(echo "$url" | awk -F':' '{print $NF}')

    SSH_COMMAND="ssh $USER@$host -p $port"
    echo "$SSH_COMMAND" > "$SSH_COMMAND_FILE"
    echo "[$(date +'%T')] Comando SSH: $SSH_COMMAND"
}

# Formata comando VNC
format_vnc_command() {
    echo "[$(date +'%T')] Formatando comando VNC..."
    host=$(echo "$url" | awk -F'://' '{print $2}' | awk -F':' '{print $1}')
    port=$(echo "$url" | awk -F':' '{print $NF}')

    VNC_COMMAND="vncviewer $host::$port"
    echo "$VNC_COMMAND" > "$VNC_COMMAND_FILE"
    echo "[$(date +'%T')] Comando VNC: $VNC_COMMAND"
}

# Envia para MEGA
upload_to_mega() {
    local file=$1
    echo "[$(date +'%T')] Enviando $file para MEGA..."

    if mega-put "$file" "$MEGA_UPLOAD_PATH" >/dev/null 2>&1; then
        echo "[$(date +'%T')] Sucesso: Arquivo enviado"
        return 0
    else
        echo "[$(date +'%T')] Erro: Falha no upload"
        return 1
    fi
}

# Verifica Ngrok
check_ngrok() {
    if curl -s --max-time 3 http://localhost:4040/api/tunnels >/dev/null; then
        return 0
    fi
    return 1
}

# Função principal
main() {
    clear

    local mode=$1
    local success=false

    case $mode in
        ssh)
            if start_ngrok "$SSH_PORT" && \
               capture_ngrok_url && \
               format_ssh_command && \
               upload_to_mega "$SSH_COMMAND_FILE"; then
                success=true
            fi
            ;;
        vnc)
            if start_ngrok "$VNC_PORT" && \
               capture_ngrok_url && \
               format_vnc_command && \
               upload_to_mega "$VNC_COMMAND_FILE"; then
                success=true
            fi
            ;;
    esac

    if [ "$success" = false ]; then
        cleanup
        echo "[$(date +'%T')] Falha na operação, tentando novamente em $LOOP_INTERVAL segundos"
    fi
}

# ============================================================================================================
# Execução

# Processa argumentos
case "$1" in
    --ssh) MODE="ssh" ;;
    --vnc) MODE="vnc" ;;
    --version) echo "Versão $VERSION"; exit 0 ;;
    --help) show_help ;;
    *) echo "Uso: $0 [--ssh | --vnc | --help]"; exit 1 ;;
esac

# Verifica dependências
check_dependencies
# Loop principal
echo "[$(date +'%T')] Iniciando script no modo $MODE..."
while true; do
    if ! check_ngrok; then
        main "$MODE"
    fi
    sleep "$LOOP_INTERVAL"
done

trap cleanup SIGINT SIGTERM EXIT
# heheheheh
