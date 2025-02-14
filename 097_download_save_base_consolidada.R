# Carregar a biblioteca necessária
library(dplyr)

# Carregar um dataframe grande a partir de um arquivo CSV
# Substitua "caminho/para/seu/arquivo.csv" pelo caminho real do seu arquivo CSV
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

sql <- "SELECT *
FROM 
    `noticias-423520.noticias.noticias_consolidado`
ORDER BY
    data_formatada DESC"
# Executar a query
query_job <- bq_project_query("noticias-423520", sql)
# Obter os resultados da query
df <- bq_table_download(query_job, page_size = 100)


# Obter a lista de termos únicos na coluna 'termo_pesquisado'
termos <- unique(df$termo_pesquisado)

# Loop para filtrar e salvar arquivos CSV
for (termo in termos) {
  # Filtrar o dataframe pelo termo
  df_filtrado <- df %>% filter(termo_pesquisado == termo)
  
  # Gerar o nome do arquivo
  nome_arquivo <- paste0("bases_tratadas/", termo, ".csv")
  
  # Salvar o dataframe filtrado em um arquivo CSV
  write.csv(df_filtrado, nome_arquivo, row.names = FALSE)
}

df_consolidado <- df %>% distinct()
# df_consolidado <- df_consolidado[,c(1,3,4,6)]
write.csv(df_consolidado, "df_consolidado.csv")


