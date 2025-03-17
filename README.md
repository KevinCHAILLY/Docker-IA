# Ollama avec Docker Compose

Ce dépôt contient la configuration nécessaire pour exécuter [Ollama](https://ollama.ai/) dans un conteneur Docker à l'aide de Docker Compose.

## Qu'est-ce qu'Ollama ?

Ollama est un outil qui permet de lancer des modèles de langage de grande taille (LLM) localement. Il prend en charge une variété de modèles comme Llama 2, Mistral, Vicuna et bien d'autres.

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

Pour la liste complète des variables d'environnement disponibles, consultez le fichier `.env.example`.

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

### Accéder à Ollama

Ollama est accessible à l'adresse `http://localhost:11434`. Vous pouvez interagir avec Ollama via son API.

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

- `ollama_data`: Stocke les modèles et les données d'Ollama.

## Ressources additionnelles

- [Site officiel d'Ollama](https://ollama.ai/)
- [Documentation d'Ollama](https://github.com/ollama/ollama/tree/main/docs)
- [Image Docker Ollama](https://hub.docker.com/r/ollama/ollama)

## Licence

Ce projet est distribué sous licence MIT. 