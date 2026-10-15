#!/bin/bash
# Télécharge les ventes immobilières de l'Essonne (DVF) pour plusieurs années.
# Source : data.gouv.fr (dossier "latest", qui ne garde qu'environ 5 années).

set -euo pipefail          # s'arrêter dès la première erreur
cd "$(dirname "$0")"       # travailler dans le dossier du projet, d'où qu'on lance le script

for annee in 2021 2022 2023 2024 2025
do
    echo "Téléchargement de l'année $annee..."
    mkdir -p data/raw/$annee
    wget -q -O data/raw/$annee/91.csv.gz \
        https://files.data.gouv.fr/geo-dvf/latest/csv/$annee/departements/91.csv.gz

    # Vérifier que le fichier n'est pas vide
    if [ ! -s data/raw/$annee/91.csv.gz ]; then
        echo "ERREUR : le fichier de $annee est vide."
        exit 1
    fi
done

date "+%Y-%m-%d" > data/raw/date_telechargement.txt
echo "Terminé ! Données téléchargées le $(cat data/raw/date_telechargement.txt)."
