import requests
from bs4 import BeautifulSoup
import re

def get_clean_links(sitemap_url):
    """Obtém links de páginas (não arquivos) do sitemap"""
    res = requests.get(sitemap_url)
    if res.status_code != 200:
        print(f"Erro na requisição: Status Code {res.status_code}")
        return []

    soup = BeautifulSoup(res.text, 'lxml-xml')
    clean_links = []
    
    for loc in soup.find_all('loc'):
        link = loc.text.strip()
        parte_final = link.split('?')[0].split('#')[0].split('/')[-1]
        if '.' not in parte_final or link.endswith('/'):
            clean_links.append(link)
    
    return clean_links

def extract_magnet_pages(page_url):
    """Extrai links /magnet/ de uma página específica"""
    try:
        res = requests.get(page_url)
        res.raise_for_status()
        soup = BeautifulSoup(res.text, 'html.parser')
        magnet_pages = []
        
        for a in soup.find_all('a', href=True):
            href = a['href']
            if '/magnet/' in href:
                magnet_pages.append(href)
        
        return magnet_pages
    except Exception as e:
        print(f"Erro ao processar {page_url}: {str(e)}")
        return []

def extract_magnet_link(magnet_page_url):
    """Extrai o magnet link real de uma página /magnet/"""
    try:
        res = requests.get(magnet_page_url)
        res.raise_for_status()
        soup = BeautifulSoup(res.text, 'html.parser')
        
        # Procura por links magnet (começando com magnet:?)
        magnet_link = None
        for a in soup.find_all('a', href=True):
            href = a['href']
            if href.startswith('magnet:?'):
                magnet_link = href
                break
        
        return magnet_link
    except Exception as e:
        print(f"Erro ao extrair magnet de {magnet_page_url}: {str(e)}")
        return None

# Execução principal
sitemap_url = "https://plugdosplugins.com/post-sitemap.xml"
clean_links = get_clean_links(sitemap_url)

print(f"Encontradas {len(clean_links)} páginas no sitemap")

all_magnet_links = []
for page_url in clean_links:
    magnet_pages = extract_magnet_pages(page_url)
    for magnet_page in magnet_pages:
        magnet_link = extract_magnet_link(magnet_page)
        if magnet_link:
            all_magnet_links.append(magnet_link)

# Remove duplicados mantendo a ordem
unique_magnet_links = list(dict.fromkeys(all_magnet_links))

print("\nMagnet links encontrados:")
for magnet in unique_magnet_links:
    print(magnet)

print(f"\nTotal de magnet links únicos encontrados: {len(unique_magnet_links)}")
