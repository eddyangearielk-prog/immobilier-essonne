-- Export : évolution des ventes et du prix au m² en Essonne, 2021-2025 (pour Power BI)
-- Mêmes règles que evolution.sql
COPY (
    WITH ventes AS (
        SELECT
            id_mutation,
            MIN(YEAR(CAST(date_mutation AS DATE))) AS annee,
            COUNT(DISTINCT nom_commune) AS nb_communes,
            COUNT(*) FILTER (WHERE type_local IN ('Maison', 'Appartement')) AS nb_logements,
            COUNT(*) FILTER (WHERE type_local LIKE 'Local%') AS nb_locaux_activite,
            MAX(valeur_fonciere) AS prix,
            SUM(surface_reelle_bati) FILTER (WHERE type_local IN ('Maison', 'Appartement')) AS surface
        FROM read_csv('data/raw/*/91.csv.gz', union_by_name = true)
        WHERE nature_mutation = 'Vente'
        GROUP BY id_mutation
    )
    SELECT
        annee,
        COUNT(*) AS nb_ventes,
        ROUND(MEDIAN(prix / surface)) AS prix_m2_median
    FROM ventes
    WHERE nb_logements = 1
      AND nb_locaux_activite = 0
      AND nb_communes = 1
      AND surface > 0
      AND prix / surface BETWEEN 500 AND 15000
    GROUP BY annee
    ORDER BY annee
) TO 'resultats/evolution_2021_2025.csv' (HEADER);
