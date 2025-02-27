#!/data/data/com.termux/files/usr/bin/bash

# Função para exibir o banner colorido
display_banner() {
    clear
    echo -e "\033[1;36m"  # Ciano brilhante
    cat << 'EOF'
██████╗     ███████╗    ███╗   ███╗     ██████╗     ████████╗    ███████╗       ██████╗     ██╗     ██████╗    ███████╗
██╔══██╗    ██╔════╝    ████╗ ████║    ██╔═══██╗    ╚══██╔══╝    ██╔════╝       ██╔══██╗    ██║    ██╔════╝    ██╔════╝
██████╔╝    █████╗      ██╔████╔██║    ██║   ██║       ██║       █████╗         ██████╔╝    ██║    ██║         ███████╗
██╔══██╗    ██╔══╝      ██║╚██╔╝██║    ██║   ██║       ██║       ██╔══╝         ██╔═══╝     ██║    ██║         ╚════██║
██║  ██║    ███████╗    ██║ ╚═╝ ██║    ╚██████╔╝       ██║       ███████╗       ██║         ██║    ╚██████╗    ███████║
╚═╝  ╚═╝    ╚══════╝    ╚═╝     ╚═╝     ╚═════╝        ╚═╝       ╚══════╝       ╚═╝         ╚═╝     ╚═════╝    ╚══════╝
                                                                                                                       
EOF
    echo -e "\033[0m"  # Resetar cor
}

# Função para exibir a ajuda
usage() {
    echo "Usage: $0 [-d LOCAL_DIR] [-m MEGA_DIR] [-i INTERVAL] [-c] [-k] [-s TIME] [-e] [-p PASSWORD] [-D] [-C CAMERA] [-h]"
    echo "  -d LOCAL_DIR  Local directory to save photos (default: ~/storage/pictures/FotosMega)"
    echo "  -m MEGA_DIR   MEGA directory to upload photos (default: FotosMega)"
    echo "  -i INTERVAL   Interval between photos in seconds (default: 5)"
    echo "  -c            Clean local files after upload (default: false)"
    echo "  -k            Enable colored interface (default: true)"
    echo "  -s TIME       Schedule execution at a specific time (format: HH:MM, default: none)"
    echo "  -e            Encrypt files before uploading (default: false)"
    echo "  -p PASSWORD   Password for encryption (required if -e is used)"
    echo "  -D            Enable dependency checking (default: false)"
    echo "  -C CAMERA     Select camera (0 for back, 1 for front, default: 0)"
    echo "  -h            Display this help"
    exit 1
}

# Valores padrão
LOCAL_DIR="~/storage/pictures/FotosMega"
MEGA_DIR="FotosMega"
INTERVAL=5
CLEAN_FILES=false
COLORED_OUTPUT=true
SCHEDULE_TIME=""
ENCRYPT_FILES=false
CRYPT_PASSWORD=""
CHECK_DEPENDENCIES=false  # Verificação de dependências desativada por padrão
CAMERA=0  # 0 para câmera traseira, 1 para frontal

# Cores para interface colorida (se ativada)
GREEN="\033[32m"
RED="\033[31m"
YELLOW="\033[33m"
BLUE="\033[34m"
RESET="\033[0m"

# Parser de argumentos
while getopts "d:m:i:cks:e:p:DC:h" opt; do
    case $opt in
        d) LOCAL_DIR="$OPTARG" ;;
        m) MEGA_DIR="$OPTARG" ;;
        i) INTERVAL="$OPTARG" ;;
        c) CLEAN_FILES=true ;;
        k) COLORED_OUTPUT=true ;;
        s) SCHEDULE_TIME="$OPTARG" ;;
        e) ENCRYPT_FILES=true ;;
        p) CRYPT_PASSWORD="$OPTARG" ;;
        D) CHECK_DEPENDENCIES=true ;;  # -D ativa a verificação de dependências
        C) CAMERA="$OPTARG" ;;
        h) usage ;;
        *) echo "Invalid option: -$OPTARG" >&2; usage ;;
    esac
done

# Função para mensagens coloridas
message() {
    local color="$1"
    local msg="$2"
    if $COLORED_OUTPUT; then
        echo -e "${color}${msg}${RESET}"
    else
        echo "$msg"
    fi
}

# Função para instalar dependências
install_dependencies() {
    message "$GREEN" "Installing dependencies..."
    pkg update -y
    pkg install -y megatools termux-api gnupg
    if [ $? -eq 0 ]; then
        message "$GREEN" "Dependencies installed successfully!"
    else
        message "$RED" "Failed to install dependencies. Please check your internet connection and try again."
        exit 1
    fi
}

# Verificar se está logado no MEGA
check_mega_login() {
    if mega-whoami >/dev/null 2>&1; then
        message "$GREEN" "Logged into MEGA as: $(mega-whoami)"
    else
        message "$YELLOW" "You are not logged into MEGA."
        message "$BLUE" "Please log in to your MEGA account."
        read -p "Enter your MEGA email: " MEGA_EMAIL
        read -s -p "Enter your MEGA password: " MEGA_PASSWORD
        echo
        mega-login "$MEGA_EMAIL" "$MEGA_PASSWORD" >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            message "$GREEN" "Successfully logged into MEGA as: $(mega-whoami)"
        else
            message "$RED" "Failed to log in. Please check your credentials and try again."
            exit 1
        fi
    fi
}

# Verificar dependências
check_dependencies() {
    if $CHECK_DEPENDENCIES; then
        commands=("megacmd" "termux-api" "gpg")
        for cmd in "${commands[@]}"; do
            if ! command -v $cmd &> /dev/null; then
                message "$RED" "Error: $cmd is not installed. Installing now..."
                install_dependencies
                break
            fi
        done
    else
        message "$YELLOW" "Dependency checking is disabled."
    fi
}

# Criptografar arquivos
encrypt_file() {
    local file="$1"
    if $ENCRYPT_FILES; then
        if [ -z "$CRYPT_PASSWORD" ]; then
            message "$RED" "Error: Encryption password not provided. Use the -p flag."
            exit 1
        fi
        message "$BLUE" "Encrypting $file..."
        echo "$CRYPT_PASSWORD" | gpg --batch --passphrase-fd 0 -c "$file" && rm "$file"
        echo "$file.gpg"
    else
        echo "$file"
    fi
}

# Configurar ambiente
setup() {
    message "$GREEN" "Setting up environment..."
    mkdir -p "$LOCAL_DIR"
    mega-rm -rf "$MEGA_DIR"
    mega-mkdir "$MEGA_DIR"
}

# Capturar e enviar fotos
capture_and_upload() {
    while true; do
        # Gerar um timestamp no formato AAAAMMDD_HHMMSS
        TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

        # Nome da foto com o timestamp
        PHOTO="$LOCAL_DIR/$TIMESTAMP.jpg"

        # Capturar foto usando a câmera selecionada
        message "$GREEN" "Capturing photo: $PHOTO..."
        termux-camera-photo -c "$CAMERA" "$PHOTO"

        # Verificar se a foto foi capturada com sucesso
        if [ -f "$PHOTO" ]; then
            message "$GREEN" "Photo captured and saved to $PHOTO"

            # Criptografar o arquivo, se necessário
            FILE_TO_UPLOAD=$(encrypt_file "$PHOTO")

            # Enviar a foto para o MEGA
            message "$BLUE" "Uploading photo to MEGA..."
            if mega-put "$FILE_TO_UPLOAD" "$MEGA_DIR" >/dev/null 2>&1; then
                message "$GREEN" "Photo uploaded to MEGA successfully!"
                # Limpar arquivos locais, se necessário
                if $CLEAN_FILES; then
                    message "$YELLOW" "Removing local file: $FILE_TO_UPLOAD..."
                    rm "$FILE_TO_UPLOAD"
                fi
            else
                message "$RED" "Error uploading photo to MEGA!"
            fi

            # Aguardar o intervalo definido antes de capturar a próxima foto
            message "$BLUE" "Waiting $INTERVAL seconds for the next capture..."
            sleep "$INTERVAL"
        else
            message "$RED" "Error capturing photo!"
        fi
    done
}

# Agendar com cron em um horário específico
schedule_cron() {
    if [ -n "$SCHEDULE_TIME" ]; then
        # Validar formato do horário (HH:MM)
        if ! [[ "$SCHEDULE_TIME" =~ ^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$ ]]; then
            message "$RED" "Invalid time format. Use HH:MM."
            exit 1
        fi

        # Dividir o horário em horas e minutos
        IFS=":" read -r HOUR MINUTE <<< "$SCHEDULE_TIME"

        # Criar expressão cron
        CRON_EXPR="$MINUTE $HOUR * * *"

        message "$GREEN" "Scheduling execution at $SCHEDULE_TIME daily..."
        (crontab -l 2>/dev/null; echo "$CRON_EXPR $0 -d '$LOCAL_DIR' -m '$MEGA_DIR' -i $INTERVAL -c -k -e -p '$CRYPT_PASSWORD' -C $CAMERA") | crontab -
        message "$GREEN" "Scheduling completed!"
        exit 0
    fi
}

# Execução principal
main() {
    display_banner
    check_dependencies
    check_mega_login
    setup
    schedule_cron
    capture_and_upload
}

# Iniciar o script
main