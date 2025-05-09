
-- 📌 1. Verificação e Tratamento de Nulos
SELECT * 
FROM `validacaohipotesesprojeto002.spotify.competition` 
WHERE in_shazam_charts IS NULL;

SELECT 
  track_id,
  IFNULL(in_apple_playlists, 0) AS in_apple_playlists,
  IFNULL(in_apple_charts, 0) AS in_apple_charts,
  IFNULL(in_deezer_playlists, 0) AS in_deezer_playlists,
  IFNULL(in_deezer_charts, 0) AS in_deezer_charts,
  IFNULL(in_shazam_charts, 0) AS in_shazam_charts
FROM `validacaohipotesesprojeto002.spotify.competition`;

-- 📌 2. Tratamento de Colunas Técnicas
SELECT 
  track_id,
  COALESCE(bpm, 0) AS bpm,
  COALESCE(`danceability__`, 0) AS danceability,
  COALESCE(`valence__`, 0) AS valence,
  COALESCE(`energy__`, 0) AS energy,
  COALESCE(`acousticness__`, 0) AS acousticness,
  COALESCE(`instrumentalness__`, 0) AS instrumentalness,
  COALESCE(`liveness__`, 0) AS liveness,
  COALESCE(`speechiness__`, 0) AS speechiness
FROM `validacaohipotesesprojeto002.spotify.technical_info`;

-- 📌 3. Identificação de Duplicidades
SELECT
  track_name,
  artist_s__name,
  COUNT(*) AS quantidade
FROM `validacaohipotesesprojeto002.spotify.track_spotify`
GROUP BY track_name, artist_s__name
HAVING COUNT(*) > 1;

-- 📌 4. Padronização de Strings
SELECT
  track_id,
  REGEXP_REPLACE(track_name, r'[^a-zA-Z0-9 ]','') AS track_name,
  REGEXP_REPLACE(artist_s__name, r'[^a-zA-Z0-9 ]','') AS artist_s__name,
  artist_count,
  released_year,
  released_month,
  released_day,
  in_spotify_playlists,
  in_spotify_charts,
  streams
FROM `validacaohipotesesprojeto002.spotify.track_spotify`;

-- 📌 5. Criação de release_date e total_por_charts_playlists
SELECT 
  *, 
  DATE(CONCAT(CAST(released_year AS STRING), "-", CAST(released_month AS STRING), "-", CAST(released_day AS STRING))) AS release_date,
  in_spotify_playlists + in_spotify_charts AS total_por_charts_playlists
FROM `validacaohipotesesprojeto002.spotify.track_spotify`;

-- 📌 6. Cálculo de Quartis
CREATE OR REPLACE TABLE `validacaohipotesesprojeto002.spotify.variaveis_streams_quartil` AS
SELECT *,
  NTILE(4) OVER (ORDER BY SAFE_CAST(streams AS INT64)) AS quartil_streams
FROM `validacaohipotesesprojeto002.spotify.track_spotify_unificada`;

-- 📌 7. Correlação entre Variáveis
SELECT 'bpm' AS variavel, CORR(streams, bpm) AS correlacao
FROM `validacaohipotesesprojeto002.spotify.variaveis_derivadas`
WHERE streams IS NOT NULL AND bpm IS NOT NULL
UNION ALL
SELECT 'in_apple_playlists', CORR(streams, in_apple_playlists)
FROM `validacaohipotesesprojeto002.spotify.variaveis_derivadas`
WHERE streams IS NOT NULL AND in_apple_playlists IS NOT NULL;

-- 📌 8. Validação de Hipóteses
SELECT
  classificacao_danceability,
  ROUND(AVG(streams), 2) AS media_streams
FROM `validacaohipotesesprojeto002.spotify.variaveis_derivadas`
GROUP BY classificacao_danceability
ORDER BY media_streams DESC;
