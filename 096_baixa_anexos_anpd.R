# Carrega as bibliotecas necessárias
library(rvest)
library(httr)
library(stringr)

# Define a URL alvo
url <- "https://www.gov.br/anpd/pt-br/documentos-e-publicacoes"

# Cria diretório para PDFs se não existir
if (!dir.exists("pdf")) {
  dir.create("pdf")
}

# Função para baixar PDF
download_pdf <- function(pdf_url, filename) {
  tryCatch({
    response <- GET(pdf_url, write_disk(paste0("pdf/", filename), overwrite = TRUE))
    if (http_status(response)$category == "Success") {
      cat("Download concluído:", filename, "\n")
    }
  }, error = function(e) {
    cat("Erro ao baixar:", filename, "\n")
  })
}

# Lê a página
webpage <- read_html(url)

# Encontra todos os links
links <- webpage %>% 
  html_nodes("a") %>% 
  html_attr("href")

# Filtra apenas links PDF
pdf_links <- links[str_detect(links, "\\.pdf$")]

# Remove duplicatas
pdf_links <- unique(pdf_links)

# Processa cada link PDF
for (pdf_url in pdf_links) {
  # Extrai nome do arquivo do URL
  filename <- basename(pdf_url)
  
  # Se o link for relativo, adiciona o domínio base
  if (!grepl("^http", pdf_url)) {
    pdf_url <- paste0("https://www.gov.br", pdf_url)
  }
  
  # Baixa o PDF
  download_pdf(pdf_url, filename)
  
  # Pequena pausa para não sobrecarregar o servidor
  Sys.sleep(1)
}

# Verifica se existem arquivos para juntar
if (length(arquivos_pdf) > 0) {
  # Nome do arquivo de saída
  arquivo_saida <- file.path(pasta_pdf, "documento_unificado.pdf")
  
  # Junta os PDFs usando pdf_combine do pdftools
  tryCatch({
    pdf_combine(arquivos_pdf, output = arquivo_saida)
    cat("PDFs unidos com sucesso em:", arquivo_saida, "\n")
  }, error = function(e) {
    cat("Erro ao unir PDFs:", e$message, "\n")
  })
} else {
  cat("Nenhum arquivo PDF encontrado na pasta.\n")
}