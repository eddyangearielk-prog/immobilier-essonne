-- Première exploration : combien de ventes, et sur quelle période ?
SELECT
    COUNT(*) AS nb_lignes,
    MIN(date_mutation) AS premiere_vente,
    MAX(date_mutation) AS derniere_vente
FROM 'data/raw/91.csv.gz'; 

-- Combien de vraies ventes ? (une vente = un id_mutation)
SELECT
    COUNT(*) AS nb_lignes,
    COUNT(DISTINCT id_mutation) AS nb_ventes
FROM 'data/raw/91.csv.gz';

-- Quels types de biens dans les ventes ?
SELECT
    type_local,
    COUNT(*) AS nb_lignes
FROM 'data/raw/91.csv.gz'
GROUP BY type_local
ORDER BY nb_lignes DESC;

-- Prix médian d'une maison et d'un appartement en Essonne (2025)
SELECT
    type_local,
    COUNT(DISTINCT id_mutation) AS nb_ventes,
    MEDIAN(valeur_fonciere) AS prix_median
FROM 'data/raw/91.csv.gz'
WHERE nature_mutation = 'Vente'
  AND type_local IN ('Maison', 'Appartement')
GROUP BY type_local;

-- Prix médian au m² à Corbeil-Essonnes (2025)
SELECT
    type_local,
    COUNT(DISTINCT id_mutation) AS nb_ventes,
    ROUND(MEDIAN(valeur_fonciere / surface_reelle_bati)) AS prix_m2_median
FROM 'data/raw/91.csv.gz'
WHERE nature_mutation = 'Vente'
  AND type_local IN ('Maison', 'Appartement')
  AND nom_commune = 'Corbeil-Essonnes'
  AND surface_reelle_bati > 0
GROUP BY type_local;

-- Top 10 des communes les plus chères au m² (au moins 30 ventes)
SELECT
    nom_commune,
    COUNT(DISTINCT id_mutation) AS nb_ventes,
    ROUND(MEDIAN(valeur_fonciere / surface_reelle_bati)) AS prix_m2_median
FROM 'data/raw/91.csv.gz'
WHERE nature_mutation = 'Vente'
  AND type_local IN ('Maison', 'Appartement')
  AND surface_reelle_bati > 0
GROUP BY nom_commune
HAVING COUNT(DISTINCT id_mutation) >= 30
ORDER BY prix_m2_median DESC
LIMIT 10;
SELECT
    nom_commune,
    COUNT(DISTINCT id_mutation) AS nb_ventes,
    ROUND(MEDIAN(valeur_fonciere / surface_reelle_bati)) AS prix_m2_median
FROM 'data/raw/91.csv.gz'
WHERE nature_mutation = 'Vente'
  AND type_local IN ('Maison', 'Appartement')
  AND surface_reelle_bati > 0
GROUP BY nom_commune
HAVING COUNT(DISTINCT id_mutation) >= 30
ORDER BY prix_m2_median ASC
LIMIT 10;

