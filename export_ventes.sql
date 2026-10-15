-- Export : une ligne par vente nettoyée, 2021-2025 (table de faits pour Power BI)
-- Mêmes règles que correction.sql et evolution.sql
COPY (
    WITH ventes AS (
        SELECT
            id_mutation,
            MIN(CAST(date_mutation AS DATE)) AS date_vente,
            MIN(nom_commune) AS nom_commune,
            COUNT(DISTINCT nom_commune) AS nb_communes,
            COUNT(*) FILTER (WHERE type_local IN ('Maison', 'Appartement')) AS nb_logements,
            COUNT(*) FILTER (WHERE type_local LIKE 'Local%') AS nb_locaux_activite,
            MAX(type_local) FILTER (WHERE type_local IN ('Maison', 'Appartement')) AS type_logement,
            MAX(valeur_fonciere) AS prix,
            SUM(surface_reelle_bati) FILTER (WHERE type_local IN ('Maison', 'Appartement')) AS surface
        FROM read_csv('data/raw/*/91.csv.gz', union_by_name = true)
        WHERE nature_mutation = 'Vente'
        GROUP BY id_mutation
    )
    SELECT
        id_mutation,
        date_vente,
        YEAR(date_vente) AS annee,
        MONTH(date_vente) AS mois,
        nom_commune,
        type_logement,
        prix,
        surface,
        ROUND(prix / surface, 2) AS prix_m2
    FROM ventes
    WHERE nb_logements = 1
      AND nb_locaux_activite = 0
      AND nb_communes = 1
      AND surface > 0
      AND prix / surface BETWEEN 500 AND 15000
    ORDER BY date_vente
) TO 'resultats/ventes_2021_2025.csv' (HEADER);
