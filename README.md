# 🔍 Projeto de Coleta e Processamento de Dados - ANPD & Google News

Este repositório contém scripts em **R** e **Python** para coleta, processamento e análise de dados relacionados à **Autoridade Nacional de Proteção de Dados (ANPD)** e ao **Google News**. O objetivo é realizar scraping de informações relevantes, armazená-las no BigQuery e conduzir análises avançadas, incluindo análise de sentimentos.

## 📂 Estrutura do Repositório

```
📁 /  (Diretório Raiz)
├── 000_main.R                     # Script principal de execução
├── 001_anpd_scraping_inicial.R     # Coleta inicial de dados da ANPD
├── 002_anpd_bigquery_inicial.R     # Criação da base inicial no BigQuery
├── 003_anpd_scraping_atualizacao.R # Atualização dos dados da ANPD
├── 004_anpd_bigquery_atualizacao.R # Atualização dos dados no BigQuery
├── 005_google_news_scraping_inicial.py  # Coleta inicial de notícias do Google News
├── 006_google_news_bigquery_inicial.R   # Armazena dados do Google News no BigQuery
├── 007_google_news_scraping_atualizacao.py # Atualização das notícias do Google News
├── 008_google_news_bigquery_atualizacao.R  # Atualização dos dados no BigQuery
├── 009_carga_bindrow_raw_inicial.R   # Processamento inicial de dados Bindrow
├── 010_carga_bindrow_raw_atualizacao.R # Atualização de dados Bindrow
├── 011_analise_sentimento.R # Análise de sentimentos nos dados coletados
├── 096_baixa_anexos_anpd.R  # Download de anexos da ANPD
├── 097_download_save_base_consolidada.R  # Consolidar base de dados coletada
├── 098_funcoes.R  # Funções auxiliares para automação
├── 099_instala_carrega_pacotes.R  # Instalação e carregamento de pacotes necessários
├── 100_rascunho.R  # Script auxiliar para testes e desenvolvimento
└── 101_download_publicacoes_anpd.R  # Download de publicações da ANPD
```

## 🚀 Tecnologias Utilizadas

- **R** 🟦 para processamento de dados e integração com **Google BigQuery**.
- **Python** 🐍 para **web scraping** e coleta de dados.
- **Google BigQuery** para armazenamento e processamento de dados.
- **APIs do Google News** para captura de notícias.

## 🔧 Como Executar

### 1️⃣ Configuração do Ambiente

Antes de rodar os scripts, certifique-se de que os pacotes necessários estão instalados. Utilize o script abaixo para configurar o ambiente em **R**:

```r
source("099_instala_carrega_pacotes.R")
```

Para Python, utilize:

```bash
pip install -r requirements.txt
```

### 2️⃣ Executando a Coleta de Dados

Para iniciar a coleta de dados da ANPD:

```r
source("001_anpd_scraping_inicial.R")
```

Para a coleta de dados do Google News:

```python
python 005_google_news_scraping_inicial.py
```

### 3️⃣ Processamento e Armazenamento no BigQuery

```r
source("002_anpd_bigquery_inicial.R")
source("006_google_news_bigquery_inicial.R")
```

### 4️⃣ Análises e Insights

Para análise de sentimentos:

```r
source("011_analise_sentimento.R")
```

## 📌 Próximos Passos

- [ ] Automatizar a execução dos scripts via **cron jobs** ou **Cloud Functions**.
- [ ] Implementar dashboards para visualização dos dados.
- [ ] Melhorar a eficiência dos scripts de scraping.

---

📢 **Mantenedores:**  
👤 **José Tenório Abs Junior**  
📧 Contato: [Seu Email]  

🛠️ **Colaboradores:**  
- Nome 1  
- Nome 2  
- Nome 3  
