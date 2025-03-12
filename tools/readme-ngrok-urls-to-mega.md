# Ngrok URL to MEGA

Este script automatiza a captura da URL do Ngrok, formata um comando SSH e envia o comando para o MEGA.

## Requisitos

- **Ngrok**: Para expor o SSH localmente.
- **MEGA-CMD**: Para enviar o arquivo com o comando SSH para o MEGA.
- **jq**: Para processar a saída JSON da API do Ngrok.

## Instalação

1. Instale o Ngrok:
   - Baixe e instale a partir do site oficial: [https://ngrok.com/download](https://ngrok.com/download).
   - Autentique sua conta:
     ```bash
     ngrok authtoken SEU_AUTH_TOKEN
     ```

2. Instale o MEGA-CMD:
   - Siga as instruções em: [https://github.com/meganz/MEGAcmd](https://github.com/meganz/MEGAcmd).
   - Configure suas credenciais:
     ```bash
     mega-login seu_email sua_senha
     ```

3. Instale o `jq`:
   - No Debian/Ubuntu:
     ```bash
     sudo apt-get install jq
     ```
   - No RedHat/CentOS:
     ```bash
     sudo yum install jq
     ```

## Como Usar

1. Clone o repositório ou copie o script para o seu sistema.

2. Torne o script executável:
   ```bash
   chmod +x ngrok-url-to-mega.sh
