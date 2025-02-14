#carregando uma variável com o nome dos arquivos csv
lista_csvs_google_news <- list.files(path = "csvs/", pattern = "*.csv", full.names = TRUE)

#unindo todos os datasets
df_google_news_unico <- ldply(lista_csvs_google_news, read.csv)
df_google_news_unico <- clean_names(df_google_news_unico)
df_google_news_unico$data_formatada <- lubridate::dmy_hms(df_google_news_unico$published_date, tz = "GMT")
df_google_news_unico$data_formatada <- format(df_google_news_unico$data_formatada, "%Y/%m/%d")


#devtools::install_github("r-dbi/bigrquery")

library(bigrquery)
library(DBI)
library(httr)

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

if(nrow(df_google_news_unico)>0){
  tablename <- "noticias_google_news"
  df_google_news_unico <- df_google_news_unico %>% mutate_all(as.character)
  bigrquery::dbWriteTable(con, tablename, df_google_news_unico, append=T, verbose = T, row.names=F, overwrite=F, fields=df_google_news_unico)
  print("Dataframe Ocorrencias Uploaded")
}

sql <- ("CREATE OR REPLACE TABLE
`noticias-423520.noticias.noticias_google_news` AS 
SELECT *
FROM 
    `noticias-423520.noticias.noticias_google_news`
ORDER BY
    published_date DESC
")
invisible(capture.output(dbSendQuery(con,sql)))

