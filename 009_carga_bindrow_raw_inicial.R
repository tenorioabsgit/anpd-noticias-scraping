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

sql <- "SELECT * FROM `noticias-423520.noticias.noticias_anpd`"
# Executar a query
query_job <- bq_project_query("noticias-423520", sql)
# Obter os resultados da query
df_raw_anpd <- bq_table_download(query_job)

sql <- "SELECT * FROM `noticias-423520.noticias.noticias_google_news`"
query_job <- bq_project_query("noticias-423520", sql)
df_raw_google_news <- bq_table_download(query_job, page_size = 100)

df_raw_anpd <- df_raw_anpd[,c(1,2,4,7)]
df_raw_google_news <- df_raw_google_news[,c(1,2,9,10,8)]

df_raw_anpd$publicador_nome <- "gov.br"

df_raw_google_news <- df_raw_google_news %>% 
  dplyr::rename(
    titulo = title,
    subtitulo = description
  )

source("098_funcoes.R")
#df_raw_anpd <- aplica_regex(df_raw_anpd, termos)
#df_raw_google_news <- aplica_regex(df_raw_google_news, termos)

df_tratada <- rbind(df_raw_anpd, df_raw_google_news)

df_tratada <- analisa_sentimento(df_tratada)

if(nrow(df_tratada)>0){
  tablename <- "noticias_consolidado"
  #df_google_news_unico <- df_google_news_unico %>% mutate_all(as.character)
  bigrquery::dbWriteTable(con, tablename, df_tratada, append=F, verbose = T, row.names=F, overwrite=T, fields=df_tratada)
  print("Dataframe Ocorrencias Uploaded")
}

sql <- ("CREATE OR REPLACE TABLE
`noticias-423520.noticias.noticias_consolidado` AS 
SELECT *
FROM 
    `noticias-423520.noticias.noticias_consolidado`
ORDER BY
    data_formatada DESC
")
invisible(capture.output(dbSendQuery(con,sql)))




