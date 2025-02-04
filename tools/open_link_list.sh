#!/bin/bash

# Caminho para o arquivo com os links
ARQUIVO_LINKS=$1

# Verifica se o arquivo existe
if [ ! -f "$ARQUIVO_LINKS" ]; then
  echo "Arquivo $ARQUIVO_LINKS não encontrado!"
  exit 1
fi

# Lê cada linha do arquivo e abre no Firefox
while IFS= read -r link; do
  echo "Abrindo: $link"
  am start -a android.intent.action.VIEW -d "$link" org.mozilla.firefox
  # sleep 2 # Espera 2 segundos entre os links (opcional, desativado)
done < "$ARQUIVO_LINKS"
