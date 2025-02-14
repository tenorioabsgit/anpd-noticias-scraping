captura_volume_noticias <- function(){

  # Instalando o pacote bigrquery a partir do GitHub
  # devtools::install_github("r-dbi/bigrquery")
  
  library(bigrquery)
  library(DBI)
  library(httr)
  
  # Configurando httr para evitar problemas de SSL e versão HTTP
  httr::set_config(httr::config(ssl_verifypeer = 0L))
  httr::set_config(httr::config(http_version = 0))
  options(httr_oob_default = TRUE)
  
  # Autenticando no BigQuery
  bigrquery::bq_auth(path = "noticias-423520-b345720d776b.json")
  
  # Definindo o projeto de billing
  billing <- "noticias-423520"
  
  # Conectando ao BigQuery
  con <- dbConnect(
    bigrquery::bigquery(),
    project = "noticias-423520",
    dataset = "noticias",
    billing = billing
  )
  
  # Escrevendo a consulta SQL
  sql <- "SELECT COUNT(*) AS total_registros FROM `noticias-423520.noticias.noticias_anpd`"
  
  # Enviando a consulta para o BigQuery
  result <- dbGetQuery(con, sql)
  result <- result$total_registros[1]
}

# Carregar a biblioteca necessária
library(dplyr)
library(tidyr)

# Definir os termos a serem buscados
termos <- c('ANPD',
            'GDPR',
            'LGPD',
            'Vazamento de Dados'
            )

# Criar uma função para buscar os termos e duplicar as linhas conforme necessário
aplica_regex <- function(df, termos) {
  # Inicializar um dataframe vazio para armazenar os resultados
  df_result <- data.frame()
  
  # Iterar sobre cada linha do dataframe
  for (i in 1:nrow(df)) {
    print(paste0("Analisando linha ", i, " de ", nrow(df)))
    linha <- df[i, ]
    conteudo <- linha$conteudo
    termos_encontrados <- termos[sapply(termos, function(t) grepl(t, conteudo))]
    
    if (length(termos_encontrados) > 0) {
      linhas_duplicadas <- linha[rep(1, length(termos_encontrados)), ]
      linhas_duplicadas$termo_pesquisado <- termos_encontrados
      df_result <- rbind(df_result, linhas_duplicadas)
    }
  }
  return(df_result)
}

data_maxima_anpd_antes_atualizacao <- function(){
  #devtools::install_github("r-dbi/bigrquery")
  
  library(bigrquery)
  library(DBI)
  library(httr)
  library(plyr)
  library(tidyverse)
  
  httr::set_config(httr::config(ssl_verifypeer = 0L))
  httr::set_config(httr::config(http_version = 0))
  options(httr_oob_default = TRUE)
  
  bigrquery::bq_auth(path = "noticias-423520-b345720d776b.json")
  
  billing <- "noticias-423520"
  
  library(DBI)
  
  con <- dbConnect(
    bigrquery::bigquery(),
    project = "noticias-423520",
    dataset = "noticias",
    billing = billing
  )
  con
  
  sql <- "SELECT MAX(data_formatada) as data_formatada FROM `noticias-423520.noticias.noticias_anpd`"
  # Executar a query
  query_job <- bq_project_query("noticias-423520", sql)
  # Obter os resultados da query
  data_formatada <- bq_table_download(query_job)
  data_formatada <- data_formatada$data_formatada
  return(data_formatada)
}

data_maxima_google_news_antes_atualizacao <- function(){
  #devtools::install_github("r-dbi/bigrquery")
  
  library(bigrquery)
  library(DBI)
  library(httr)
  library(plyr)
  library(tidyverse)
  
  httr::set_config(httr::config(ssl_verifypeer = 0L))
  httr::set_config(httr::config(http_version = 0))
  options(httr_oob_default = TRUE)
  
  bigrquery::bq_auth(path = "noticias-423520-b345720d776b.json")
  
  billing <- "noticias-423520"
  
  library(DBI)
  
  con <- dbConnect(
    bigrquery::bigquery(),
    project = "noticias-423520",
    dataset = "noticias",
    billing = billing
  )
  con
  
  sql <- "SELECT MAX(data_formatada) as data_formatada FROM `noticias-423520.noticias.noticias_google_news`"
  # Executar a query
  query_job <- bq_project_query("noticias-423520", sql)
  # Obter os resultados da query
  data_formatada <- bq_table_download(query_job)
  data_formatada <- data_formatada$data_formatada
  return(data_formatada)
}


analisa_sentimento <- function(df){
  
  library(dplyr)
  library(stringr)
  
  # Listas expandidas de palavras positivas e negativas
  positive_words <- c("bom", "ótimo", "excelente", "positivo", "seguro", "confiável", "satisfatório", "melhoria", "sucesso", "progresso",
                      "compliance", "conformidade", "transparente", "confidencialidade", "eficácia", "protegido", "segurança")
  negative_words <- c("vazamento", "ruim", "péssimo", "negativo", "inseguro", "falha", "ameaça", "risco", "problema", "vulnerabilidade",
                      "violação", "exposição", "brecha", "roubo", "desprotegido", "ataque", "fraude")
  
  # Função para pré-processar texto
  preprocess <- function(text) {
    text <- tolower(text)
    text <- str_replace_all(text, "\\W", " ")
    return(text)
  }
  
  # Função para análise de sentimento
  custom_sentiment_analysis <- function(text) {
    words <- str_split(text, " ")[[1]]
    pos_score <- sum(words %in% positive_words)
    neg_score <- sum(words %in% negative_words)
    sentiment_score <- pos_score - neg_score
    return(sentiment_score)
  }
  
  # Função para categorizar sentimento
  categorize_sentiment <- function(score) {
    if (score > 0) {
      return('Positivo')
    } else if (score < 0) {
      return('Negativo')
    } else {
      return('Neutro')
    }
  }
  
  # Aplicar pré-processamento e análise de sentimento
  df$cleaned_conteudo <- sapply(df$conteudo, preprocess)
  df$sentiment_score <- sapply(df$cleaned_conteudo, custom_sentiment_analysis)
  df$sentiment <- sapply(df$sentiment_score, categorize_sentiment)
  
  return(df)
}


