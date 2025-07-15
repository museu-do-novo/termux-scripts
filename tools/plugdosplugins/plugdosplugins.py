import requests
from bs4 import BeautifulSoup
from colorama import init, Fore, Style
import os

# Inicializa o colorama (necessário no Windows)
init(autoreset=True)

# Salva listas em arquivos de texto
def salvar_em_arquivo(nome_arquivo, lista):
    with open(nome_arquivo, 'w', encoding='utf-8') as f:
        for item in lista:
            f.write(item + '\n')
    print(f"{Fore.GREEN}[✔] Lista salva: {nome_arquivo} ({len(lista)} itens){Style.RESET_ALL}")

# Extrai links válidos de páginas do sitemap
def get_clean_links(sitemap_url):
    print(f"{Fore.CYAN}[→] Requisitando sitemap: {sitemap_url}{Style.RESET_ALL}")
    res = requests.get(sitemap_url)
    
    if res.status_code != 200:
        print(f"{Fore.RED}[✘] Erro: Status Code {res.status_code}{Style.RESET_ALL}")
        return []

    soup = BeautifulSoup(res.text, 'lxml-xml')
    clean_links = []

    print(f"{Fore.CYAN}[→] Processando URLs do sitemap...{Style.RESET_ALL}")
    for loc in soup.find_all('loc'):
        link = loc.text.strip()
        parte_final = link.split('?')[0].split('#')[0].split('/')[-1]
        
        # Considera apenas páginas reais (não arquivos)
        if '.' not in parte_final or link.endswith('/'):
            clean_links.append(link)

    print(f"{Fore.GREEN}[✔] {len(clean_links)} links limpos extraídos.{Style.RESET_ALL}")
    salvar_em_arquivo("links_limpos.txt", clean_links)
    return clean_links

# Busca por páginas com "/magnet/" em um post
def extract_magnet_pages(page_url):
    try:
        res = requests.get(page_url)
        res.raise_for_status()
        soup = BeautifulSoup(res.text, 'html.parser')
        magnet_pages = []

        for a in soup.find_all('a', href=True):
            href = a['href']
            if '/magnet/' in href:
                if href.startswith("http"):
                    magnet_pages.append(href)
                else:
                    base = page_url.rstrip('/')
                    magnet_pages.append(base + '/' + href.lstrip('/'))

        return magnet_pages
    except Exception as e:
        print(f"{Fore.RED}[✘] Erro em {page_url}: {str(e)}{Style.RESET_ALL}")
        return []

# Extração do magnet link real de uma página /magnet/
def extract_magnet_link(magnet_page_url):
    try:
        res = requests.get(magnet_page_url)
        res.raise_for_status()
        soup = BeautifulSoup(res.text, 'html.parser')

        for a in soup.find_all('a', href=True):
            href = a['href']
            if href.startswith('magnet:?'):
                return href

        return None
    except Exception as e:
        print(f"{Fore.RED}[✘] Erro ao extrair magnet de {magnet_page_url}: {str(e)}{Style.RESET_ALL}")
        return None

# ======= EXECUÇÃO PRINCIPAL =======

sitemap_url = "https://plugdosplugins.com/post-sitemap.xml"

# Etapa 1: Extração de links do sitemap
clean_links = get_clean_links(sitemap_url)

print(f"\n{Fore.YELLOW}[🚀] Iniciando varredura de páginas para encontrar magnet links...\n{Style.RESET_ALL}")

all_magnet_pages = []
all_magnet_links = []
magnet_count = 0

# Etapa 2: Para cada link limpo, buscar páginas /magnet/
for i, page_url in enumerate(clean_links, 1):
    print(f"{Fore.BLUE}[🔄] ({i}/{len(clean_links)}) Página: {page_url}{Style.RESET_ALL}")
    magnet_pages = extract_magnet_pages(page_url)
    all_magnet_pages.extend(magnet_pages)

    # Etapa 3: Para cada página /magnet/, buscar o link magnet real
    for magnet_page in magnet_pages:
        magnet_link = extract_magnet_link(magnet_page)
        if magnet_link:
            magnet_count += 1
            print(f"{Fore.GREEN}    [#{magnet_count:03}] {magnet_link}{Style.RESET_ALL}")
            all_magnet_links.append(magnet_link)

# Etapa 4: Remover duplicatas mantendo a ordem
unique_magnet_pages = list(dict.fromkeys(all_magnet_pages))
unique_magnet_links = list(dict.fromkeys(all_magnet_links))

# Salvar arquivos com os resultados
salvar_em_arquivo("paginas_magnet.txt", unique_magnet_pages)
salvar_em_arquivo("magnet_links.txt", unique_magnet_links)

# Resumo final
print(f"\n{Fore.MAGENTA}[🏁] Varredura finalizada com sucesso.{Style.RESET_ALL}")
print(f"{Fore.YELLOW}[📄] Links do sitemap: {len(clean_links)}")
print(f"[📄] Páginas /magnet/: {len(unique_magnet_pages)}")
print(f"[📄] Magnet links únicos: {len(unique_magnet_links)}{Style.RESET_ALL}")
