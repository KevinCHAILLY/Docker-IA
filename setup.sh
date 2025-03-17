#!/bin/bash

# Couleurs pour les messages
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Fonction pour afficher un message d'aide
show_help() {
    echo -e "${YELLOW}Usage:${NC} $0 [command]"
    echo ""
    echo "Commands:"
    echo "  start       - Démarre les services Ollama et Open WebUI"
    echo "  stop        - Arrête les services"
    echo "  restart     - Redémarre les services"
    echo "  pull MODEL  - Télécharge un modèle (ex: mistral, llama2)"
    echo "  run MODEL   - Exécute une commande avec un modèle"
    echo "  help        - Affiche ce message d'aide"
    echo ""
}

# Vérifier si Docker est installé
check_docker() {
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}Docker n'est pas installé. Veuillez l'installer avant de continuer.${NC}"
        exit 1
    fi
}

# Vérifier si Docker Compose est installé
check_docker_compose() {
    if ! docker compose version &> /dev/null; then
        echo -e "${RED}Docker Compose n'est pas installé ou n'est pas dans le PATH.${NC}"
        exit 1
    fi
}

# Créer le fichier .env s'il n'existe pas
create_env_file() {
    if [ ! -f .env ]; then
        if [ -f .env.example ]; then
            cp .env.example .env
            echo -e "${GREEN}Fichier .env créé à partir de .env.example${NC}"
        else
            echo -e "${RED}Fichier .env.example introuvable. Impossible de créer le fichier .env.${NC}"
            exit 1
        fi
    fi
}

# Démarrer les services
start_services() {
    echo -e "${YELLOW}Démarrage des services Ollama et Open WebUI...${NC}"
    docker compose up -d
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Services démarrés avec succès!${NC}"
        echo -e "${GREEN}Interface Open WebUI accessible à l'adresse: http://open-webui.docker.localhost${NC}"
        echo -e "${GREEN}Tableau de bord Traefik accessible à l'adresse: http://localhost:8080${NC}"
        echo -e "${GREEN}API Ollama accessible uniquement à l'intérieur du réseau Docker${NC}"
        echo -e "${GREEN}Ollama peut accéder à Internet pour télécharger et mettre à jour les modèles${NC}"
    else
        echo -e "${RED}Erreur lors du démarrage des services.${NC}"
        exit 1
    fi
}

# Arrêter les services
stop_services() {
    echo -e "${YELLOW}Arrêt des services...${NC}"
    docker compose down
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Services arrêtés avec succès.${NC}"
    else
        echo -e "${RED}Erreur lors de l'arrêt des services.${NC}"
        exit 1
    fi
}

# Télécharger un modèle
pull_model() {
    if [ -z "$1" ]; then
        echo -e "${RED}Veuillez spécifier un modèle à télécharger.${NC}"
        echo -e "Exemple: $0 pull mistral"
        exit 1
    fi
    
    echo -e "${YELLOW}Téléchargement du modèle $1...${NC}"
    docker compose exec ollama ollama pull $1
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Modèle $1 téléchargé avec succès.${NC}"
    else
        echo -e "${RED}Erreur lors du téléchargement du modèle $1.${NC}"
        exit 1
    fi
}

# Exécuter une commande avec un modèle
run_model() {
    if [ -z "$1" ]; then
        echo -e "${RED}Veuillez spécifier un modèle à exécuter.${NC}"
        echo -e "Exemple: $0 run mistral"
        exit 1
    fi
    
    echo -e "${YELLOW}Exécution du modèle $1...${NC}"
    docker compose exec ollama ollama run $1
}

# Vérifier les prérequis
check_docker
check_docker_compose
create_env_file

# Traiter les commandes
case "$1" in
    start)
        start_services
        ;;
    stop)
        stop_services
        ;;
    restart)
        stop_services
        start_services
        ;;
    pull)
        pull_model "$2"
        ;;
    run)
        run_model "$2"
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        show_help
        exit 1
        ;;
esac

exit 0 