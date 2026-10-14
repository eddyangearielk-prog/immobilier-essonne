-- Export corrigé : prix au m² par commune (ventes d'un seul logement, au moins 30 ventes)
-- Exclut les ventes mixtes (logement + local commercial) et les ventes sur plusieurs communes
-- Prix aberrants exclus : moins de 500 €/m² ou plus de 15 000 €/m²
COPY (
    WITH ventes AS (
        SELECT
            id_mutation,
            MIN(nom_commune) AS nom_commune,
            COUNT(DISTINCT nom_commune) AS nb_communes,
            COUNT(*) FILTER (WHERE type_local IN ('Maison', 'Appartement')) AS nb_logements,
            COUNT(*) FILTER (WHERE type_local LIKE 'Local%') AS nb_locaux_activite,
            MAX(valeur_fonciere) AS prix,
            SUM(surface_reelle_bati) FILTER (WHERE type_local IN ('Maison', 'Appartement')) AS surface,
            MAX(latitude) FILTER (WHERE type_local IN ('Maison', 'Appartement')) AS latitude,
            MAX(longitude) FILTER (WHERE type_local IN ('Maison', 'Appartement')) AS longitude
        FROM 'data/raw/91.csv.gz'
        WHERE nature_mutation = 'Vente'
        GROUP BY id_mutation
    )

    SELECT
        nom_commune,
        COUNT(*) AS nb_ventes,
        ROUND(MEDIAN(prix / surface)) AS prix_m2_median,
        ROUND(AVG(latitude), 5) AS latitude,
        ROUND(AVG(longitude), 5) AS longitude
    FROM ventes
    WHERE nb_logements = 1
      AND nb_locaux_activite = 0
      AND nb_communes = 1
      AND surface > 0
      AND prix / surface BETWEEN 500 AND 15000
    GROUP BY nom_commune
    HAVING COUNT(*) >= 30
    ORDER BY prix_m2_median DESC, nom_commune ASC
) TO 'resultats/prix_m2_communes.csv';  -- DuckDB écrit l'en-tête par défaut
