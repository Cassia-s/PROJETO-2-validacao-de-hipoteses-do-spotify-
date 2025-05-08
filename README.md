# validacao-de-hipoteses-do-spotify-
Jornada na análise de dados do Spotify

# Ficha Técnica: Projeto de Análise de Dados do Spotify

## Título do Projeto

“O que faz uma música ter sucesso?’”

## Objetivo

Analisar dados do Spotify para validar hipóteses levantadas por uma gravadora sobre os fatores que influenciam o sucesso de uma música, com base no número de streams, e fornecer insights estratégicos para decisões de lançamento.

## Equipe

- Cassia Silva
- Vanessa Santana

## Ferramentas e Tecnologias

- Google BigQuery
- SQL
- Power BI
- Python

## Hipóteses Testadas

1. Músicas com BPM mais alto geram mais streams.
2. Músicas populares no Spotify tendem a se comportar de forma semelhante em outras plataformas.
3. A presença em mais playlists está relacionada a um maior número de streams.
4. Artistas com mais músicas disponíveis tendem a ter mais streams.
5. As características técnicas da música influenciam diretamente o número de streams.

## 📥 Processamento dos Dados

Descrição das etapas realizadas para preparar os dados para análise.

### 1. Importação da Base

Utilizamos o ambiente **Google BigQuery** para carregar as tabelas de dados.

- **Projeto BigQuery:** `validacaohipotesesprojeto02`
- **Dataset:** `spotify`
- **Tabelas carregadas:**
    - `competition`
    - `technical_info`
    - `track_spotify`

### 2. Tratamento de Dados

As etapas de tratamento foram realizadas utilizando **SQL** dentro do ambiente Google BigQuery.

- **Dados Nulos:** Substituição de valores nulos (`IS NULL`, `COUNT`). Exemplo: `in_shazam_charts` com nulos substituídos por 0.
  - `technical_info` foi encontrado 95 resultados nulos.
  - `track_spotify` foi encontrado 50 resultados nulos.
- **Dados Duplicados:** Foram identificados com `GROUP BY` + `HAVING COUNT(*) > 1` e tratados com média dos registros duplicados.
  - Na tabela `competition`, foram encontrados 4 resultados duplicados.
- **Exclusão de Variáveis Fora do Escopo:** Como `key` e `mode`.
- **Padronização de Valores Textuais:** Uso de funções SQL como `REGEXP_REPLACE`, `UPPER` e `LOWER`.
- **Correção de Erros:** Um `track_id` com valor inválido de `streams` foi corrigido com base na média da variável.
- **Conversão de Tipos:** Uso da função SQL `SAFE_CAST` para transformar variáveis como `streams` de string para inteiro.

### 3. Criação de Novas Variáveis

Novas variáveis foram criadas utilizando **SQL** no Google BigQuery.

- `release_date` = `DATE(CONCAT(year, '-', month, '-', day))`
- `total_playlists` = soma das playlists nas plataformas Spotify, Deezer e Apple Music

### 4. Views Auxiliares

Views auxiliares foram criadas para organizar o processo de ETL e consolidar a base final, utilizando **SQL** no Google BigQuery.

- `competition_nova`
- `technical_info_nova`
- `track_spotify_nova`
- `base_unificada` (final consolidada com `LEFT JOIN`)
- `total_artista` (view auxiliar para contabilizar músicas por artista)

## 🔍 Análise Exploratória

A análise exploratória foi realizada utilizando **Python** para algumas visualizações (como histogramas) e **SQL** para agregações, com a visualização final dos gráficos em **Power BI**.

### Análises Realizadas

- Distribuição de `streams` por artista e por ano.
- Médias e medianas de `streams` e presença em playlists.
- Histogramas com **Python**.
- Gráficos de linha e dispersão com **Power BI**.

### Quartis e Classificações Criadas

As variáveis numéricas foram categorizadas em quartis e classificações utilizando **SQL** no Google BigQuery, empregando funções como `PERCENTILE_CONT`, `CROSS JOIN` e `CASE WHEN`.

| Variável           | Classificação (Quartil)        |
| :----------------- | :----------------------------- |
| `streams_corrigido` | "Muito baixo, Baixo, Alto, Muito alto" |
| `bpm`              | "Lento, Médio, Rápido"         |
| `danceability`     | "Baixa, Média, Alta"           |
| `valence`          | "Triste, Feliz"                |
| `energy`           | "Suave, Moderada, Alta"        |
| `acousticness`     | "Baixa, Média, Alta"           |
| `instrumentalness` | "Baixa, Média, Alta"           |
| `liveness`         | "Baixa, Média, Alta"           |
| `speechiness`      | "Fala pouco, Moderada, Fala muito" |

Essas variáveis de classificação foram criadas com `CASE WHEN` + `PERCENTILE_CONT`, possibilitando uma análise categórica mais visual e comparativa no Power BI.

## 📊 Validação das Hipóteses e Resultados

A validação das hipóteses envolveu o cálculo de correlações (realizado via **SQL** ou **Python**) e a análise visual dos dados em **Power BI**.

### 📌 Hipótese 1: Músicas com BPM mais altas fazem mais sucesso

- **Correlação entre BPM e Streams:** `-0.0028`
- **Interpretação:** Não houve correlação significativa entre o número de BPMs de uma música e sua quantidade de streams. A hipótese não foi confirmada.

### 📌 Hipótese 2: As músicas populares no Spotify também se destacam em outras plataformas

- **Correlação com Deezer:** `0.5851`
- **Correlação com Apple Music:** `0.7758`
- **Interpretação:** Há correlação forte, principalmente com o Apple Music, indicando que músicas bem-sucedidas no Spotify tendem a aparecer em playlists de outras plataformas. A hipótese foi confirmada.

### 📌 Hipótese 3: Músicas em mais playlists têm mais streams

- **Correlação com `total_playlists`:** `0.6225`
- **Interpretação:** Forte correlação positiva. Quanto mais playlists uma música está inserida, maior tende a ser o número de streams. A hipótese foi confirmada.

### 📌 Hipótese 4: Artistas com mais músicas têm mais streams

- **Correlação com `total_musicas_artista`:** `0.7787`
- **Interpretação:** Foi identificada uma correlação forte e positiva entre o número de músicas lançadas por um artista e o total de streams acumulados. Isso indica que artistas com maior volume de lançamentos tendem a obter mais streams, possivelmente devido à maior presença em plataformas e alcance de público. Essa evidência reforça que a constância e o volume de produção musical influenciam diretamente no sucesso em termos de audiência.

### 📌 Hipótese 5: Características técnicas influenciam o sucesso da música

- **Correlações:**
    - Valence: `-0.0411`
    - Danceability: `-0.1055`
    - Energy: `-0.0256`
- **Interpretação:** Embora as correlações individuais sejam fracas e negativas, a análise visual dos quartis e gráficos de dispersão no **Power BI** sugere uma tendência: músicas com maior danceability, positividade (valence) e energia tendem a ter um desempenho marginalmente melhor em streams. No entanto, essa relação não se confirma como uma correlação estatisticamente forte ou direta. Isso indica que essas características influenciam o sucesso musical de forma limitada, integrando um conjunto mais amplo de fatores, como marketing, inclusão em playlists e presença multiplataforma. A hipótese foi parcialmente confirmada, demonstrando que características técnicas contribuem para o sucesso, mas são secundárias em relação a fatores de visibilidade.

## 💡 Conclusão Geral

Dos cinco principais pontos analisados, três hipóteses foram confirmadas. A inclusão em playlists e a popularidade em outras plataformas mostraram-se fortemente correlacionadas com o desempenho de streams das músicas. As variáveis técnicas exibiram uma influência moderada nesse desempenho, sugerindo um papel secundário. Em contrapartida, não foi observada uma relação direta entre o BPM ou o número de músicas por artista e o sucesso em streams.

## 🎯 Recomendações

- Investir em estratégias para inclusão em playlists populares no Spotify, Apple Music e Deezer.
- Avaliar campanhas de marketing alinhadas a faixas com características técnicas já validadas como potencialmente mais populares (alta danceability, valence e energy).
- Explorar combinações de características técnicas com estratégias de visibilidade para maximizar o sucesso de lançamentos futuros.

## Arquivos e Documentos

- **Dataset:** Disponível no Google BigQuery.
- **Power BI:** Arquivo com dashboards interativos que mostram as análises, filtros por classificações e correlações 
