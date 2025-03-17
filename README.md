# Ollama avec Docker Compose

Ce dépôt contient la configuration nécessaire pour exécuter [Ollama](https://ollama.ai/) dans un conteneur Docker à l'aide de Docker Compose, avec une interface utilisateur [Open WebUI](https://github.com/open-webui/open-webui).

## Qu'est-ce qu'Ollama ?

Ollama est un outil qui permet de lancer des modèles de langage de grande taille (LLM) localement. Il prend en charge une variété de modèles comme Llama 2, Mistral, Vicuna et bien d'autres.

## Qu'est-ce qu'Open WebUI ?

Open WebUI est une interface utilisateur web moderne et conviviale pour Ollama. Elle offre de nombreuses fonctionnalités avancées :
- Interface de chat similaire à ChatGPT
- Gestion des modèles
- Historique des conversations
- Partage de conversations
- Personnalisation des prompts
- Et bien plus encore...

## Prérequis

- Docker
- Docker Compose

## Installation

1. Clonez ce dépôt :
```bash
git clone <votre-repo>
cd <votre-repo>
```

2. Copiez le fichier d'exemple des variables d'environnement :
```bash
cp .env.example .env
```

3. Modifiez le fichier `.env` selon vos besoins.

## Configuration

Toutes les variables d'environnement sont stockées dans le fichier `.env`. Un fichier `.env.example` est fourni comme modèle avec les valeurs par défaut et des commentaires explicatifs.

### Variables d'environnement principales

| Variable | Description | Valeur par défaut |
|----------|-------------|-------------------|
| `OLLAMA_HOST` | Adresse d'écoute du serveur Ollama | `0.0.0.0:11434` |
| `OLLAMA_MODELS` | Répertoire des modèles | `/root/.ollama/models` |
| `OLLAMA_KEEP_ALIVE` | Durée pendant laquelle les modèles restent chargés | `5m` |
| `OLLAMA_NUM_PARALLEL` | Nombre maximum de requêtes parallèles | `0` (illimité) |
| `OLLAMA_MAX_QUEUE` | Nombre maximum de requêtes en file d'attente | `512` |

### Variables d'environnement Open WebUI

| Variable | Description | Valeur par défaut |
|----------|-------------|-------------------|
| `WEBUI_AUTH` | Activer l'authentification | `true` |
| `WEBUI_NAME` | Nom de l'interface Web | `Ollama WebUI` |
| `WEBUI_URL` | URL de l'interface Web | `http://localhost:3000` |
| `WEBUI_SECRET_KEY` | Clé secrète pour l'authentification | `changeme` |

Pour la liste complète des variables d'environnement disponibles, consultez le fichier `.env.example`.

## Architecture réseau

La configuration utilise deux réseaux Docker distincts pour une sécurité renforcée :

1. **Réseau interne (`ollama_internal`)** :
   - Réseau isolé sans accès à l'extérieur
   - Contient le service Ollama
   - Accessible uniquement par les conteneurs connectés à ce réseau

2. **Réseau externe (`webui_external`)** :
   - Réseau exposé à l'hôte
   - Permet l'accès à l'interface Open WebUI depuis l'extérieur

Le service Open WebUI est connecté aux deux réseaux, agissant comme un pont sécurisé entre l'utilisateur et le service Ollama. Cette architecture garantit que l'API Ollama n'est jamais directement exposée à l'extérieur.

## Utilisation

### Script d'installation rapide

Un script shell `setup.sh` est fourni pour faciliter l'installation et l'utilisation :

```bash
# Rendre le script exécutable
chmod +x setup.sh

# Lancer l'installation et démarrer Ollama
./setup.sh start

# Arrêter Ollama
./setup.sh stop

# Redémarrer Ollama
./setup.sh restart

# Télécharger le modèle Mistral
./setup.sh pull mistral

# Exécuter une commande avec Mistral
./setup.sh run mistral
```

### Commandes manuelles

Si vous préférez utiliser les commandes Docker Compose directement :

### Démarrer les services

```bash
docker compose up -d
```

### Vérifier l'état des services

```bash
docker compose ps
```

### Arrêter les services

```bash
docker compose down
```

### Accéder à Ollama et Open WebUI

- **API Ollama** : accessible uniquement à l'intérieur du réseau Docker interne
- **Interface Open WebUI** : accessible à l'adresse `http://localhost:3000`

Lors de votre première connexion à Open WebUI, vous devrez créer un compte utilisateur.

### Sécurité

Pour des raisons de sécurité, l'API Ollama est isolée dans un réseau Docker interne sans accès direct depuis l'extérieur. Toutes les interactions avec Ollama doivent passer par l'interface Open WebUI ou par les commandes Docker.

Cette architecture à deux réseaux offre une couche de sécurité supplémentaire en empêchant tout accès non autorisé à l'API Ollama.

### Exécuter une commande dans le conteneur

```bash
docker compose exec ollama ollama run mistral
```

### Télécharger un modèle

```bash
docker compose exec ollama ollama pull mistral
```

## Structure des fichiers

```
.
├── docker-compose.yml    # Configuration Docker Compose
├── .env                 # Variables d'environnement (à créer à partir de .env.example)
├── .env.example        # Exemple de configuration des variables d'environnement
├── .gitignore         # Liste des fichiers ignorés par Git
├── README.md         # Documentation du projet
└── setup.sh         # Script d'installation et d'utilisation
```

## Volumes

- `ollama_data`: Stocke les modèles et les données d'Ollama
- `open-webui_data`: Stocke les données de l'interface Open WebUI (utilisateurs, conversations, etc.)

## Ressources additionnelles

- [Site officiel d'Ollama](https://ollama.ai/)
- [Documentation d'Ollama](https://github.com/ollama/ollama/tree/main/docs)
- [Image Docker Ollama](https://hub.docker.com/r/ollama/ollama)
- [GitHub Open WebUI](https://github.com/open-webui/open-webui)

## Licence

Ce projet est distribué sous licence MIT. 