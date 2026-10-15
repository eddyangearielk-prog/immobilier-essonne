# Immobilier en Essonne : analyse des ventes 2025

Analyse du marché immobilier de l'Essonne (91) à partir des données publiques
**DVF** (Demandes de Valeurs Foncières) publiées par la DGFiP sur data.gouv.fr.

![Tableau de bord Power BI](images/dashboard.png)

## Outils
- **DuckDB** et **SQL** : ingestion, contrôles qualité, agrégations (CTE)
- **Power BI** : tableau de bord interactif, mesures DAX, thème personnalisé
- **Linux (WSL2)**, **VS Code**, **Git / GitHub**

## Démarche
1. **Ingestion** du fichier officiel DVF 2025 de l'Essonne
2. **Contrôles qualité** : couverture temporelle, structure des données, valeurs aberrantes
3. **Correction d'un biais** : certaines ventes regroupent des dizaines de logements
   (ex. 2 ventes de 80 logements à Igny), ce qui gonflait le prix au m² (12 497 €/m² au lieu de 4 602 €/m²).
   Correction avec une CTE : une ligne par vente, ventes d'un seul logement uniquement.
   Sont aussi exclues les ventes mixtes (logement + local commercial, dont le prix couvre les deux)
   et les ventes portant sur plusieurs communes.
   Les prix aberrants sont écartés : moins de 500 €/m² (ventes à 1 €, cessions symboliques)
   ou plus de 15 000 €/m² (surface bâtie incohérente, ex. une maison de 4 m²).
4. **Export** des résultats en CSV et **visualisation** dans Power BI

## Principaux résultats (2025)
- 43 662 lignes, mais **17 625 ventes réelles** : une vente peut occuper plusieurs lignes
- **11 410 ventes** d'un seul logement analysées dans **88 communes** (au moins 30 ventes chacune)
- Prix médian au m² le plus élevé : **Verrières-le-Buisson (4 636 €/m²)**, suivie d'Igny, Saclay et Bièvres
- Les communes les plus chères sont au nord du département, près de Paris et du plateau de Saclay

## Fichiers du projet
| Fichier | Rôle |
|---|---|
| `exploration.sql` | Exploration et contrôles qualité |
| `correction.sql` | Prix au m² corrigé (CTE) |
| `export.sql` | Export des résultats pour Power BI |
| `resultats/prix_m2_communes.csv` | Résultats par commune |
| `immobilier-essonne.pbix` | Tableau de bord Power BI |
| `theme-bleu.json` | Thème Power BI personnalisé |
| `telecharger.sh` | Téléchargement automatisé des données 2021-2025 |
| `evolution.sql` | Évolution des ventes et des prix 2021-2025 |

## Reproduire l'analyse
```bash
bash telecharger.sh      # télécharge 2021 à 2025 dans data/raw/<année>/
duckdb < correction.sql  # classement des communes (2025)
duckdb < export.sql      # export pour Power BI
duckdb < evolution.sql   # évolution 2021-2025
```
Puis ouvrir `immobilier-essonne.pbix` dans Power BI Desktop et cliquer sur **Actualiser**.

Données téléchargées le 15/10/2026 depuis le dossier `latest` de data.gouv.fr. Ce dossier ne conserve qu'environ cinq années et peut être révisé : un nouveau téléchargement peut donner des chiffres légèrement différents.

## Évolution 2021-2025 (tout le département)
![Page Évolution du tableau de bord Power BI](images/evolution.png)


| Année | Ventes | Prix médian au m² |
|---|---|---|
| 2021 | 17 358 | 3 272 € |
| 2022 | 16 418 | 3 428 € |
| 2023 | 12 023 | 3 316 € |
| 2024 | 10 867 | 3 125 € |
| 2025 | 12 385 | 3 136 € |

- Le nombre de ventes a chuté de 37 % entre 2021 et 2024, puis rebondit de 14 % en 2025.
- Le prix médian a culminé en 2022, a reculé d'environ 9 % jusqu'en 2024, et se stabilise en 2025.
- Ce retournement coïncide avec la hausse des taux d'intérêt, qui ne figure pas dans ces données.
- Chiffres vérifiés de façon indépendante (recalcul en Python) ; chaque année couvre bien janvier à décembre.

*Ces chiffres portent sur tout le département : 12 385 ventes en 2025, contre 11 410 dans le classement, qui ne retient que les 88 communes ayant au moins 30 ventes.*

## Analyse et recommandations

**1. Un marché très contrasté.** Le prix médian au m² va de 1 209 € (Grigny) à 4 636 € (Verrières-le-Buisson), soit un écart de près de 1 à 4. La commune typique se situe à 3 199 €/m².

**2. Un gradient nord-sud.** Le prix diminue nettement avec la distance à Paris : les communes les plus chères sont au nord, près de Paris et du plateau de Saclay. Ce lien n'explique pas tout : Grigny, proche de Paris, reste la commune la moins chère, ce qui renvoie à d'autres facteurs non mesurés dans ces données.

**3. Corbeil-Essonnes, marché accessible et très actif.** Avec 2 614 €/m², elle figure parmi les communes les moins chères (79ᵉ sur 88), mais c'est le marché le plus actif du département (549 ventes), devant Évry-Courcouronnes et Massy.

**Recommandations**
- *Acheteur à budget limité* : cibler le centre et le sud-est du département (Corbeil-Essonnes, Évry-Courcouronnes, Ris-Orangis), où les prix sont bas et l'offre abondante.
- *Professionnel de l'immobilier* : concentrer l'effort commercial sur les marchés les plus actifs (Corbeil-Essonnes, Évry-Courcouronnes, Massy).
- *Collectivité* : suivre les écarts extrêmes, qui peuvent signaler des besoins en politique du logement.

**Limites** : une seule année de données (2025) ; seules les ventes d'un logement unique sont retenues ; les ventes de logements neufs sur plan (VEFA) sont exclues, l'analyse porte donc sur le marché de l'ancien. Prochaine étape : l'évolution des prix 2021-2025.

## Source
Données : [DVF géolocalisées, data.gouv.fr](https://www.data.gouv.fr/fr/datasets/demandes-de-valeurs-foncieres-geolocalisees/), Licence Ouverte 2.0
