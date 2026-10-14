-- Prix au m² corrigé : une vente = une ligne, uniquement les ventes d'un seul logement

-- ÉTAPE 1 (la CTE) : préparer un tableau avec une ligne par vente
WITH ventes AS (
    SELECT
        id_mutation,
        nom_commune,
        COUNT(*) AS nb_logements,
        MAX(valeur_fonciere) AS prix,
        SUM(surface_reelle_bati) AS surface
    FROM 'data/raw/91.csv.gz'
    WHERE nature_mutation = 'Vente'
      AND type_local IN ('Maison', 'Appartement')
      AND surface_reelle_bati > 0
    GROUP BY id_mutation, nom_commune
)

-- ÉTAPE 2 : calculer le prix au m² sur ce tableau propre
SELECT
    nom_commune,
    COUNT(*) AS nb_ventes,
    ROUND(MEDIAN(prix / surface)) AS prix_m2_median
FROM ventes
WHERE nb_logements = 1
GROUP BY nom_commune
HAVING COUNT(*) >= 30
ORDER BY prix_m2_median DESC
LIMIT 10;