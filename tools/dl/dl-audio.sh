#!/bin/bash

dl-audio() {
    local link="${1:-$(termux-clipboard-get)}"
    local output_path="${2:-$HOME/storage/music/%(title)s.%(ext)s}"

    yt-dlp --cookies ./yt.netscape -o "$output_path" -x --audio-format mp3 "$link" && \
    termux-toast "audio baixado" || termux-toast "erro"
}

dl-audio "$1" "$2"
