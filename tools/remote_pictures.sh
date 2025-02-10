#!/data/data/com.termux/files/usr/bin/bash

clear

# Diretório local onde as fotos serão salvas
DIR_LOCAL="~/storage/pictures/FotosMega"

# Diretório no MEGA onde as fotos serão enviadas
DIR_MEGA="FotosMega"

# Certifica-se de que o diretório local existe
mkdir -p $DIR_LOCAL

# Remove o diretório no MEGA (se existir) e cria um novo
mega-rm -rf $DIR_MEGA
mega-mkdir $DIR_MEGA

# Faz login no MEGA
# mega-login seu_email@exemplo.com sua_senha

# Contador de fotos
COUNT=1

# Loop infinito para capturar fotos
while true; do
    # Nome da foto com numeração
    FOTO="$DIR_LOCAL/foto_$COUNT.jpg"

    # Captura a foto usando a câmera do Termux
    termux-camera-photo -c 0 $FOTO

    # Verifica se a foto foi tirada
    if [ -f "$FOTO" ]; then
        echo "Foto $COUNT capturada e salva em $FOTO"

        # Envia a foto para a conta MEGA em segundo plano
        nohup mega-put $FOTO $DIR_MEGA >/dev/null 2>&1 &
        echo "Foto $COUNT sendo enviada para o MEGA em segundo plano!"

        # Incrementa o contador
        COUNT=$((COUNT+1))

        # Espera 5 segundos antes de tirar outra foto (ajuste conforme necessário)
        sleep 5
    else
        echo "Erro ao capturar a foto!"
    fi
done
