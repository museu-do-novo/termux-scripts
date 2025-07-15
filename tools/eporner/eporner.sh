#!/bin/bash

clear
output_file="videos.txt"
> "$output_file"
baseurl="https://www.eporner.com/"
search="search/curvy-latina-natalia/"
downloadpath="/sdcard/Movies/eporner/"
maxpage=5

# Verifica se o diretório existe, senão cria
if [ ! -d "$downloadpath" ]; then
    mkdir -p "$downloadpath"
fi

# Busca vídeos e extrai os links
for page in $(seq 1 $maxpage); do
    echo "🔍 Página: $page"
    curl -s "${baseurl}${search}${page}/" | \
    grep -oP 'href="/video-[^"]+"' | \
    sed "s|href=\"\([^\"]*\)\"|${baseurl}\1|" | \
    sed 's|//video-|/video-|g' >> "$output_file"
done

# Remove linhas vazias e duplicadas
# sed -i '/^$/d' "$output_file"
# sort -u "$output_file" -o "$output_file"

echo -e "\n✅ Finalizado. Resultados salvos em: $output_file"
echo "📼 Total de vídeos encontrados: $(wc -l < "$output_file")"
sleep 3

# Função para baixar vídeos
dl_video() {
    while read -r link; do
        yt-dlp "$link" \
        --referer "https://www.eporner.com/" \
        --user-agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" \
        -o "${downloadpath}%(title)s.%(ext)s" && \
        termux-toast "✅ Vídeo baixado!" || termux-toast "❌ Erro no download!"
    done < "$output_file"
}

# Chamada da função
dl_video
