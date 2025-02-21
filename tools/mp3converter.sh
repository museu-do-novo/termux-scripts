#!/bin/bash

# Diretório onde estão os arquivos
DIR=~/storage/music/

# Encontrar todos os arquivos de áudio e converter para MP3
find "$DIR" -type f \( -iname "*.wav" -o -iname "*.flac" -o -iname "*.aac" -o -iname "*.ogg" -o -iname "*.m4a" \) -exec bash -c 'ffmpeg -i "$0" -q:a 2 "${0%.*}.mp3"' {} \;

echo "Conversão concluída!"
