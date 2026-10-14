-- Export corrigé : prix au m² par commune (ventes d'un seul logement, au moins 30 ventes)
COPY (
    WITH ventes AS (
        SELECT
            id_mutation,
            nom_commune,
            COUNT(*) AS nb_logements,
            MAX(valeur_fonciere) AS prix,
            SUM(surface_reelle_bati) AS surface,
            MAX(latitude) AS latitude,
            MAX(longitude) AS longitude
        FROM 'data/raw/91.csv.gz'
        WHERE nature_mutation = 'Vente'
          AND type_local IN ('Maison', 'Appartement')
          AND surface_reelle_bati > 0
        GROUP BY id_mutation, nom_commune
    )
    SELECT
        nom_commune,
        COUNT(*) AS nb_ventes,
        ROUND(MEDIAN(prix / surface)) AS prix_m2_median,
        ROUND(AVG(latitude), 5) AS latitude,
        ROUND(AVG(longitude), 5) AS longitude
    FROM ventes
    WHERE nb_logements = 1
    GROUP BY nom_commune
    HAVING COUNT(*) >= 30
    ORDER BY prix_m2_median DESC
) TO 'resultats/prix_m2_communes.csv' (HEADER);