#!/bin/bash

# Couleurs pour les messages
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction pour afficher les messages
print_message() {
    echo -e "${BLUE}[Ollama]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[Succès]${NC} $1"
}

print_error() {
    echo -e "${RED}[Erreur]${NC} $1"
}

# Vérifier que Docker est installé
check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker n'est pas installé. Veuillez l'installer avant de continuer."
        exit 1
    fi
}

# Démarrer Ollama
start() {
    print_message "Démarrage d'Ollama..."
    docker compose up -d
    if [ $? -eq 0 ]; then
        print_success "Ollama a été démarré avec succès"
    else
        print_error "Erreur lors du démarrage d'Ollama"
        exit 1
    fi
}

# Arrêter Ollama
stop() {
    print_message "Arrêt d'Ollama..."
    docker compose down
    if [ $? -eq 0 ]; then
        print_success "Ollama a été arrêté avec succès"
    else
        print_error "Erreur lors de l'arrêt d'Ollama"
        exit 1
    fi
}

# Redémarrer Ollama
restart() {
    stop
    start
}

# Télécharger un modèle
pull() {
    if [ -z "$1" ]; then
        print_error "Veuillez spécifier un modèle à télécharger"
        echo "Usage: $0 pull <nom_du_modele>"
        exit 1
    fi
    print_message "Téléchargement du modèle $1..."
    docker compose exec ollama ollama pull "$1"
    if [ $? -eq 0 ]; then
        print_success "Le modèle $1 a été téléchargé avec succès"
    else
        print_error "Erreur lors du téléchargement du modèle $1"
        exit 1
    fi
}

# Exécuter une commande avec un modèle
run() {
    if [ -z "$1" ]; then
        print_error "Veuillez spécifier un modèle à exécuter"
        echo "Usage: $0 run <nom_du_modele>"
        exit 1
    fi
    print_message "Exécution du modèle $1..."
    docker compose exec ollama ollama run "$1"
}

# Afficher l'aide
show_help() {
    echo "Usage: $0 <commande> [arguments]"
    echo ""
    echo "Commandes disponibles:"
    echo "  start         Démarrer Ollama"
    echo "  stop          Arrêter Ollama"
    echo "  restart       Redémarrer Ollama"
    echo "  pull <model>  Télécharger un modèle"
    echo "  run <model>   Exécuter une commande avec un modèle"
    echo "  help         Afficher cette aide"
    echo ""
    echo "Exemples:"
    echo "  $0 start"
    echo "  $0 pull mistral"
    echo "  $0 run mistral"
}

# Vérifier que Docker est installé
check_docker

# Traiter les commandes
case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    restart)
        restart
        ;;
    pull)
        pull "$2"
        ;;
    run)
        run "$2"
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        print_error "Commande inconnue: $1"
        show_help
        exit 1
        ;;
esac 