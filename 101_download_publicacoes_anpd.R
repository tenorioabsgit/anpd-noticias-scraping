# Carregar os pacotes
library(rvest)
library(httr)

# Definir as URLs das páginas com os PDFs
urls <- c(
  "https://www.gov.br/anpd/pt-br/documentos-e-publicacoes",
  "https://www.gov.br/anpd/pt-br/composicao-1/coordenacao-geral-de-fiscalizacao/processos-administrativos-sancionadores",
  "https://www.gov.br/anpd/pt-br/documentos-e-publicacoes/planejamento-estrategico-anpd-2021-2023",
  "https://www.gov.br/anpd/pt-br/cnpd-2/documentos-e-publicacoes-do-cnpd/view"
)

# Criar uma pasta chamada publicacoes_anpd para salvar os PDFs
dir.create("publicacoes_anpd", showWarnings = FALSE)

# Função para baixar PDFs de uma URL
baixar_pdfs <- function(url) {
  # Ler o conteúdo da página
  webpage <- read_html(url)
  
  # Extrair todos os links que contêm PDFs
  pdf_links <- webpage %>%
    html_nodes("a") %>%
    html_attr("href") %>%
    grep("\\.pdf$", ., value = TRUE)
  
  # Completar os links, se forem relativos (adicionando o domínio)
  pdf_links <- ifelse(grepl("^http", pdf_links), pdf_links, paste0("https://www.gov.br", pdf_links))
  
  # Baixar todos os PDFs
  for (pdf_link in pdf_links) {
    # Extrair o nome do arquivo a partir do link
    file_name <- basename(pdf_link)
    
    # Baixar o arquivo e salvar na pasta publicacoes_anpd
    download.file(pdf_link, file.path("publicacoes_anpd", file_name), mode = "wb")
    
    # Informar o progresso
    cat("Baixado:", file_name, "de", url, "\n")
  }
}

# Loop para iterar sobre todas as URLs
for (url in urls) {
  cat("Processando:", url, "\n")
  baixar_pdfs(url)
}

cat("Download concluído!\n")
