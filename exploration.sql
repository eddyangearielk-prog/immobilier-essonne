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

-- Les requêtes de prix ci-dessous travaillent sur une ligne par vente,
-- en ne gardant que les ventes d'un seul logement (sans local commercial,
-- dans une seule commune), comme dans correction.sql.

-- Prix médian d'une maison et d'un appartement en Essonne (2025)
WITH ventes AS (
    SELECT
        id_mutation,
        COUNT(DISTINCT nom_commune) AS nb_communes,
        COUNT(*) FILTER (WHERE type_local IN ('Maison', 'Appartement')) AS nb_logements,
        COUNT(*) FILTER (WHERE type_local LIKE 'Local%') AS nb_locaux_activite,
        MAX(type_local) FILTER (WHERE type_local IN ('Maison', 'Appartement')) AS type_local,
        MAX(valeur_fonciere) AS prix
    FROM 'data/raw/91.csv.gz'
    WHERE nature_mutation = 'Vente'
    GROUP BY id_mutation
)

SELECT
    type_local,
    COUNT(*) AS nb_ventes,
    MEDIAN(prix) AS prix_median
FROM ventes
WHERE nb_logements = 1
  AND nb_locaux_activite = 0
  AND nb_communes = 1
GROUP BY type_local;

-- Prix médian au m² à Corbeil-Essonnes (2025)
WITH ventes AS (
    SELECT
        id_mutation,
        MIN(nom_commune) AS nom_commune,
        COUNT(DISTINCT nom_commune) AS nb_communes,
        COUNT(*) FILTER (WHERE type_local IN ('Maison', 'Appartement')) AS nb_logements,
        COUNT(*) FILTER (WHERE type_local LIKE 'Local%') AS nb_locaux_activite,
        MAX(type_local) FILTER (WHERE type_local IN ('Maison', 'Appartement')) AS type_local,
        MAX(valeur_fonciere) AS prix,
        SUM(surface_reelle_bati) FILTER (WHERE type_local IN ('Maison', 'Appartement')) AS surface
    FROM 'data/raw/91.csv.gz'
    WHERE nature_mutation = 'Vente'
    GROUP BY id_mutation
)

SELECT
    type_local,
    COUNT(*) AS nb_ventes,
    ROUND(MEDIAN(prix / surface)) AS prix_m2_median
FROM ventes
WHERE nb_logements = 1
  AND nb_locaux_activite = 0
  AND nb_communes = 1
  AND surface > 0
  AND nom_commune = 'Corbeil-Essonnes'
GROUP BY type_local;

-- AVANT CORRECTION (volontairement biaisé) : top 10 des communes les plus chères au m²
-- calculé ligne par ligne. Les ventes de plusieurs logements gonflent le prix au m²
-- (Igny à 12 497 €/m²). Version corrigée : correction.sql
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

-- Top 10 des communes les moins chères au m² (au moins 30 ventes)
WITH ventes AS (
    SELECT
        id_mutation,
        MIN(nom_commune) AS nom_commune,
        COUNT(DISTINCT nom_commune) AS nb_communes,
        COUNT(*) FILTER (WHERE type_local IN ('Maison', 'Appartement')) AS nb_logements,
        COUNT(*) FILTER (WHERE type_local LIKE 'Local%') AS nb_locaux_activite,
        MAX(valeur_fonciere) AS prix,
        SUM(surface_reelle_bati) FILTER (WHERE type_local IN ('Maison', 'Appartement')) AS surface
    FROM 'data/raw/91.csv.gz'
    WHERE nature_mutation = 'Vente'
    GROUP BY id_mutation
)

SELECT
    nom_commune,
    COUNT(*) AS nb_ventes,
    ROUND(MEDIAN(prix / surface)) AS prix_m2_median
FROM ventes
WHERE nb_logements = 1
  AND nb_locaux_activite = 0
  AND nb_communes = 1
  AND surface > 0
GROUP BY nom_commune
HAVING COUNT(*) >= 30
ORDER BY prix_m2_median ASC
LIMIT 10;
