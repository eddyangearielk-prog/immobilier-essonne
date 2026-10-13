# Immobilier en Essonne : analyse des ventes 2025

Analyse du marché immobilier de l'Essonne (91) à partir des données publiques
**DVF** (Demandes de Valeurs Foncières) publiées par la DGFiP sur data.gouv.fr.

## Outils
- **DuckDB** : moteur SQL analytique
- **SQL** : exploration, nettoyage et agrégations
- **Linux (WSL2)**, **VS Code**, **Git**

## Démarche
1. Ingestion du fichier officiel DVF 2025 de l'Essonne
2. Contrôles qualité : couverture temporelle, structure des données
3. Analyse : prix médians et prix au m² par commune

## Principaux résultats (2025)
- 43 662 lignes, mais **17 625 ventes réelles** : une vente peut occuper plusieurs lignes
- Prix médian d'une **maison** : **320 000 €** ; d'un **appartement** : **177 000 €**
- Classement des communes par prix au m² : **en cours de correction**. Biais détecté : certaines ventes regroupent des dizaines de logements (ex. 2 ventes de 80 logements à Igny), ce qui gonfle artificiellement le prix au m².

## Reproduire l'analyse
```bash
mkdir -p data/raw
wget -P data/raw https://files.data.gouv.fr/geo-dvf/latest/csv/2025/departements/91.csv.gz
duckdb < exploration.sql
```

## Limites
Le prix au m² est approximatif lorsqu'une même vente contient plusieurs logements.
Amélioration prévue : dédoublonnage des ventes multi-biens.

## Source
Données : [DVF géolocalisées, data.gouv.fr](https://www.data.gouv.fr/fr/datasets/demandes-de-valeurs-foncieres-geolocalisees/), Licence Ouverte 2.0
