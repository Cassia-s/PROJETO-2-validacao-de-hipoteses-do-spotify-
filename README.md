# Projeto de Análise de Dados e validação de hipóteses Spotify

## Título: “O que faz uma música ter sucesso?’”

  <details>
  <summary><strong style="font-size: 16px;">Objetivo</strong></summary> 

Analisar dados do Spotify para validar hipóteses levantadas por uma gravadora sobre os fatores que influenciam o sucesso de uma música, com base no número de streams, e fornecer insights estratégicos para decisões de lançamento.

  </details>
  
  <details>
  <summary><strong style="font-size: 16px;">Equipe</strong></summary>
      
- Cassia Silva
- Vanessa Santana

  </details>
  
  <details>
  <summary><strong style="font-size: 16px;">Ferramentas e Tecnologias</strong></summary>
  
  - Power BI: gráficos, médias, medianas, dispersão e dashboards interativos
  - Python: histogramas e apoio à distribuição
  - BigQuery (SQL): agregações, quartis, correlações
  - Google Apresentação: criar apresentação final

  </details>
  
  <details>
  <summary><strong style="font-size: 16px;">Hipóteses Testadas</strong></summary>
  
1. Músicas com BPM mais alto geram mais streams.
2. Músicas populares no Spotify tendem a se comportar de forma semelhante em outras plataformas.
3. A presença em mais playlists está relacionada a um maior número de streams.
4. Artistas com mais músicas disponíveis tendem a ter mais streams.
5. As características técnicas da música influenciam diretamente o número de streams.

  </details>
  
  <details>
  <summary><strong style="font-size: 16px;">Processamento dos Dados</strong></summary>

## 📥 Processamento dos Dados

Descrição das etapas realizadas para preparar os dados para análise.

### 1. Importação da Base

Utilizamos o ambiente **Google BigQuery** para carregar as tabelas de dados.

- **Projeto BigQuery:** `validacaohipotesesprojeto02`
- **Dataset:** `spotify`
- **Tabelas importadas:**
    - `competition`
    - `technical_info`
    - `track_spotify`

### 2. Tratamento de Dados

As etapas de tratamento foram realizadas utilizando **SQL** dentro do ambiente Google BigQuery.

- **Dados Nulos:** Substituição de valores nulos (`IS NULL`, `COUNT`, e `COALESCE`). Exemplo: `in_shazam_charts` com nulos substituídos por 0.
  - `technical_info` foi encontrado 95 resultados nulos.
  - `track_spotify` foi encontrado 50 resultados nulos.
- **Dados Duplicados:** Foram identificados com `GROUP BY`, `COUNT(*)` e `HAVING COUNT(*) > 1` e tratados com média dos registros duplicados.
  - Na tabela `competition`, foram encontrados 4 resultados duplicados.
- **Exclusão de Variáveis Fora do Escopo:** Como `key` e `mode` com `SELECT EXCEPT`.
- **Correção de valores extremos:** track_id = '0:00' removido.
- **Padronização de Valores Textuais:** Uso de funções SQL como `REGEXP_REPLACE`, `UPPER` e `LOWER`.
- **Correção de Erros:** Um `track_id` com valor inválido de `streams` foi corrigido com base na média da variável.
- **Conversão de Tipos:** Uso da função SQL `SAFE_CAST` para transformar variáveis como `streams` de string para inteiro.

### 3. Criação de Novas Variáveis

Novas variáveis foram criadas utilizando **SQL** no Google BigQuery.

- release_date: concatenação de ano, mês e dia
- streams_por_dia: `SAFE_DIVIDE`(streams, idade_musica_em_dias)
- idade_musica_em_dias: `DATE_DIFF`(`CURRENT_DATE`(), `release_date`, `DAY`)
- complexidade_acustica: média entre acousticness e instrumentalness
- popularidade_geral: soma das presenças em todas as plataformas
- total_playlists: número de plataformas em que a faixa aparece (`CASE WHEN` + `COALESCE`)
- streams_categoria_quartil_label: categorizado por quartis usando `NTILE()`

### 4. Views Auxiliares

Views auxiliares foram criadas para organizar o processo de ETL e consolidar a base final, utilizando **SQL** no Google BigQuery.

- ´variaveis_streams_quartil´
- `track_spotify_unificada` (final consolidada com `LEFT JOIN`)
- Tabela final: ´variaveis_derivadas´ usando LEFT JOIN entre todas as bases.

View auxiliar: total_por_artista, com COUNT(DISTINCT track_id) e SUM(streams) por artista.

  </details>
  
  <details>
  <summary><strong style="font-size: 16px;">Análise Exploratória</strong></summary>

A análise exploratória foi realizada utilizando **Python** para algumas visualizações (como histogramas) e **SQL** para agregações, com a visualização final dos gráficos em **Power BI**.

### Análises Realizadas

- Distribuição de `streams` por artista e por ano.
- Médias e medianas de `streams` e presença em playlists.
- Histogramas com **Python**.
- Gráficos de linha e dispersão com **Power BI**.

### Quartis e Classificações Criadas

As variáveis numéricas foram categorizadas em quartis e classificações utilizando **SQL** no Google BigQuery, empregando funções como `PERCENTILE_CONT`, `CROSS JOIN` e `CASE WHEN`.

As classificações geradas para facilitar a análise categórica foram:

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

  </details>
  
  <details>
  <summary><strong style="font-size: 16px;">Validação das Hipóteses e Resultados</strong></summary>
      
A validação das hipóteses envolveu o cálculo de correlações (realizado via **SQL** ou **Python**) e a análise visual dos dados em **Power BI**.

### 📌 Hipótese 1: Músicas com BPM mais altas fazem mais sucesso

- **Correlação entre BPM e Streams:** `-0.0028` ❌ Hipótese refutada
- **Interpretação:** Não houve correlação significativa entre o número de BPMs de uma música e sua quantidade de streams. A hipótese não foi confirmada. Em contrapartida, o número de músicas por artista mostrou uma forte correlação com o desempenho, reforçando a relevância de manter um catálogo ativo.

### 📌 Hipótese 2: As músicas populares no Spotify também se destacam em outras plataformas

- **Correlação com Deezer:** `0.8264`  ✅ Confirmada
- **Correlação com Apple Music:** `0.7092`  ✅ Confirmada
- **Interpretação:** Há correlação forte, principalmente com o Apple Music, indicando que músicas bem-sucedidas no Spotify tendem a aparecer em playlists de outras plataformas. A hipótese foi confirmada.

### 📌 Hipótese 3: Músicas em mais playlists têm mais streams

- **Correlação com `total_playlists`:** `0.7832`  ✅ Confirmada
- **Interpretação:** Forte correlação positiva. Quanto mais playlists uma música está inserida, maior tende a ser o número de streams. A hipótese foi confirmada.

### 📌 Hipótese 4: Artistas com mais músicas têm mais streams

- **Correlação com `total_musicas_artista`:** `0.7786`  ✅ Confirmada
- **Interpretação:** Foi identificada uma correlação forte e positiva entre o número de músicas lançadas por um artista e o total de streams acumulados. Isso indica que artistas com maior volume de lançamentos tendem a obter mais streams, possivelmente devido à maior presença em plataformas e alcance de público. Essa evidência reforça que a constância e o volume de produção musical influenciam diretamente no sucesso em termos de audiência.

### 📌 Hipótese 5: Características técnicas influenciam o sucesso da música

- **Correlações:**
    - Valence: `-0.0496`
    - Danceability: `-0.1054`
    - Energy: `-0.0257`
- **Interpretação:** Embora as correlações individuais sejam fracas e negativas, a análise visual dos quartis e gráficos de dispersão no **Power BI** sugere uma tendência: músicas com maior danceability, positividade (valence) e energia tendem a ter um desempenho marginalmente melhor em streams. No entanto, essa relação não se confirma como uma correlação estatisticamente forte ou direta. Isso indica que essas características influenciam o sucesso musical de forma limitada, integrando um conjunto mais amplo de fatores, como marketing, inclusão em playlists e presença multiplataforma. A hipótese foi parcialmente confirmada, demonstrando que características técnicas contribuem para o sucesso, mas são secundárias em relação a fatores de visibilidade. Assim, recomenda-se considerar características técnicas em conjunto com estratégias de visibilidade e marketing. ✅ Parcialmente confirmada

  </details>
  
  <details>
  <summary><strong style="font-size: 16px;">Conclusão Geral</strong></summary>

Dos cinco principais pontos analisados, três hipóteses foram confirmadas. A inclusão em playlists e a popularidade em outras plataformas mostraram-se fortemente correlacionadas com o desempenho de streams das músicas. As variáveis técnicas exibiram uma influência moderada nesse desempenho, sugerindo um papel secundário. Em contrapartida, não foi observada uma relação direta entre o BPM ou o número de músicas por artista e o sucesso em streams.

  </details>
  
  <details>
  <summary><strong style="font-size: 16px;">Recomendações</strong></summary>

- Investir em estratégias para inclusão em playlists populares no Spotify, Apple Music e Deezer.
- Avaliar campanhas de marketing alinhadas a faixas com características técnicas já validadas como potencialmente mais populares (alta danceability, valence e energy).
- Explorar combinações de características técnicas com estratégias de visibilidade para maximizar o sucesso de lançamentos futuros.

  </details>
  
  <details>
  <summary><strong style="font-size: 16px;">Dashboard</strong></summary>
    
![Image](https://github.com/user-attachments/assets/92b29431-3e9f-4a17-8adc-bbdfdf91954e)

  </details>
  
  <details>
  <summary><strong style="font-size: 16px;">Links</strong></summary>

[Apresentação Google Slide](https://docs.google.com/presentation/d/1vzNds0b3ifMHkiMoM5ybMV7n6Hb_tPqs/edit?usp=sharing&ouid=117411998894801958154&rtpof=true&sd=true)

</details>
