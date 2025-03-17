#!/bin/bash

# Couleurs pour les messages
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Fonction pour afficher les messages
print_message() {
    echo -e "${BLUE}[Ollama]${NC} $1"
}

print_webui_message() {
    echo -e "${YELLOW}[WebUI]${NC} $1"
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

# Démarrer les services
start() {
    print_message "Démarrage des services..."
    docker compose up -d
    if [ $? -eq 0 ]; then
        print_success "Les services ont été démarrés avec succès"
        print_message "API Ollama accessible uniquement à l'intérieur du réseau Docker"
        print_webui_message "Interface Web disponible à l'adresse: http://localhost:3000"
    else
        print_error "Erreur lors du démarrage des services"
        exit 1
    fi
}

# Arrêter les services
stop() {
    print_message "Arrêt des services..."
    docker compose down
    if [ $? -eq 0 ]; then
        print_success "Les services ont été arrêtés avec succès"
    else
        print_error "Erreur lors de l'arrêt des services"
        exit 1
    fi
}

# Redémarrer les services
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

# Afficher les logs
logs() {
    if [ -z "$1" ]; then
        print_message "Affichage des logs de tous les services..."
        docker compose logs --tail=100 -f
    else
        if [ "$1" = "ollama" ] || [ "$1" = "open-webui" ]; then
            print_message "Affichage des logs du service $1..."
            docker compose logs --tail=100 -f "$1"
        else
            print_error "Service inconnu: $1"
            echo "Services disponibles: ollama, open-webui"
            exit 1
        fi
    fi
}

# Afficher les modèles disponibles
models() {
    print_message "Liste des modèles disponibles..."
    docker compose exec ollama ollama list
}

# Afficher l'aide
show_help() {
    echo "Usage: $0 <commande> [arguments]"
    echo ""
    echo "Commandes disponibles:"
    echo "  start         Démarrer tous les services"
    echo "  stop          Arrêter tous les services"
    echo "  restart       Redémarrer tous les services"
    echo "  pull <model>  Télécharger un modèle"
    echo "  run <model>   Exécuter une commande avec un modèle"
    echo "  logs [service] Afficher les logs (ollama, open-webui ou tous si non spécifié)"
    echo "  models        Afficher la liste des modèles disponibles"
    echo "  help          Afficher cette aide"
    echo ""
    echo "Exemples:"
    echo "  $0 start"
    echo "  $0 pull mistral"
    echo "  $0 run mistral"
    echo "  $0 logs ollama"
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
    logs)
        logs "$2"
        ;;
    models)
        models
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