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

if(nrow(df_final)>0){
  tablename <- "noticias_anpd"
  
  df_final <- df_final %>% mutate_all(as.character)
  
  bigrquery::dbWriteTable(con, tablename, df_final, append=F, verbose = T, row.names=F, overwrite=T, fields=df_final)
  print("Dataframe Ocorrencias Uploaded")
}
