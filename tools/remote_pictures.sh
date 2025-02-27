#!/data/data/com.termux/files/usr/bin/bash

# Função para exibir a ajuda
usage() {
    echo "Uso: $0 [-d DIR_LOCAL] [-m DIR_MEGA] [-i INTERVAL] [-c] [-q] [-k] [-s] [-e] [-h]"
    echo "  -d DIR_LOCAL  Diretório local para salvar as fotos (padrão: ~/storage/pictures/FotosMega)"
    echo "  -m DIR_MEGA   Diretório no MEGA para enviar as fotos (padrão: FotosMega)"
    echo "  -i INTERVAL   Intervalo entre as fotos em segundos (padrão: 5)"
    echo "  -c            Limpar arquivos locais após envio"
    echo "  -q            Verificar espaço no MEGA e parar se estiver quase cheio"
    echo "  -k            Ativar interface colorida"
    echo "  -s            Agendar execução com cron (uma vez por hora)"
    echo "  -e            Criptografar arquivos antes de enviar"
    echo "  -h            Exibir esta ajuda"
    exit 1
}

# Valores padrão
DIR_LOCAL="~/storage/pictures/FotosMega"
DIR_MEGA="FotosMega"
INTERVAL=5
CLEAN_FILES=0
CHECK_QUOTA=0
COLORED_OUTPUT=0
SCHEDULE_CRON=0
ENCRYPT_FILES=0

# Cores para interface colorida (se ativada)
GREEN="\033[32m"
RED="\033[31m"
YELLOW="\033[33m"
BLUE="\033[34m"
RESET="\033[0m"

# Parser de argumentos
while getopts "d:m:i:cqkseh" opt; do
    case $opt in
        d) DIR_LOCAL="$OPTARG" ;;
        m) DIR_MEGA="$OPTARG" ;;
        i) INTERVAL="$OPTARG" ;;
        c) CLEAN_FILES=1 ;;
        q) CHECK_QUOTA=1 ;;
        k) COLORED_OUTPUT=1 ;;
        s) SCHEDULE_CRON=1 ;;
        e) ENCRYPT_FILES=1 ;;
        h) usage ;;
        *) echo "Opção inválida: -$OPTARG" >&2; usage ;;
    esac
done

# Função para mensagens coloridas
message() {
    local color="$1"
    local msg="$2"
    if [ "$COLORED_OUTPUT" -eq 1 ]; then
        echo -e "${color}${msg}${RESET}"
    else
        echo "$msg"
    fi
}

# Verifica dependências
check_dependencies() {
    commands=("mega-put" "termux-camera-photo" "mega-login" "mega-rm" "mega-mkdir")
    for cmd in "${commands[@]}"; do
        if ! command -v $cmd &> /dev/null; then
            message "$RED" "Erro: $cmd não está instalado. Instale antes de continuar."
            exit 1
        fi
    done
    if [ "$ENCRYPT_FILES" -eq 1 ] && ! command -v gpg &> /dev/null; then
        message "$RED" "Erro: gpg não está instalado. Instale para usar criptografia."
        exit 1
    fi
}

# Verifica o espaço no MEGA
check_mega_quota() {
    if [ "$CHECK_QUOTA" -eq 1 ]; then
        QUOTA=$(mega-quota | grep "Used" | awk '{print $2}')
        if [ "$QUOTA" -gt 90 ]; then
            message "$RED" "Espaço no MEGA quase cheio (90% usado). Encerrando..."
            exit 1
        fi
    fi
}

# Criptografa arquivos
encrypt_file() {
    local file="$1"
    if [ "$ENCRYPT_FILES" -eq 1 ]; then
        message "$BLUE" "Criptografando $file..."
        gpg -c "$file" && rm "$file"
        echo "$file.gpg"
    else
        echo "$file"
    fi
}

# Configura o ambiente
setup() {
    message "$GREEN" "Configurando ambiente..."
    mkdir -p "$DIR_LOCAL"
    mega-rm -rf "$DIR_MEGA"
    mega-mkdir "$DIR_MEGA"
}

# Captura e envia fotos
capture_and_upload() {
    while true; do
        # Gera um timestamp no formato AAAAMMDD_HHMMSS
        TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

        # Nome da foto com o timestamp
        FOTO="$DIR_LOCAL/$TIMESTAMP.jpg"

        # Captura a foto usando a câmera do Termux
        message "$GREEN" "Capturando foto: $FOTO..."
        termux-camera-photo -c 0 "$FOTO"

        # Verifica se a foto foi capturada com sucesso
        if [ -f "$FOTO" ]; then
            message "$GREEN" "Foto capturada e salva em $FOTO"

            # Criptografa o arquivo, se necessário
            FILE_TO_UPLOAD=$(encrypt_file "$FOTO")

            # Envia a foto para a conta MEGA em segundo plano
            message "$BLUE" "Enviando foto para o MEGA..."
            nohup mega-put "$FILE_TO_UPLOAD" "$DIR_MEGA" >/dev/null 2>&1 &
            message "$GREEN" "Foto enviada para o MEGA em segundo plano!"

            # Limpa arquivos locais, se necessário
            if [ "$CLEAN_FILES" -eq 1 ]; then
                message "$YELLOW" "Removendo arquivo local: $FILE_TO_UPLOAD..."
                rm "$FILE_TO_UPLOAD"
            fi

            # Verifica o espaço no MEGA, se necessário
            check_mega_quota

            # Espera o intervalo definido antes de tirar outra foto
            message "$BLUE" "Aguardando $INTERVAL segundos para a próxima captura..."
            sleep "$INTERVAL"
        else
            message "$RED" "Erro ao capturar a foto!"
        fi
    done
}

# Agendamento com cron
schedule_cron() {
    if [ "$SCHEDULE_CRON" -eq 1 ]; then
        message "$GREEN" "Agendando execução com cron (uma vez por hora)..."
        (crontab -l 2>/dev/null; echo "0 * * * * $0 -d '$DIR_LOCAL' -m '$DIR_MEGA' -i $INTERVAL -c -q -k -e") | crontab -
        message "$GREEN" "Agendamento concluído!"
        exit 0
    fi
}

# Execução principal
main() {
    check_dependencies
    setup
    schedule_cron
    capture_and_upload
}

# Inicia o script
main