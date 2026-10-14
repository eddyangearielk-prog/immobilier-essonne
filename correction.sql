-- Prix au m² corrigé : une vente = une ligne, uniquement les ventes d'un seul logement
-- (sans local commercial associé, et situées dans une seule commune)
-- Prix aberrants exclus : moins de 500 €/m² (ventes à 1 €, cessions symboliques)
-- ou plus de 15 000 €/m² (surface bâtie incohérente)

-- ÉTAPE 1 (la CTE) : préparer un tableau avec une ligne par vente
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

-- ÉTAPE 2 : calculer le prix au m² sur ce tableau propre
SELECT
    nom_commune,
    COUNT(*) AS nb_ventes,
    ROUND(MEDIAN(prix / surface)) AS prix_m2_median
FROM ventes
WHERE nb_logements = 1
  AND nb_locaux_activite = 0
  AND nb_communes = 1
  AND surface > 0
  AND prix / surface BETWEEN 500 AND 15000
GROUP BY nom_commune
HAVING COUNT(*) >= 30
ORDER BY prix_m2_median DESC
LIMIT 10;
