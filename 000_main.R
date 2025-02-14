library(reticulate)
options(warn = -1)
rm(list = ls())

## carrega scripts de pacotes e funções
source('099_instala_carrega_pacotes.R')
source("098_funcoes.R")

## captura datas maximas atuais das bases raws
data_maxima_anpd <- data_maxima_anpd_antes_atualizacao()
data_maxima_anpd
data_maxima_google_news <- data_maxima_google_news_antes_atualizacao()
data_maxima_google_news

## atualiza as bases raws
source("003_anpd_scraping_atualizacao.R")
source("004_anpd_bigquery_atualizacao.R")
system("C:/Users/tenor/AppData/Local/Programs/Python/Python310/python.exe 007_google_news_scraping_atualizacao.py")
source("008_google_news_bigquery_atualizacao.R")

## atualiza base merged
source("010_carga_bindrow_raw_atualizacao.R")

lista_csvs <- list.files(path = "csvs/", all.files = T, full.names = T, recursive = T)
file.remove(lista_csvs)

source("097_download_save_base_consolidada.R")




