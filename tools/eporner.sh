#!/bin/bash

clear
output_file="videos.txt"
> "$output_file"
baseurl="https://www.eporner.com/"
search="search/curvy-latina-natalia/"
page=""

curl -s "${baseurl}${search}" | \
grep -oP 'href="/video-[^"]+"' | \
sed "s|href=\"\(/video-[^\"]*\)\"|${baseurl}\1|" >> "$output_file"


# Remover linhas vazias e duplicados (opcional)
sed -i '/^$/d' "$output_file"
sort -u "$output_file" -o "$output_file"

echo -e "\nFinished. Results saved in: $output_file"
echo "Total videos found: $(wc -l < "$output_file")"
