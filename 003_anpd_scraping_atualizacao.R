# Carregar os pacotes necessários
library(rvest)
library(dplyr)

url <- "https://www.gov.br/anpd/pt-br/assuntos/noticias"

# Leitura do conteúdo da página principal
pagina <- read_html(url)

# Extração dos links das notícias
links <- pagina %>%
  html_nodes(".titulo a") %>%
  html_attr("href")

# Adiciona a parte inicial do link, se necessário
base_url <- "https://www.gov.br"
links <- ifelse(startsWith(links, "http"), links, paste0(base_url, links))

# Função para extrair os detalhes de uma notícia
extrair_detalhes <- function(link) {
  tryCatch({
    noticia_pagina <- read_html(link)
    
    # Extrair título
    titulo <- noticia_pagina %>%
      html_node(".documentFirstHeading") %>%
      html_text(trim = TRUE)
    
    # Extrair subtítulo (se existir)
    subtitulo <- noticia_pagina %>%
      html_node(".documentDescription") %>%
      html_text(trim = TRUE)
    if (is.na(subtitulo)) subtitulo <- ""
    
    # Extrair data (se existir)
    data <- noticia_pagina %>%
      html_node(".documentPublished") %>%
      html_text(trim = TRUE)
    if (is.na(data)) data <- ""
    
    # Extrair imagem (se existir)
    imagem <- noticia_pagina %>%
      html_node("img") %>%
      html_attr("src")
    if (!is.na(imagem) && !startsWith(imagem, "http")) {
      imagem <- paste0("https://www.gov.br", imagem)
    }
    
    # Extrair conteúdo
    conteudo <- noticia_pagina %>%
      html_nodes('div[property="rnews:articleBody"] p') %>%
      html_text(trim = TRUE) %>%
      paste(collapse = "\n")
    
    return(data.frame(
      titulo = titulo,
      subtitulo = subtitulo,
      data = data,
      conteudo = conteudo,
      imagem = imagem,
      link = link,
      stringsAsFactors = FALSE
    ))
  }, error = function(e) {
    return(data.frame(
      titulo = NA,
      subtitulo = NA,
      data = NA,
      conteudo = NA,
      imagem = NA,
      link = link,
      stringsAsFactors = FALSE
    ))
  })
}

# Iterar sobre os links e extrair os detalhes de cada notícia
df_final <- do.call(rbind, lapply(links, extrair_detalhes))

df_final$data <- gsub("\\s+", " ", df_final$data) %>% sub("Publicado em ", "Publicado em ", .) %>% sub(" ([0-9]{2}/[0-9]{2}/[0-9]{4}) ([0-9]{2}h[0-9]{2})", " \\1 às \\2min", .)
# Extrair apenas a parte da data
df_final$data_formatada <- sub("Publicado em (\\d{2}/\\d{2}/\\d{4}).*", "\\1", df_final$data)
# Converter para o formato desejado
df_final$data_formatada <- format(as.Date(df_final$data_formatada, format="%d/%m/%Y"), "%Y/%m/%d")


