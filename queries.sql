-- 📌 1. Verificação e Tratamento de Nulos
SELECT * 
FROM 
`validacaohipotesesprojeto002.spotify.competition` 
WHERE in_shazam_charts IS NULL

SELECT 
  track_id,
  IFNULL(in_apple_playlists, 0) AS in_apple_playlists,
  IFNULL(in_apple_charts, 0) AS in_apple_charts,
  IFNULL(in_deezer_playlists, 0) AS in_deezer_playlists,
  IFNULL(in_deezer_charts, 0) AS in_deezer_charts,
  IFNULL(in_shazam_charts, 0) AS in_shazam_charts
  
FROM 
  `validacaohipotesesprojeto002.spotify.competition`

-- 📌 2. Tratamento de Colunas Técnicas
SELECT 
  track_id,
  COALESCE(bpm, 0) AS bpm,
  COALESCE(`danceability__`, 0) AS `danceability_%`,
  COALESCE(`valence__`, 0) AS `valence_%`,
  COALESCE(`energy__`, 0) AS `energy_%`,
  COALESCE(`acousticness__`, 0) AS `acousticness_%`,
  COALESCE(`instrumentalness__`, 0) AS `instrumentalness_%`,
  COALESCE(`liveness__`, 0) AS `liveness_%`,
  COALESCE(`speechiness__`, 0) AS `speechiness_%`
FROM 
  `validacaohipotesesprojeto002.spotify.technical_info`

  SELECT *
FROM 
`validacaohipotesesprojeto002.spotify.technical_info` 
WHERE KEY IS NULL

-- 📌 3. Identificação de Duplicidades
SELECT
track_name,
artist_s__name,
COUNT(*) as quantidade
FROM 
`validacaohipotesesprojeto002.spotify.track_spotify` 
GROUP BY
track_name, artist_s__name
having count(*) > 1

SELECT *
FROM `validacaohipotesesprojeto002.spotify.track_spotify_unificada`
WHERE artist_s__name = 'Rosa Linn'
  AND track_name = 'SNAP'

SELECT *
FROM `validacaohipotesesprojeto002.spotify.track_spotify_unificada`
WHERE artist_s__name = 'Lizzo'
  AND track_name = 'About Damn Time'

SELECT *
FROM `validacaohipotesesprojeto002.spotify.track_spotify_unificada`
WHERE artist_s__name = 'The Weeknd'
  AND track_name = 'Take My Breath'

SELECT *
FROM `validacaohipotesesprojeto002.spotify.track_spotify_unificada`
WHERE track_id IN ('4967469', '8173823')

SELECT
  -- Pega o track_id mais recente
  ARRAY_AGG(track_id ORDER BY SAFE_CAST(released_year AS INT64) DESC, SAFE_CAST(released_month AS INT64) DESC, SAFE_CAST(released_day AS INT64) DESC LIMIT 1)[OFFSET(0)] AS track_id,

  track_name,
  artist_s__name,

  AVG(SAFE_CAST(artist_count AS FLOAT64)) AS media_artist_count,
  AVG(SAFE_CAST(released_year AS FLOAT64)) AS media_released_year,
  AVG(SAFE_CAST(released_month AS FLOAT64)) AS media_released_month,
  AVG(SAFE_CAST(released_day AS FLOAT64)) AS media_released_day,
  AVG(SAFE_CAST(in_spotify_playlists AS FLOAT64)) AS media_in_spotify_playlists,
  AVG(SAFE_CAST(in_spotify_charts AS FLOAT64)) AS media_in_spotify_charts,
  AVG(SAFE_CAST(streams AS FLOAT64)) AS media_streams

FROM `validacaohipotesesprojeto002.spotify.track_spotify`
GROUP BY
  track_name, artist_s__name
HAVING COUNT(*) > 1

SELECT 
* except (key,mode)
FROM 
`validacaohipotesesprojeto002.spotify.technical_info`

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
FROM 
  `validacaohipotesesprojeto002.spotify.track_spotify`

SELECT 
MAX(streams),
MIN(streams),
FROM `validacaohipotesesprojeto002.spotify.track_spotify` 

SELECT  
  track_id,
  track_name,
  artist_s__name,
  artist_count,
  released_year,
  released_month,
  released_day,
  in_spotify_playlists,
  in_spotify_charts,
  SAFE_CAST(streams AS INT64) AS streams
FROM `validacaohipotesesprojeto002.spotify.track_spotify`

SELECT 
  MIN(SAFE_CAST(streams AS INT64)) AS menor_streams,
  MAX(SAFE_CAST(streams AS INT64)) AS maior_streams
FROM `validacaohipotesesprojeto002.spotify.track_spotify_unificada`;

SELECT 
*,
DATE(CONCAT(CAST(released_year AS STRING),"-", CAST(released_month AS STRING),"-", CAST(released_day AS STRING))) AS release_date,
in_spotify_playlists + in_spotify_charts AS total_por_charts_playlists
FROM 
`validacaohipotesesprojeto002.spotify.track_spotify` 

--Unir tabelas

CREATE OR REPLACE TABLE `validacaohipotesesprojeto002.spotify.track_spotify_unificada` AS (
  WITH TrackSpotifyAggregated AS (
    SELECT
      -- Pega o track_id mais recente
      ARRAY_AGG(t.track_id ORDER BY SAFE_CAST(nv.release_date AS DATE) DESC LIMIT 1)[OFFSET(0)] AS track_id,
      ts.track_name,
      ts.artist_s__name,
      AVG(t.artist_count) AS artist_count,

      -- ✅ Aqui a média de release_date corretamente
      DATE_FROM_UNIX_DATE(CAST(AVG(UNIX_DATE(nv.release_date)) AS INT64)) AS release_date,

      AVG(st.streams) AS streams,
      AVG(qt.quartil_streams) AS quartil_streams,
      AVG(ti.bpm) AS bpm,
      AVG(CAST(REPLACE(CAST(ti.`danceability_%` AS STRING), ',', '.') AS NUMERIC)) AS danceability,
      AVG(CAST(REPLACE(CAST(ti.`valence_%` AS STRING), ',', '.') AS NUMERIC)) AS valence,
      AVG(CAST(REPLACE(CAST(ti.`energy_%` AS STRING), ',', '.') AS NUMERIC)) AS energy,
      AVG(CAST(REPLACE(CAST(ti.`acousticness_%` AS STRING), ',', '.') AS NUMERIC)) AS acousticness,
      AVG(CAST(REPLACE(CAST(ti.`instrumentalness_%` AS STRING), ',', '.') AS NUMERIC)) AS instrumentalness,
      AVG(CAST(REPLACE(CAST(ti.`liveness_%` AS STRING), ',', '.') AS NUMERIC)) AS liveness,
      AVG(CAST(REPLACE(CAST(ti.`speechiness_%` AS STRING), ',', '.') AS NUMERIC)) AS speechiness,
      AVG(c.in_apple_playlists) AS in_apple_playlists,
      AVG(c.in_apple_charts) AS in_apple_charts,
      AVG(c.in_deezer_playlists) AS in_deezer_playlists,
      AVG(c.in_deezer_charts) AS in_deezer_charts,
      AVG(c.in_shazam_charts) AS in_shazam_charts,
      AVG(t.in_spotify_playlists) AS in_spotify_playlists,
      COUNT(*) AS track_count
    FROM
      `validacaohipotesesprojeto002.spotify.track_spotify` t
      LEFT JOIN `validacaohipotesesprojeto002.spotify.techinical_info_null_0_key_mode_excluido` ti ON t.track_id = ti.track_id
      LEFT JOIN `validacaohipotesesprojeto002.spotify.competion_null_0` c ON t.track_id = c.track_id
      LEFT JOIN `validacaohipotesesprojeto002.spotify.track_spotify_sem_simbolos` ts ON t.track_id = ts.track_id
      LEFT JOIN `validacaohipotesesprojeto002.spotify.track_spotify_date_nova_variavel` nv ON t.track_id = nv.track_id
      LEFT JOIN `validacaohipotesesprojeto002.spotify.track_spotify_streams_media` st ON t.track_id = st.track_id
      LEFT JOIN `validacaohipotesesprojeto002.spotify.variaveis_streams_quartil` qt ON t.track_id = qt.track_id
      LEFT JOIN `validacaohipotesesprojeto002.spotify.track_spotify_duplicidade` sd ON t.track_id = sd.track_id
    GROUP BY
      ts.track_name,
      ts.artist_s__name
  )
  SELECT 
    t.*
  FROM TrackSpotifyAggregated t

);

--Construir tabelas auxiliares
WITH teste AS (
  SELECT
    artist_s__name,
    COUNT(*) AS total_de_artistas_solo_por_id
  FROM `validacaohipotesesprojeto002.spotify.track_spotify`
  GROUP BY artist_s__name
)

SELECT
  tt.track_id,
  -- tt.artist_s__name,  -- Exclude this from track_spotify
  tt.artist_count,
  tt.released_year,
  tt.released_month,
  tt.released_day,
  tt.in_spotify_playlists,
  tt.in_spotify_charts,
  tt.streams,
  teste.artist_s__name,  -- Include artist_s__name from CTE
  teste.total_de_artistas_solo_por_id,
FROM `validacaohipotesesprojeto002.spotify.track_spotify` tt
LEFT JOIN teste
  ON tt.artist_s__name = teste.artist_s__name;

--Calcular quartis, decis ou percentis
  
CREATE OR REPLACE TABLE `validacaohipotesesprojeto002.spotify.variaveis_streams_quartil` AS
SELECT
  *,
  NTILE(4) OVER (ORDER BY SAFE_CAST(streams AS INT64)) AS quartil_streams
FROM `validacaohipotesesprojeto002.spotify.track_spotify_unificada`;

--Calcular correlação entre variáveis

SELECT 'bpm' AS variavel, CORR(streams, bpm) AS correlacao
FROM `validacaohipotesesprojeto002.spotify.variaveis_derivadas`
WHERE streams IS NOT NULL AND bpm IS NOT NULL

UNION ALL

SELECT 'in_apple_playlists', CORR(streams, in_apple_playlists)
FROM `validacaohipotesesprojeto002.spotify.variaveis_derivadas`
WHERE streams IS NOT NULL AND in_apple_playlists IS NOT NULL

UNION ALL

SELECT 'in_deezer_playlists', CORR(streams, in_deezer_playlists)
FROM `validacaohipotesesprojeto002.spotify.variaveis_derivadas`
WHERE streams IS NOT NULL AND in_deezer_playlists IS NOT NULL

UNION ALL

SELECT 'total_playlists', CORR(streams, total_playlists)
FROM `validacaohipotesesprojeto002.spotify.variaveis_derivadas`
WHERE streams IS NOT NULL AND total_playlists IS NOT NULL

UNION ALL

SELECT 'danceability', CORR(streams, danceability)
FROM `validacaohipotesesprojeto002.spotify.variaveis_derivadas`
WHERE streams IS NOT NULL AND danceability IS NOT NULL

UNION ALL

SELECT 'valence', CORR(streams, valence)
FROM `validacaohipotesesprojeto002.spotify.variaveis_derivadas`
WHERE streams IS NOT NULL AND valence IS NOT NULL

UNION ALL

SELECT 'energy', CORR(streams, energy)
FROM `validacaohipotesesprojeto002.spotify.variaveis_derivadas`
WHERE streams IS NOT NULL AND energy IS NOT NULL

UNION ALL

SELECT 'acousticness', CORR(streams, acousticness)
FROM `validacaohipotesesprojeto002.spotify.variaveis_derivadas`
WHERE streams IS NOT NULL AND acousticness IS NOT NULL

UNION ALL

SELECT 'instrumentalness', CORR(streams, instrumentalness)
FROM `validacaohipotesesprojeto002.spotify.variaveis_derivadas`
WHERE streams IS NOT NULL AND instrumentalness IS NOT NULL

UNION ALL

SELECT 'liveness', CORR(streams, liveness)
FROM `validacaohipotesesprojeto002.spotify.variaveis_derivadas`
WHERE streams IS NOT NULL AND liveness IS NOT NULL

UNION ALL

SELECT 'speechiness', CORR(streams, speechiness)
FROM `validacaohipotesesprojeto002.spotify.variaveis_derivadas`
WHERE streams IS NOT NULL AND speechiness IS NOT NULL;

SELECT
  CORR(total_streams, total_musicas) AS correlacao_streams_total_musicas
FROM
  `validacaohipotesesprojeto002.spotify.Total_de_musica_por_artista`
WHERE
  total_streams IS NOT NULL AND total_musicas IS NOT NULL

--Validar hipótese

-- HIPÓTESE 1: Danceabilidade influencia nos streams
SELECT
  classificacao_danceability,
  ROUND(AVG(streams), 2) AS media_streams
FROM `validacaohipotesesprojeto002.spotify.variaveis_derivadas`
GROUP BY classificacao_danceability
ORDER BY media_streams DESC;

--Classificação / Média streams
--1	Baixa 641093661.86
--2	Média 543474266.37
--3	Alta 469022700.48

-- HIPÓTESE 2: Valence (emoção da música) está associada à popularidade
SELECT
  CORR(valence, streams) AS correlacao_valence_streams
FROM `validacaohipotesesprojeto002.spotify.variaveis_derivadas`;

--Correlação valence streams
---0.04114416518

-- HIPÓTESE 3: BPM influencia o sucesso
SELECT
  faixa_bpm,
  ROUND(AVG(streams), 2) AS media_streams
FROM `validacaohipotesesprojeto002.spotify.variaveis_derivadas`
GROUP BY faixa_bpm
ORDER BY media_streams DESC;

--Faixa Bpm / Média streams
--1	Médio 553565604.8
--2	Lento 495208526.37
--3	Rápido 487374489.48

-- HIPÓTESE 4: Músicas instrumentais tendem a ter menos streams
SELECT
  classificacao_instrumentalness,
  ROUND(AVG(streams), 2) AS media_streams
FROM `validacaohipotesesprojeto002.spotify.variaveis_derivadas`
GROUP BY classificacao_instrumentalness
ORDER BY media_streams DESC;

--Classificação instrumentalness / média streams
--1 Baixa 516701804.45
--2 Média 401070198.45
--3 Alta 281466038.0

-- HIPÓTESE 5: Complexidade acústica impacta a performance
SELECT
  NTILE(4) OVER (ORDER BY streams_categoria_quartil_label) AS quartil_complexidade,
  ROUND(AVG(streams), 2) AS media_streams
FROM `validacaohipotesesprojeto002.spotify.variaveis_derivadas`
GROUP BY streams_categoria_quartil_label
ORDER BY streams_categoria_quartil_label;

--Quartil complexidade / média streams
--1 439608875.18
--2 84469345.89
--3 1326195973.15
--4 208694410.92

-- HIPÓTESE 6: Ano de lançamento impacta streams
SELECT
  ano_lancamento,
  COUNT(track_id) AS qtd_musicas,
  ROUND(AVG(streams), 2) AS media_streams
FROM `validacaohipotesesprojeto002.spotify.variaveis_derivadas`
GROUP BY ano_lancamento
ORDER BY ano_lancamento DESC;

--Ano lamçamento / qt musicas / média streams
--2023 175 147477052.02
--2022 398 287265102.89
--2021 118 623105287.89
--2020 37 937938698.84

-- HIPÓTESE 7: Mais músicas no catálogo = mais streams
SELECT
  artist_count,
  ROUND(AVG(streams), 2) AS media_streams
FROM `validacaohipotesesprojeto002.spotify.variaveis_derivadas`
GROUP BY artist_count
ORDER BY artist_count DESC;

--artist_count / media_streams
--8.0 173221173.5
--7.0 339060067.5
--6.0 87466453.0
--5.0 144808200.4
--4.0 306106246.47
--3.0 381342098.31
--2.0 463021846.48
--1.0 568540682.39

--Aplicar segmentação

CREATE OR REPLACE TABLE `validacaohipotesesprojeto002.spotify.variaveis_derivadas` AS

WITH total_por_artista AS (
  SELECT
    artist_s__name,
    COUNT(DISTINCT track_id) AS total_musicas_artista,
    SUM(SAFE_CAST(streams AS INT64)) AS total_streams_artista
  FROM
    `validacaohipotesesprojeto002.spotify.track_spotify_unificada`
  WHERE
    track_id != '0:00'
  GROUP BY
    artist_s__name
)

SELECT
  t.track_id,
  t.track_name,
  t.artist_s__name,
  t.artist_count,
  t.release_date,
  SAFE_CAST(t.streams AS INT64) AS streams,

  -- 🔢 Categorias de streams
  CASE
    WHEN t.quartil_streams = 1 THEN 'Baixo'
    WHEN t.quartil_streams = 2 THEN 'Médio'
    WHEN t.quartil_streams = 3 THEN 'Alto'
    WHEN t.quartil_streams = 4 THEN 'Muito Alto'
  END AS streams_categoria_quartil_label,

  -- 📅 Variáveis de tempo
  EXTRACT(YEAR FROM t.release_date) AS ano_lancamento,
  EXTRACT(MONTH FROM t.release_date) AS mes_lancamento,
  DATE_DIFF(CURRENT_DATE(), t.release_date, DAY) AS idade_musica_em_dias,
  SAFE_DIVIDE(SAFE_CAST(t.streams AS INT64), DATE_DIFF(CURRENT_DATE(), t.release_date, DAY)) AS streams_por_dia,

  -- 🎵 Faixas musicais
  t.bpm,
  CASE 
    WHEN t.bpm < 68 THEN 'Lento'
    WHEN t.bpm BETWEEN 68 AND 136 THEN 'Médio'
    ELSE 'Rápido'
  END AS faixa_bpm,

  t.danceability,
  CASE 
    WHEN t.danceability < 30 THEN 'Baixa'
    WHEN t.danceability BETWEEN 30 AND 60 THEN 'Média'
    ELSE 'Alta'
  END AS classificacao_danceability,

  t.valence,
  CASE 
    WHEN t.valence < 50 THEN 'Triste'
    ELSE 'Feliz'
  END AS emocional_valence,

  t.energy,
  CASE 
    WHEN t.energy < 30 THEN 'Suave'
    WHEN t.energy BETWEEN 30 AND 60 THEN 'Moderada'
    ELSE 'Alta'
  END AS classificacao_energy,

  t.acousticness,
  CASE 
    WHEN t.acousticness < 30 THEN 'Baixa'
    WHEN t.acousticness BETWEEN 30 AND 60 THEN 'Média'
    ELSE 'Alta'
  END AS classificacao_acousticness,

  t.instrumentalness,
  CASE 
    WHEN t.instrumentalness < 30 THEN 'Baixa'
    WHEN t.instrumentalness BETWEEN 30 AND 60 THEN 'Média'
    ELSE 'Alta'
  END AS classificacao_instrumentalness,

  t.liveness,
  CASE 
    WHEN t.liveness < 30 THEN 'Baixa'
    WHEN t.liveness BETWEEN 30 AND 60 THEN 'Média'
    ELSE 'Alta'
  END AS classificacao_liveness,

  t.speechiness,
  CASE 
    WHEN t.speechiness < 21 THEN 'Pouca fala'
    WHEN t.speechiness BETWEEN 21 AND 66 THEN 'Moderada'
    ELSE 'Muita fala'
  END AS classificacao_speechiness,

  -- 🎧 Perfil de complexidade sonora
  ROUND((t.acousticness + t.instrumentalness) / 2, 2) AS complexidade_acustica,

  -- 📣 Presença em plataformas
  t.in_apple_playlists,
  t.in_apple_charts,
  t.in_deezer_playlists,
  t.in_deezer_charts,
  t.in_shazam_charts,

  -- 🔥 Popularidade total
  (
    COALESCE(t.in_apple_playlists, 0) +
    COALESCE(t.in_deezer_playlists, 0)
  ) AS total_playlists,

  (
    COALESCE(t.in_apple_charts, 0) +
    COALESCE(t.in_deezer_charts, 0) +
    COALESCE(t.in_shazam_charts, 0)
  ) AS total_charts,

  (
    COALESCE(t.in_apple_playlists, 0) +
    COALESCE(t.in_deezer_playlists, 0) +
    COALESCE(t.in_apple_charts, 0) +
    COALESCE(t.in_deezer_charts, 0) +
    COALESCE(t.in_shazam_charts, 0)
  ) AS popularidade_geral,

  -- 🔁 Novos campos derivados por artista
  a.total_musicas_artista,
  a.total_streams_artista

FROM
  `validacaohipotesesprojeto002.spotify.track_spotify_unificada` t
LEFT JOIN
  total_por_artista a
ON
  t.artist_s__name = a.artist_s__name
WHERE
  t.track_id != '0:00'









