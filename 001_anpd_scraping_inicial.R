library(rvest)
library(dplyr)

# URL base
base_url <- "https://www.gov.br/anpd/pt-br/assuntos/noticias"

# Gerar links das páginas de 1 a 14
pagination_urls <- c(base_url, paste0(base_url, "?b_start:int=", seq(30, 390, by = 30)))

# DataFrame para armazenar as notícias
all_news <- data.frame()

# Função para extrair os detalhes de uma notícia
extract_news_details <- function(link) {
  tryCatch({
    page <- read_html(link)
    
    # Extrair título
    titulo <- page %>%
      html_node(".documentFirstHeading") %>%
      html_text(trim = TRUE)
    
    # Extrair subtítulo
    subtitulo <- page %>%
      html_node(".documentDescription") %>%
      html_text(trim = TRUE)
    if (is.na(subtitulo)) subtitulo <- ""
    
    # Extrair data
    data <- page %>%
      html_node(".documentPublished") %>%
      html_text(trim = TRUE)
    if (is.na(data)) data <- ""
    
    # Extrair imagem
    imagem <- page %>%
      html_node("img") %>%
      html_attr("src")
    if (!is.na(imagem) && !startsWith(imagem, "http")) {
      imagem <- paste0("https://www.gov.br", imagem)
    }
    
    # Extrair conteúdo
    conteudo <- page %>%
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

# Iterar sobre as páginas de notícias
for (url in pagination_urls) {
  print(paste("Processando página:", url))
  page <- read_html(url)
  
  # Extrair links das notícias
  news_links <- page %>%
    html_nodes(".titulo a") %>%
    html_attr("href") %>%
    unique()
  news_links <- ifelse(startsWith(news_links, "http"), news_links, paste0("https://www.gov.br", news_links))
  
  # Extrair os detalhes das notícias
  page_news <- do.call(rbind, lapply(news_links, extract_news_details))
  all_news <- rbind(all_news, page_news)
}

# Limpeza de dados
all_news$data <- gsub("\\s+", " ", all_news$data)
all_news$data <- sub("Publicado em ", "", all_news$data)
all_news$data_formatada <- sub("Publicado em (\\d{2}/\\d{2}/\\d{4}).*", "\\1", all_news$data)
all_news$data_formatada <- format(as.Date(all_news$data_formatada, format = "%d/%m/%Y"), "%Y/%m/%d")

# Salvar em CSV
write.csv(all_news, paste0("noticias_anpd_completo_", Sys.Date(), ".csv"), row.names = FALSE)

print("Extração concluída com sucesso!")
