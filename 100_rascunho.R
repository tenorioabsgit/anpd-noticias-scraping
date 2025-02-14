# Carregar a biblioteca necessária
library(dplyr)

# Carregar um dataframe grande a partir de um arquivo CSV
# Substitua "caminho/para/seu/arquivo.csv" pelo caminho real do seu arquivo CSV
df <- fread("df_consolidado.csv")

# Supondo que seu dataframe se chame 'df'
# Criar a pasta 'bases_tratadas' se ela não existir
if (!dir.exists("bases_tratadas")) {
  dir.create("bases_tratadas")
}

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



