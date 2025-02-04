#!/data/data/com.termux/files/usr/bin/bash

# Configurações globais
VERSION="4.1"
CONFIG_FILE="$HOME/.config/searchhelper.conf"
DEFAULT_ENGINE="google"

declare -A SEARCH_ENGINES=(
    # Buscas Gerais
    ["google"]="https://www.google.com/search?q={query}"
    ["ddg"]="https://duckduckgo.com/?q={query}"
    ["brave"]="https://search.brave.com/search?q={query}"
    ["startpage"]="https://www.startpage.com/search?q={query}"
    ["yandex"]="https://yandex.com/search/?text={query}"
    ["baidu"]="https://www.baidu.com/s?wd={query}"
    ["ecosia"]="https://www.ecosia.org/search?q={query}"
    ["searx"]="https://searx.be/search?q={query}"
    
    # Tech/Code
    ["github"]="https://github.com/search?q={query}"
    ["gitlab"]="https://gitlab.com/search?search={query}"
    ["bitbucket"]="https://bitbucket.org/repo/all?name={query}"
    ["stackoverflow"]="https://stackoverflow.com/search?q={query}"
    ["npm"]="https://www.npmjs.com/search?q={query}"
    ["dockerhub"]="https://hub.docker.com/search?q={query}"
    ["pypi"]="https://pypi.org/search/?q={query}"
    ["rubygems"]="https://rubygems.org/search?query={query}"
    ["packagist"]="https://packagist.org/search/?q={query}"
    ["cargo"]="https://crates.io/search?q={query}"
    ["nuget"]="https://www.nuget.org/packages?q={query}"
    ["maven"]="https://search.maven.org/search?q={query}"
    ["pubdev"]="https://pub.dev/packages?q={query}"
    ["brew"]="https://formulae.brew.sh/search/?q={query}"
    ["aur"]="https://aur.archlinux.org/packages/?K={query}"
    ["debian"]="https://packages.debian.org/search?keywords={query}"
    ["ubuntu"]="https://packages.ubuntu.com/search?keywords={query}"
    ["ctan"]="https://ctan.org/search?phrase={query}"
    ["grepapp"]="https://grep.app/search?q={query}"
    ["sourcegraph"]="https://sourcegraph.com/search?q={query}"
    ["codeberg"]="https://codeberg.org/explore/repos?q={query}"
    ["readthedocs"]="https://readthedocs.org/search/?q={query}"
    ["godoc"]="https://pkg.go.dev/search?q={query}"
    
    # Acadêmico
    ["arxiv"]="https://arxiv.org/search/?query={query}"
    ["scholar"]="https://scholar.google.com/scholar?q={query}"
    ["pubmed"]="https://pubmed.ncbi.nlm.nih.gov/?term={query}"
    ["springer"]="https://link.springer.com/search?query={query}"
    ["ieee"]="https://ieeexplore.ieee.org/search/searchresult.jsp?newsearch=true&queryText={query}"
    ["scihub"]="https://sci-hub.se/{query}"
    
    # Mídia
    ["youtube"]="https://www.youtube.com/results?search_query={query}"
    ["odysee"]="https://odysee.com/$/search?q={query}"
    ["spotify"]="https://open.spotify.com/search/{query}"
    
    # Compras
    ["amazon"]="https://www.amazon.com/s?k={query}"
    ["ebay"]="https://www.ebay.com/sch/i.html?_nkw={query}"
    
    # Especializados
    ["wolfram"]="https://www.wolframalpha.com/input/?i={query}"
    ["imdb"]="https://www.imdb.com/find?q={query}"
    ["ted"]="https://www.ted.com/search?q={query}"
    ["linguee"]="https://www.linguee.com.br/search?source=auto&query={query}"
    ["deepl"]="https://www.deepl.com/translator#auto/auto/{query}"
    ["openlibrary"]="https://openlibrary.org/search?q={query}"
    ["archive"]="https://archive.org/search.php?query={query}"
    
    # AI
    ["openai"]="https://openai.com/research/#{query}"
    ["huggingface"]="https://huggingface.co/models?search={query}"
    
    # Social Media
    ["medium"]="https://medium.com/search?q={query}"
    ["reddit"]="https://www.reddit.com/search/?q={query}"
    ["twitter"]="https://twitter.com/search?q={query}"
    ["linkedin"]="https://www.linkedin.com/search/results/all/?keywords={query}"
    ["quora"]="https://www.quora.com/search?q={query}"
    ["patreon"]="https://www.patreon.com/search?q={query}"
    
    # Wikipédia
    ["wikipedia"]="https://en.wikipedia.org/w/index.php?search={query}"
    ["wikipt"]="https://pt.wikipedia.org/w/index.php?search={query}"
    ["wikies"]="https://es.wikipedia.org/w/index.php?search={query}"
    ["wikifr"]="https://fr.wikipedia.org/w/index.php?search={query}"
    ["wikide"]="https://de.wikipedia.org/w/index.php?search={query}"
)

show_help() {
    echo "📘 Search Helper v$VERSION - Manual Completo

🌈 USO BÁSICO:
  $0 [OPÇÕES] \"TERMOS DE PESQUISA\"

🔧 OPÇÕES PRINCIPAIS:
  -e, --engine <nome>  Seleciona mecanismo de pesquisa
  -m, --multi <e1,e2>  Pesquisa em múltiplos mecanismos
  -f, --file <arquivo> Carrega pesquisas de um arquivo de texto
  -l, --list           Lista mecanismos disponíveis
  -h, --help           Mostra este manual
  -V, --version        Mostra a versão

📁 ARQUIVO DE CONFIGURAÇÃO (~/.config/searchhelper.conf):
  → Caminho padrão: $CONFIG_FILE
  → Sintaxe:
     • DEFAULT_ENGINE=\"nome_engine\"  # Altera o mecanismo padrão
     • SEARCH_ENGINES[\"novo\"]=\"url\"  # Adiciona novo mecanismo
     • SEARCH_ENGINES[\"existente\"]=\"nova_url\"  # Sobrescreve existente
  
  💡 Exemplo de conteúdo:
     # Define mecanismo padrão
     DEFAULT_ENGINE=\"startpage\"
     
     # Adiciona mecanismo personalizado
     SEARCH_ENGINES[\"meurepo\"]=\"https://repo.example.com/search?q={query}\"
     
     # Modifica mecanismo existente
     SEARCH_ENGINES[\"github\"]=\"https://github.com/search?q={query}&type=code\"

🔍 CATEGORIAS PRINCIPAIS:
  → Gerais: google, ddg, brave, startpage
  → Tech: github, pypi, npm, dockerhub, aur
  → Acadêmico: scholar, arxiv, ieee
  → Pacotes: brew, cargo, nuget, maven
  → Mídia: youtube, spotify, odysee
  → Documentação: godoc, readthedocs

💡 EXEMPLOS:
  1. Busca simples: $0 -e pypi \"async web framework\"
  2. Multiplataforma: $0 -m github,gitlab \"linux kernel driver\"
  3. Arquivo em lote: $0 -f queries.txt
  4. Mecanismo customizado: $0 -e meurepo \"API v2\"
  5. Config personalizada: $0 \"pesquisa padrão\"

📌 Dica: O arquivo de configuração é carregado automaticamente se existir!"
    exit 0
}

load_config() {
    [ -f "$CONFIG_FILE" ] && source "$CONFIG_FILE"
}

list_engines() {
    echo "🔧 Mecanismos disponíveis:"
    for engine in "${!SEARCH_ENGINES[@]}"; do
        echo " - $engine"
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
    local input_file=""
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
            -f|--file)
                [ -z "$2" ] && { echo "❌ Faltando nome do arquivo"; exit 1; }
                input_file="$2"
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
    
    for engine in "${engines[@]}"; do
        validate_engine "$engine"
    done

    if [ -n "$input_file" ]; then
        [ ! -r "$input_file" ] && { echo "❌ Arquivo não encontrado ou sem permissão: $input_file"; exit 1; }
        echo "📁 Processando arquivo: $input_file"
        while IFS= read -r line || [ -n "$line" ]; do
            line=$(echo "$line" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
            [ -z "$line" ] && continue
            echo "🔎 Pesquisando: '$line'"
            process_search "${engines[@]}" "$line"
        done < "$input_file"
    else
        [ ${#query[@]} -eq 0 ] && { echo "❌ Nenhum termo de pesquisa!"; show_help; exit 1; }
        process_search "${engines[@]}" "${query[*]}"
    fi
}

process_search() {
    local engines=("${@:1:$#-1}")
    local query="${*: -1}"
    local encoded_query=$(urlencode "$query")

    for engine in "${engines[@]}"; do
        local url="${SEARCH_ENGINES[$engine]//\{query\}/$encoded_query}"
        echo "🌐 Abrindo ($engine): $query"
        am start -a android.intent.action.VIEW -d "$url" > /dev/null 2>&1
        [ $? -ne 0 ] && echo "❌ Falha ao abrir: $url"
    done
}

parse_arguments "$@"
