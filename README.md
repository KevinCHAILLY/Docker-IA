# Ollama avec Docker Compose

Ce dépôt contient la configuration nécessaire pour exécuter [Ollama](https://ollama.ai/) dans un conteneur Docker à l'aide de Docker Compose, avec une interface utilisateur [Open WebUI](https://github.com/open-webui/open-webui) et un reverse proxy [Traefik](https://traefik.io/).

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

## Qu'est-ce que Traefik ?

Traefik est un reverse proxy et un équilibreur de charge moderne conçu pour le déploiement de microservices. Dans cette configuration, Traefik est utilisé pour :
- Rediriger le trafic HTTP vers les services appropriés
- Fournir un accès à Open WebUI via un nom d'hôte convivial (`open-webui.docker.localhost`)
- Sécuriser l'accès aux services en exposant uniquement les points d'entrée nécessaires

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
| `WEBUI_URL` | URL de l'interface Web | `http://open-webui.docker.localhost` |
| `WEBUI_SECRET_KEY` | Clé secrète pour l'authentification | `changeme` |

Pour la liste complète des variables d'environnement disponibles, consultez le fichier `.env.example`.

## Architecture réseau

La configuration utilise trois réseaux Docker distincts pour une sécurité renforcée et un reverse proxy Traefik :

1. **Réseau interne (`ollama_internal`)** :
   - Réseau isolé pour la communication entre Ollama et Open WebUI
   - Accessible uniquement par les conteneurs connectés à ce réseau
   - Empêche l'accès direct à l'API Ollama depuis l'extérieur

2. **Réseau externe pour Ollama (`ollama_external`)** :
   - Permet à Ollama d'accéder à Internet pour télécharger et mettre à jour les modèles
   - N'expose pas l'API Ollama à l'extérieur

3. **Réseau externe pour l'interface (`webui_external`)** :
   - Réseau exposé à l'hôte
   - Contient le service Traefik et permet l'accès à l'interface Open WebUI depuis l'extérieur
   - Configuré comme réseau principal pour Traefik afin d'assurer une découverte correcte des services

4. **Configuration Traefik** :
   - Agit comme point d'entrée unique pour tous les services exposés
   - Gère le routage basé sur les noms d'hôtes
   - Expose le tableau de bord d'administration sur le port 8080
   - Utilise spécifiquement le réseau `webui_external` pour découvrir et communiquer avec les services
   - Configuration spéciale pour garantir l'utilisation de la bonne adresse IP du container Open WebUI

Cette architecture à trois réseaux offre un équilibre optimal entre sécurité et fonctionnalité :
- L'API Ollama reste isolée et inaccessible depuis l'extérieur
- Ollama peut accéder à Internet pour télécharger et mettre à jour les modèles
- Open WebUI est accessible via Traefik avec un nom d'hôte convivial
- La configuration réseau garantit que Traefik utilise toujours la bonne adresse IP pour communiquer avec Open WebUI

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
- **Interface Open WebUI** : accessible à l'adresse `http://open-webui.docker.localhost`
- **Tableau de bord Traefik** : accessible à l'adresse `http://localhost:8080`

Lors de votre première connexion à Open WebUI, vous devrez créer un compte utilisateur.

### Sécurité

Pour des raisons de sécurité, l'API Ollama est isolée dans un réseau Docker interne sans accès direct depuis l'extérieur. Toutes les interactions avec Ollama doivent passer par l'interface Open WebUI ou par les commandes Docker.

Cette architecture à trois réseaux avec Traefik comme point d'entrée unique offre plusieurs couches de sécurité :
- Isolation de l'API Ollama (non exposée à l'extérieur)
- Accès contrôlé via des règles de routage Traefik
- Exposition minimale des ports sur l'hôte (uniquement les ports 80 et 8080)
- Accès Internet limité au service Ollama pour les mises à jour de modèles

### Exécuter une commande dans le conteneur

```bash
docker compose exec ollama ollama run mistral
```

### Télécharger un modèle

```bash
docker compose exec ollama ollama pull mistral
```

## Résolution des problèmes courants

### Problèmes de réseau avec Traefik

Si vous rencontrez des problèmes de connexion à Open WebUI via Traefik, vérifiez les points suivants :

1. **Vérifiez que le nom d'hôte est correctement configuré** :
   - Assurez-vous que `open-webui.docker.localhost` est correctement résolu sur votre machine
   - Sur certains systèmes, vous devrez peut-être ajouter une entrée dans votre fichier `/etc/hosts`

2. **Vérifiez les logs de Traefik** :
   ```bash
   docker compose logs traefik
   ```

3. **Vérifiez la configuration réseau** :
   - La configuration actuelle utilise `traefik.docker.network=webui_external` pour s'assurer que Traefik utilise la bonne interface réseau pour communiquer avec Open WebUI
   - Vous pouvez vérifier les réseaux Docker avec la commande :
   ```bash
   docker network ls
   docker network inspect webui_external
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
- [Documentation Traefik](https://doc.traefik.io/traefik/)

## Licence

Ce projet est distribué sous licence MIT. 