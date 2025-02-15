#!/bin/bash

dl-video() {
    local link="${1:-$(termux-clipboard-get)}"
    local output_path="${2:-$HOME/storage/movies/%(title)s.%(ext)s}"

    yt-dlp --cookies ./yt.netscape -o "$output_path" --write-auto-sub --sub-lang en "$link" && \
    termux-toast "video baixado" || termux-toast "erro"
}

dl-video "$1" "$2"
