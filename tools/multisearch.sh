#!/data/data/com.termux/files/usr/bin/bash

display_banner() {
    clear
    message "cyan" ""
    cat << 'EOF'

███╗   ███╗    ██╗   ██╗    ██╗         ████████╗    ██╗       ███████╗    ███████╗     █████╗     ██████╗      ██████╗    ██╗  ██╗
████╗ ████║    ██║   ██║    ██║         ╚══██╔══╝    ██║       ██╔════╝    ██╔════╝    ██╔══██╗    ██╔══██╗    ██╔════╝    ██║  ██║
██╔████╔██║    ██║   ██║    ██║            ██║       ██║       ███████╗    █████╗      ███████║    ██████╔╝    ██║         ███████║
██║╚██╔╝██║    ██║   ██║    ██║            ██║       ██║       ╚════██║    ██╔══╝      ██╔══██║    ██╔══██╗    ██║         ██╔══██║
██║ ╚═╝ ██║    ╚██████╔╝    ███████╗       ██║       ██║       ███████║    ███████╗    ██║  ██║    ██║  ██║    ╚██████╗    ██║  ██║
╚═╝     ╚═╝     ╚═════╝     ╚══════╝       ╚═╝       ╚═╝       ╚══════╝    ╚══════╝    ╚═╝  ╚═╝    ╚═╝  ╚═╝     ╚═════╝    ╚═╝  ╚═╝

Made by: museu_do_novo                                                                                                                               
V1.0
EOF

}

# Function to display colored messages
message() {
    local color=$1
    local text=$2
    case $color in
        red)    echo -e "\033[1;31m${text}\033[0m" ;;
        green)  echo -e "\033[1;32m${text}\033[0m" ;;
        yellow) echo -e "\033[1;33m${text}\033[0m" ;;
        blue)   echo -e "\033[1;34m${text}\033[0m" ;;
        purple) echo -e "\033[1;35m${text}\033[0m" ;;
        cyan)   echo -e "\033[1;36m${text}\033[0m" ;;
        *)      echo -e "${text}" ;;
    esac
}


# Global settings
VERSION="1.0"
CONFIG_FILE="$HOME/.config/multisearch.conf"
DEFAULT_ENGINE="google"

declare -A SEARCH_ENGINES=(
    # General Searches
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
    
    # Academic
    ["arxiv"]="https://arxiv.org/search/?query={query}"
    ["scholar"]="https://scholar.google.com/scholar?q={query}"
    ["pubmed"]="https://pubmed.ncbi.nlm.nih.gov/?term={query}"
    ["springer"]="https://link.springer.com/search?query={query}"
    ["ieee"]="https://ieeexplore.ieee.org/search/searchresult.jsp?newsearch=true&queryText={query}"
    ["scihub"]="https://sci-hub.se/{query}"
    
    # Media
    ["youtube"]="https://www.youtube.com/results?search_query={query}"
    ["odysee"]="https://odysee.com/$/search?q={query}"
    ["spotify"]="https://open.spotify.com/search/{query}"
    
    # Shopping
    ["amazon"]="https://www.amazon.com/s?k={query}"
    ["ebay"]="https://www.ebay.com/sch/i.html?_nkw={query}"
    
    # Specialized
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
    
    # Wikipedia
    ["wikipedia"]="https://en.wikipedia.org/w/index.php?search={query}"
    ["wikipt"]="https://pt.wikipedia.org/w/index.php?search={query}"
    ["wikies"]="https://es.wikipedia.org/w/index.php?search={query}"
    ["wikifr"]="https://fr.wikipedia.org/w/index.php?search={query}"
    ["wikide"]="https://de.wikipedia.org/w/index.php?search={query}"
)

show_help() {
    message "cyan" "📘 Search Helper v$VERSION - Complete Manual

🌈 BASIC USAGE:
  $0 [OPTIONS] \"SEARCH TERMS\"

🔧 MAIN OPTIONS:
  -e, --engine <name>  Select search engine
  -m, --multi <e1,e2>  Search across multiple engines
  -f, --file <file>    Load searches from a text file
  -l, --list           List available search engines
  -h, --help           Show this manual
  -V, --version        Show version

📁 CONFIGURATION FILE (~/.config/searchhelper.conf):
  → Default path: $CONFIG_FILE
  → Syntax:
     • DEFAULT_ENGINE=\"engine_name\"  # Change default engine
     • SEARCH_ENGINES[\"new\"]=\"url\"  # Add new engine
     • SEARCH_ENGINES[\"existing\"]=\"new_url\"  # Overwrite existing
  
  💡 Example content:
     # Set default engine
     DEFAULT_ENGINE=\"startpage\"
     
     # Add custom engine
     SEARCH_ENGINES[\"myrepo\"]=\"https://repo.example.com/search?q={query}\"
     
     # Modify existing engine
     SEARCH_ENGINES[\"github\"]=\"https://github.com/search?q={query}&type=code\"

🔍 MAIN CATEGORIES:
  → General: google, ddg, brave, startpage
  → Tech: github, pypi, npm, dockerhub, aur
  → Academic: scholar, arxiv, ieee
  → Packages: brew, cargo, nuget, maven
  → Media: youtube, spotify, odysee
  → Documentation: godoc, readthedocs

💡 EXAMPLES:
  1. Simple search: $0 -e pypi \"async web framework\"
  2. Multi-engine search: $0 -m github,gitlab \"linux kernel driver\"
  3. Batch search: $0 -f queries.txt
  4. Custom engine: $0 -e myrepo \"API v2\"
  5. Custom config: $0 \"default search\"

📌 Tip: The configuration file is automatically loaded if it exists!"
    exit 0
}

load_config() {
    [ -f "$CONFIG_FILE" ] && source "$CONFIG_FILE"
}

list_engines() {
    message "yellow" "🔧 Available search engines:"
    for engine in "${!SEARCH_ENGINES[@]}"; do
        message "cyan" " - $engine"
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
        message "red" "❌ Error: Invalid engine '$engine'!"
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
                [ -z "$2" ] && { message "red" "❌ Missing engine name"; exit 1; }
                engines+=("$2")
                shift 2
                ;;
            -m|--multi)
                [ -z "$2" ] && { message "red" "❌ Missing engine list"; exit 1; }
                IFS=',' read -ra multi_engines <<< "$2"
                engines+=("${multi_engines[@]}")
                shift 2
                ;;
            -f|--file)
                [ -z "$2" ] && { message "red" "❌ Missing file name"; exit 1; }
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
                message "green" "🔄 Version: $VERSION"
                exit 0
                ;;
            -*)
                message "red" "❌ Invalid option: $1"
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
        [ ! -r "$input_file" ] && { message "red" "❌ File not found or no permission: $input_file"; exit 1; }
        message "blue" "📁 Processing file: $input_file"
        while IFS= read -r line || [ -n "$line" ]; do
            line=$(echo "$line" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
            [ -z "$line" ] && continue
            message "cyan" "🔎 Searching: '$line'"
            process_search "${engines[@]}" "$line"
        done < "$input_file"
    else
        [ ${#query[@]} -eq 0 ] && { message "red" "❌ No search terms provided!"; show_help; exit 1; }
        process_search "${engines[@]}" "${query[*]}"
    fi
}

process_search() {
    local engines=("${@:1:$#-1}")
    local query="${*: -1}"
    local encoded_query=$(urlencode "$query")

    for engine in "${engines[@]}"; do
        local url="${SEARCH_ENGINES[$engine]//\{query\}/$encoded_query}"
        message "green" "🌐 Opening ($engine): $query"
        am start -a android.intent.action.VIEW -d "$url" > /dev/null 2>&1
        [ $? -ne 0 ] && message "red" "❌ Failed to open: $url"
    done
}

parse_arguments "$@"