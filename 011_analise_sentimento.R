# Carregar bibliotecas necessárias
library(dplyr)
library(stringr)
library(lexiconPT)

# Carregar os léxicos do pacote lexiconPT
data("oplexicon_v3.0")

# Verificar as primeiras entradas do léxico
head(oplexicon_v3.0)

# Função para pré-processar texto
preprocess <- function(text) {
  text <- tolower(text)
  text <- str_replace_all(text, "\\W", " ")
  return(text)
}

# Função para análise de sentimento usando oplexicon_v3.0
custom_sentiment_analysis <- function(text) {
  words <- str_split(text, " ")[[1]]
  
  # Depuração: Imprimir algumas palavras do texto
  print(head(words, 10))
  
  pos_words <- words %in% oplexicon_v3.0$term[oplexicon_v3.0$polarity == 1]
  neg_words <- words %in% oplexicon_v3.0$term[oplexicon_v3.0$polarity == -1]
  
  pos_score <- sum(pos_words)
  neg_score <- sum(neg_words)
  
  # Depuração: Imprimir pontuações de sentimento
  print(paste("Positive score:", pos_score, "Negative score:", neg_score))
  
  sentiment_score <- pos_score - neg_score
  return(sentiment_score)
}

# Função para categorizar sentimento
categorize_sentiment <- function(score) {
  if (score > 0) {
    return('Positivo')
  } else if (score < 0) {
    return('Negativo')
  } else {
    return('Neutro')
  }
}

# Carregar dados
df <- read.csv('df_consolidado.csv', stringsAsFactors = FALSE)

# Aplicar pré-processamento e análise de sentimento
df$cleaned_conteudo <- sapply(df$conteudo, preprocess)
df$sentiment_score <- sapply(df$cleaned_conteudo, custom_sentiment_analysis)
df$sentiment <- sapply(df$sentiment_score, categorize_sentiment)

# Resumo dos sentimentos
sentiment_counts <- df %>% count(sentiment)
print(sentiment_counts)
