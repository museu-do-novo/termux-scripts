import requests
from bs4 import BeautifulSoup
from colorama import init, Fore, Style
import os
import sys
from datetime import datetime
import re
import sh

# Initialize colorama and clear screen
init(autoreset=True)
sh.clear()

# Custom message handler class
class MessageHandler:
    @staticmethod
    def message(text, level="info", custom_color=None):
        colors = {
            "error": Fore.RED,
            "success": Fore.GREEN,
            "info": Fore.CYAN,
            "debug": Fore.BLUE,
            "warning": Fore.YELLOW
        }
        
        color = colors.get(level, Fore.WHITE)
        if custom_color:
            color = getattr(Fore, custom_color.upper(), color)
        
        formatted_message = f"{color}{text}{Style.RESET_ALL}"
        print(formatted_message)

# Initialize message handler
sh = MessageHandler()

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
        self.log.flush()

# Redirect stdout to our logger
sys.stdout = Logger()

# Save lists to text files
def salvar_em_arquivo(nome_arquivo, lista):
    with open(nome_arquivo, 'w', encoding='utf-8') as f:
        for item in lista:
            f.write(item + '\n')
    sh.message(f"[✔] Lista salva: {nome_arquivo} ({len(lista)} itens)", level="success")

# Extract clean links from sitemap pages
def get_clean_links(sitemap_url):
    sh.message(f"[→] Requisitando sitemap: {sitemap_url}", level="info")
    res = requests.get(sitemap_url)
    
    if res.status_code != 200:
        sh.message(f"[✘] Erro: Status Code {res.status_code}", level="error")
        return []

    soup = BeautifulSoup(res.text, 'lxml-xml')
    clean_links = []

    sh.message(f"[→] Processando URLs do sitemap...", level="info")
    for loc in soup.find_all('loc'):
        link = loc.text.strip()
        parte_final = link.split('?')[0].split('#')[0].split('/')[-1]
        
        # Only consider actual pages (not files)
        if '.' not in parte_final or link.endswith('/'):
            clean_links.append(link)

    sh.message(f"[✔] {len(clean_links)} links limpos extraídos.", level="success")
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
        sh.message(f"[✘] Erro em {page_url}: {str(e)}", level="error")
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
        sh.message(f"[✘] Erro ao extrair magnet de {magnet_page_url}: {str(e)}", level="error")
        return None

# ======= MAIN EXECUTION =======

sh.message(f"\n[📅] Processo iniciado em: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}", level="info")

sitemap_url = "https://plugdosplugins.com/post-sitemap.xml"

# Step 1: Extract links from sitemap
clean_links = get_clean_links(sitemap_url)

sh.message(f"\n[🚀] Iniciando varredura de páginas para encontrar magnet links...\n", level="info")

all_magnet_pages = []
all_magnet_links = []
magnet_count = 0

# Step 2: For each clean link, search for /magnet/ pages
for i, page_url in enumerate(clean_links, 1):
    sh.message(f"[🔄] ({i}/{len(clean_links)}) Página: {page_url}", level="debug")
    magnet_pages = extract_magnet_pages(page_url)
    all_magnet_pages.extend(magnet_pages)

    # Step 3: For each /magnet/ page, extract the real magnet link
    for magnet_page in magnet_pages:
        magnet_link = extract_magnet_link(magnet_page)
        if magnet_link:
            magnet_count += 1
            sh.message(f"    [#{magnet_count:03}] {magnet_link}", custom_color="green")
            all_magnet_links.append(magnet_link)

# Step 4: Remove duplicates while preserving order
unique_magnet_pages = list(dict.fromkeys(all_magnet_pages))
unique_magnet_links = list(dict.fromkeys(all_magnet_links))

# Save files with results
salvar_em_arquivo("paginas_magnet.txt", unique_magnet_pages)
salvar_em_arquivo("magnet_links.txt", unique_magnet_links)

# Final summary
sh.message(f"\n[🏁] Varredura finalizada com sucesso.", level="info")
sh.message(f"[📄] Links do sitemap: {len(clean_links)}", level="info")
sh.message(f"[📄] Páginas /magnet/: {len(unique_magnet_pages)}", level="info")
sh.message(f"[📄] Magnet links únicos: {len(unique_magnet_links)}", level="info")

# Add final timestamp
sh.message(f"\n[📅] Processo concluído em: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}", level="info")

# Ensure all logs are written
sys.stdout.flush()
