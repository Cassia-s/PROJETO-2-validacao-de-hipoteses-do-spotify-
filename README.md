# validacao-de-hipoteses-do-spotify-
Jornada na análise de dados do Spotify

# Título do Projeto: “O que faz uma música ter sucesso?’”

## Objetivo do Projeto

Analisar dados do Spotify para validar hipóteses levantadas por uma gravadora sobre os fatores que influenciam o sucesso de uma música, com base no número de streams, e fornecer insights estratégicos para decisões de lançamento.

## Equipe

- Cassia Silva
- Vanessa Santana

## Ferramentas e Tecnologias

- Google BigQuery
- SQL
- Power BI
- (Python)

## Hipóteses Testadas

1. Músicas com BPM mais alto geram mais streams.
2. Músicas populares no Spotify tendem a se comportar de forma semelhante em outras plataformas.
3. A presença em mais playlists está relacionada a um maior número de streams.
4. Artistas com mais músicas disponíveis tendem a ter mais streams.
5. As características técnicas da música influenciam diretamente o número de streams.

## Processamento dos Dados

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

- **Dados Nulos:** Substituição de valores nulos (`IS NULL`, `COUNT`). Exemplo: `in_shazam_charts` com nulos substituídos por 0. Foram encontrados 95 nulos em `technical_info` e 50 em `track_spotify`.
- **Dados Duplicados:** Identificados com `GROUP BY` + `HAVING COUNT(*) > 1` e tratados com a média dos registros duplicados. Foram encontrados 4 duplicados na tabela `competition`.
- **Exclusão de Variáveis Fora do Escopo:** Variáveis como `key` e `mode` foram removidas.
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

## Análise Exploratória

A análise exploratória foi realizada utilizando **Python** para algumas visualizações (como histogramas) e **SQL** para agregações, com a visualização final dos gráficos em **Power BI**.

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

## Validação das Hipóteses e Resultados

A validação das hipóteses envolveu o cálculo de correlações (realizado via **SQL** ou **Python**) e a análise visual dos dados em **Power BI**.

### 📌 Hipótese 1: Músicas com BPM mais altas fazem mais sucesso

- **Correlação entre BPM e Streams:** -0.0028
- **Interpretação:** Não houve correlação significativa. Hipótese não confirmada.

### 📌 Hipótese 2: As músicas populares no Spotify também se destacam em outras plataformas

- **Correlação com Deezer:** 0.5851
- **Correlação com Apple Music:** 0.7758
- **Interpretação:** Há correlação forte, principalmente com o Apple Music. Hipótese confirmada.

### 📌 Hipótese 3: Músicas em mais playlists têm mais streams

- **Correlação com `total_playlists`:** 0.6225
- **Interpretação:** Forte correlação positiva. Hipótese confirmada.

### 📌 Hipótese 4: Artistas com mais músicas têm mais streams

- **Correlação com `total_musicas_artista`:** 0,7787
- **Interpretação:** Correlação forte e positiva. Artistas com maior volume de lançamentos tendem a obter mais streams. Hipótese confirmada.

### 📌 Hipótese 5: Características técnicas influenciam o sucesso da música

- **Correlações:**
    - Valence: -0.0411
    - Danceability: -0.1055
    - Energy: -0.0256
- **Interpretação:** Embora correlações individuais fracas, análise visual em **Power BI** sugere que maior danceability, positividade e energia tendem a ter desempenho marginalmente melhor. Relação não é estatisticamente forte ou direta. Hipótese parcialmente confirmada, indicando influência limitada.

## Conclusão Geral

Dos cinco pontos analisados, três hipóteses foram confirmadas (popularidade em outras plataformas, inclusão em playlists e número de músicas por artista). Variáveis técnicas têm influência moderada. Não há relação direta entre BPM e sucesso em streams.

## Recomendações

- Investir em estratégias para inclusão em playlists populares no Spotify, Apple Music e Deezer.
- Avaliar campanhas de marketing alinhadas a faixas com características técnicas potencialmente mais populares (alta danceability, valence e energy).
- Explorar combinações de características técnicas com estratégias de visibilidade.

## Arquivos e Documentos

- **Dataset:** Disponível no Google BigQuery (detalhes para acesso, se possível).
- **Power BI:** Arquivo com dashboards interativos (`visualizations/power_bi/seu_dashboard.pbix`).

---

Agora você pode copiar este texto e utilizá-lo para o seu arquivo `README.md` no GitHub, dentro da estrutura de pastas que definimos anteriormente. Lembre-se de adicionar seus arquivos `.sql` e `.py` nas pastas correspondentes e o arquivo `.pbix` na pasta `visualizations/power_bi/`.
