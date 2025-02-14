import os
import pandas as pd
from gnews import GNews
from datetime import datetime, timedelta
import time
import ast

def set_working_directory():
    script_directory = os.path.dirname(os.path.abspath(__file__))
    os.chdir(script_directory)
    current_directory = os.getcwd()
    print("Diretório de trabalho atual:", current_directory)

def process_date_range(data_inicio, data_fim):
    data_obj_inicio = datetime.strptime(data_inicio, '%d/%m/%Y')
    data_obj_fim = datetime.strptime(data_fim, '%d/%m/%Y')
    return data_obj_inicio, data_obj_fim

def fetch_news(palavra_chave, data_obj_inicio, data_obj_fim):
    list_news_df = []
    iteration_count = 0
    while data_obj_inicio <= data_obj_fim:
        data_obj_final = calculate_end_of_month(data_obj_inicio)
        if data_obj_final > data_obj_fim:
            data_obj_final = data_obj_fim

        print(f"Processando notícias do período: {data_obj_inicio.strftime('%Y-%m-%d')} até {data_obj_final.strftime('%Y-%m-%d')} com a palavra-chave: '{palavra_chave}'")
        news = get_news_for_period(palavra_chave, data_obj_inicio, data_obj_final)
        if news:
            df = pd.DataFrame(news)
            df['termo_pesquisado'] = palavra_chave
            df = extract_publisher_info(df) 
            list_news_df.append(df)
            print(f"\033[32mEncontradas {len(news)} notícias para o período {data_obj_inicio.strftime('%Y-%m-%d')} até {data_obj_final.strftime('%Y-%m-%d')}\033[0m.")
        else:
            print(f"\033[31mNenhuma notícia encontrada para o período {data_obj_inicio.strftime('%Y-%m-%d')} até {data_obj_final.strftime('%Y-%m-%d')}\033[0m.")

        data_obj_inicio = increment_date(data_obj_inicio)
        iteration_count += 1
        if iteration_count % 30 == 0:
            print("Pausando para evitar limitações de taxa de solicitação...")
            time.sleep(3)

    return list_news_df

def extract_publisher_info(df):
    def parse_publisher(publisher_str):
        try:
            publisher_dict = ast.literal_eval(publisher_str)
            return publisher_dict.get('href', 'NaN'), publisher_dict.get('title', 'NaN')
        except (ValueError, SyntaxError, TypeError):
            return 'NaN', 'NaN'

    df[['publicador_url', 'publicador_nome']] = df['publisher'].astype(str).apply(parse_publisher).tolist()
    return df

def calculate_end_of_month(data_obj):
    next_month = data_obj.replace(day=28) + timedelta(days=4)
    return next_month - timedelta(days=next_month.day)

def get_news_for_period(palavra_chave, data_obj_inicio, data_obj_final):
    google_news = GNews(language='pt-419', country='BR',
                        start_date=(data_obj_inicio.year, data_obj_inicio.month, data_obj_inicio.day),
                        end_date=(data_obj_final.year, data_obj_final.month, data_obj_final.day),
                        max_results=100, exclude_websites=['yahoo.com', 'cnn.com'])
    try:
        return google_news.get_news(palavra_chave)
    except Exception as e:
        print(f"Erro ao buscar notícias: {e}")
        return []

def increment_date(data_obj):
    next_month = data_obj.replace(day=28) + timedelta(days=4)
    return next_month.replace(day=1)

def concatenate_news(list_news_df):
    if list_news_df:
        return pd.concat(list_news_df, ignore_index=True)
    else:
        print("Não foram encontradas notícias para concatenar.")
        return pd.DataFrame()

def process_news_data(final_news_df):
    #final_news_df['published date'] = pd.to_datetime(final_news_df['published date'], format='%a, %d %b %Y %H:%M:%S GMT', errors='coerce')
    #final_news_df['published date'] = final_news_df['published date'].dt.strftime('%Y/%m/%d')
    final_news_df = final_news_df.drop_duplicates(subset=['title', 'url'], keep='first')
    return final_news_df

def scrape_news_content(final_news_df):
    google_news = GNews()
    contents = []
    total_noticias = len(final_news_df['url'])
    for contador, url in enumerate(final_news_df['url'], start=1):
        try:
            print(f"Raspando conteúdo da notícia {contador} de {total_noticias}.")
            article = google_news.get_full_article(url)
            contents.append(article.text if article and hasattr(article, 'text') else '')
        except Exception as e:
            contents.append('')
            print(f"Erro ao capturar conteúdo: {e}")
    final_news_df['conteudo'] = contents
    return final_news_df

def save_to_csv(final_news_df, palavra_chave, data_inicio, data_fim):
    # Cria a pasta 'csvs' se ela não existir
    if not os.path.exists('csvs'):
        os.makedirs('csvs')

    # Formata o timestamp, palavra_chave e nome do arquivo
    timestamp = datetime.now().strftime('%Y%m%d%H%M%S')
    palavra_chave = palavra_chave.replace(" ", "_")
    nome_arquivo = f"{palavra_chave}_{data_inicio}_{data_fim}_{timestamp}.csv".replace("/", "_")

    # Define o caminho completo para salvar o arquivo dentro da pasta 'csvs'
    caminho_completo = os.path.join('csvs', nome_arquivo)

    # Salva o arquivo CSV no caminho completo
    final_news_df.to_csv(caminho_completo, index=False)
    print(f"Arquivo salvo como: {caminho_completo}")

def main(palavras_chave, data_inicio, data_fim):
    set_working_directory()
    for palavra_chave in palavras_chave:
        data_obj_inicio, data_obj_fim = process_date_range(data_inicio, data_fim)
        list_news_df = fetch_news(palavra_chave, data_obj_inicio, data_obj_fim)
        if list_news_df:
            final_news_df = concatenate_news(list_news_df)
            if not final_news_df.empty:
                final_news_df = process_news_data(final_news_df)
                final_news_df = scrape_news_content(final_news_df)
                save_to_csv(final_news_df, palavra_chave, data_inicio, data_fim)
        else:
            print(f"Nenhuma notícia encontrada para a palavra-chave '{palavra_chave}' no intervalo de datas {data_inicio} a {data_fim}.")


if __name__ == "__main__":
    palavras_chave = [
         'ANPD Multa',
         'Vazamento de Dados Pessoais'
        ]

    intervalos = [
                ("01/01/2003", "01/01/2004"),
                ("01/01/2004", "01/01/2005"),
                ("01/01/2005", "01/01/2006"),
                ("01/01/2006", "01/01/2007"),
                ("01/01/2007", "01/01/2008"),
                ("01/01/2008", "01/01/2009"),
                ("01/01/2009", "01/01/2010"),
                ("01/01/2010", "01/01/2011"),
                ("01/01/2011", "01/01/2012"),
                ("01/01/2012", "01/01/2013"),
                ("01/01/2013", "01/01/2014"),
                ("01/01/2014", "01/01/2015"),
                ("01/01/2015", "01/01/2016"),
                ("01/01/2016", "01/01/2017"),
                ("01/01/2017", "01/01/2018"),
                ("01/01/2018", "01/01/2019"),
                ("01/01/2019", "01/01/2020"),
                ("01/01/2020", "01/01/2021"),
                ("01/01/2021", "01/01/2022"),
                ("01/01/2022", "01/01/2023"),
                ("01/01/2023", datetime.now().strftime('%d/%m/%Y'))
              ]
    

    for data_inicio, data_fim in intervalos:
        main(palavras_chave, data_inicio, data_fim)
