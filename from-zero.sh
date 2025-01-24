#! /bin/bash

pkg update; pkg upgrade -y; pkg install git; git clone https://github.com/museu-do-novo/termux-scripts.git; cd termux-scripts; chmod +x *.sh; bash my-termux-setup.sh