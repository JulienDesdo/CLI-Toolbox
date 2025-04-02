import requests
from bs4 import BeautifulSoup
import random

# Obtenir tous les paquets
url = "https://pypi.org/simple/"
response = requests.get(url)
soup = BeautifulSoup(response.text, 'html.parser')
packages = [a.text for a in soup.find_all('a')]

# Choisir un paquet au hasard
random_package = random.choice(packages)

# Obtenir les infos du paquet via API
info_url = f"https://pypi.org/pypi/{random_package}/json"
info_response = requests.get(info_url)

if info_response.status_code == 200:
    data = info_response.json()
    summary = data['info'].get('summary', '(Pas de description dispo)')
else:
    summary = '(Aucune info disponible)'

print(f"🎲 Paquet aléatoire : {random_package}")
print(f"🔗 https://pypi.org/project/{random_package}/")
print(f"📖 Description : {summary}")


