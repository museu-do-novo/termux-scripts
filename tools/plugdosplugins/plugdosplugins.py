import requests
from bs4 import BeautifulSoup
from colorama import init, Fore, Style
import os
import sys
from datetime import datetime
import re

# Initialize colorama (required on Windows)
init(autoreset=True)

# Logger class to mirror console output to a file
class Logger(object):
    def __init__(self):
        self.terminal = sys.stdout
        self.log = open("console_output.log", "w", encoding='utf-8')
        
    def write(self, message):
        self.terminal.write(message)
        # Remove color codes for the log file
        clean_message = re.sub(r'\x1b\[[0-9;]*[mK]', '', message)
        self.log.write(clean_message)
        
    def flush(self):
        pass

# Redirect stdout to our logger
sys.stdout = Logger()

# Save lists to text files
def salvar_em_arquivo(nome_arquivo, lista):
    with open(nome_arquivo, 'w', encoding='utf-8') as f:
        for item in lista:
            f.write(item + '\n')
    print(f"{Fore.GREEN}[✔] Lista salva: {nome_arquivo} ({len(lista)} itens){Style.RESET_ALL}")

# Extract clean links from sitemap pages
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
        
        # Only consider actual pages (not files)
        if '.' not in parte_final or link.endswith('/'):
            clean_links.append(link)

    print(f"{Fore.GREEN}[✔] {len(clean_links)} links limpos extraídos.{Style.RESET_ALL}")
    salvar_em_arquivo("links_limpos.txt", clean_links)
    return clean_links

# Search for pages with "/magnet/" in a post
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

# Extract real magnet link from a /magnet/ page
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

# ======= MAIN EXECUTION =======

print(f"\n{Fore.YELLOW}[📅] Processo iniciado em: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}{Style.RESET_ALL}")

sitemap_url = "https://plugdosplugins.com/post-sitemap.xml"

# Step 1: Extract links from sitemap
clean_links = get_clean_links(sitemap_url)

print(f"\n{Fore.YELLOW}[🚀] Iniciando varredura de páginas para encontrar magnet links...\n{Style.RESET_ALL}")

all_magnet_pages = []
all_magnet_links = []
magnet_count = 0

# Step 2: For each clean link, search for /magnet/ pages
for i, page_url in enumerate(clean_links, 1):
    print(f"{Fore.BLUE}[🔄] ({i}/{len(clean_links)}) Página: {page_url}{Style.RESET_ALL}")
    magnet_pages = extract_magnet_pages(page_url)
    all_magnet_pages.extend(magnet_pages)

    # Step 3: For each /magnet/ page, extract the real magnet link
    for magnet_page in magnet_pages:
        magnet_link = extract_magnet_link(magnet_page)
        if magnet_link:
            magnet_count += 1
            print(f"{Fore.GREEN}    [#{magnet_count:03}] {magnet_link}{Style.RESET_ALL}")
            all_magnet_links.append(magnet_link)

# Step 4: Remove duplicates while preserving order
unique_magnet_pages = list(dict.fromkeys(all_magnet_pages))
unique_magnet_links = list(dict.fromkeys(all_magnet_links))

# Save files with results
salvar_em_arquivo("paginas_magnet.txt", unique_magnet_pages)
salvar_em_arquivo("magnet_links.txt", unique_magnet_links)

# Final summary
print(f"\n{Fore.MAGENTA}[🏁] Varredura finalizada com sucesso.{Style.RESET_ALL}")
print(f"{Fore.YELLOW}[📄] Links do sitemap: {len(clean_links)}")
print(f"[📄] Páginas /magnet/: {len(unique_magnet_pages)}")
print(f"[📄] Magnet links únicos: {len(unique_magnet_links)}{Style.RESET_ALL}")

# Add final timestamp
print(f"\n{Fore.YELLOW}[📅] Processo concluído em: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}{Style.RESET_ALL}")
