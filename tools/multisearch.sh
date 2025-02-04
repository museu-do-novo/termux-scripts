#!/data/data/com.termux/files/usr/bin/bash

# Configurações globais
VERSION="3.1"
CONFIG_FILE="$HOME/.config/searchhelper.conf"
DEFAULT_ENGINE="google"

declare -A SEARCH_ENGINES=(
    ["google"]="https://www.google.com/search?q={query}"
    ["ddg"]="https://duckduckgo.com/?q={query}"
    ["bing"]="https://www.bing.com/search?q={query}"
    ["github"]="https://github.com/search?q={query}"
    ["youtube"]="https://www.youtube.com/results?search_query={query}"
    ["arxiv"]="https://arxiv.org/search/?query={query}"
    ["stackoverflow"]="https://stackoverflow.com/search?q={query}"
    ["wikipedia"]="https://en.wikipedia.org/w/index.php?search={query}"
)

show_help() {
    echo "
📘 Search Helper v$VERSION - Manual Completo

🌈 USO BÁSICO:
  $0 [OPÇÕES] \"TERMOS DE PESQUISA\"

🔧 OPÇÕES PRINCIPAIS:
  -e, --engine <nome>    Seleciona mecanismo de pesquisa
  -m, --multi <e1,e2>    Pesquisa em múltiplos mecanismos
  -l, --list             Lista mecanismos disponíveis
  -h, --help             Mostra este manual completo
  -V, --version          Mostra a versão

🔍 MECANISMOS SUPORTADOS:"
    for engine in "${!SEARCH_ENGINES[@]}"; do
        echo "  - $engine"
    done

    echo "
🎯 OPERADORES AVANÇADOS:
  → Operadores Básicos:
    \"frase exata\"      Pesquisa exata
    -palavra           Exclui termo
    OR                 Alternância lógica
    (parenteses)       Agrupamento lógico

  → Filtros Específicos:
    site:dominio       Limita a um site
    intitle:termo      Termo no título
    inurl:termo        Termo na URL
    intext:termo       Termo no conteúdo
    filetype:ext       Tipo de arquivo

  → Filtros Temporais:
    after:YYYY-MM-DD   Resultados após data
    before:YYYY-MM-DD  Resultados antes data

  → Filtros Especiais:
    related:url        Sites relacionados
    cache:url          Versão em cache
    define:termo       Definições
    map:local          Mapas

💡 EXEMPLOS PRÁTICOS:
  1. Pesquisa técnica:
     $0 -e google \"intitle:'index of' site:github.com filetype:pdf\"

  2. Pesquisa múltipla:
     $0 -m ddg,bing \"error 404 -wordpress filetype:log\"

  3. Pesquisa temporal:
     $0 -e google \"python vulnerability after:2023-01-01\"

  4. Pesquisa avançada:
     $0 -e youtube \"how to install AND (kali linux OR parrot os)\"

📌 DICAS:
  - Use aspas para frases exatas
  - Combine operadores para melhor precisão
  - Verifique a sintaxe específica de cada mecanismo
"
    exit 0
}

load_config() {
    [ -f "$CONFIG_FILE" ] && source "$CONFIG_FILE"
}

list_engines() {
    echo "🔧 Mecanismos disponíveis:"
    for engine in "${!SEARCH_ENGINES[@]}"; do
        echo "  - $engine"
    done
    exit 0
}

urlencode() {
    local LC_ALL=C
    local string="$*"
    local length="${#string}"
    local char

    for (( i = 0; i < length; i++ )); do
        char="${string:i:1}"
        case "$char" in
            [a-zA-Z0-9.:~_\(\)'-']) printf '%s' "$char" ;;
            ' ') printf '+' ;;
            *) printf '%%%02X' "'$char" ;;
        esac
    done
}

validate_engine() {
    local engine="$1"
    if [ -z "${SEARCH_ENGINES[$engine]}" ]; then
        echo "❌ Erro: Mecanismo '$engine' inválido!"
        list_engines
        exit 1
    fi
}

parse_arguments() {
    local engines=()
    local query=()

    load_config

    while [ $# -gt 0 ]; do
        case "$1" in
            -e|--engine)
                [ -z "$2" ] && { echo "❌ Faltando nome do mecanismo"; exit 1; }
                engines+=("$2")
                shift 2
                ;;
            -m|--multi)
                [ -z "$2" ] && { echo "❌ Faltando lista de mecanismos"; exit 1; }
                IFS=',' read -ra multi_engines <<< "$2"
                engines+=("${multi_engines[@]}")
                shift 2
                ;;
            -l|--list)
                list_engines
                ;;
            -h|--help)
                show_help
                ;;
            -V|--version)
                echo "🔄 Versão: $VERSION"
                exit 0
                ;;
            -*)
                echo "❌ Opção inválida: $1"
                show_help
                exit 1
                ;;
            *)
                query+=("$1")
                shift
                ;;
        esac
    done

    [ ${#engines[@]} -eq 0 ] && engines=("$DEFAULT_ENGINE")
    [ ${#query[@]} -eq 0 ] && { echo "❌ Nenhum termo de pesquisa!"; show_help; exit 1; }

    for engine in "${engines[@]}"; do
        validate_engine "$engine"
    done

    process_search "${engines[@]}" "${query[*]}"
}

process_search() {
    local engines=("${@:1:$#-1}")
    local query="${*: -1}"
    local encoded_query=$(urlencode "$query")

    for engine in "${engines[@]}"; do
        local url="${SEARCH_ENGINES[$engine]//\{query\}/$encoded_query}"
        echo "🔍 Pesquisando no $engine: $query"
        am start -a android.intent.action.VIEW -d "$url" > /dev/null 2>&1
        
        [ $? -ne 0 ] && echo "❌ Falha ao abrir: $url"
    done
}

parse_arguments "$@"
