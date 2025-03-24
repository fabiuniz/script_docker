#!/bin/bash
## --------------------------------------------------------
##  Template: setup_script_launcher
##  Author:    Fabiano
##  DateTime:  2023.03.16
##  Comentário: Script para criar ambiente de desenvolvimento Python sobre ngnix no Docker
## --------------------------------------------------------
#>🐋 Preparação: construindo scripts para execução da aplicação
appscripts="scripts"
apt-get install -y dos2unix
apt-get install -y android-tools-adb
#>- Importando source de Configurações da aplicação (script.cfg)
ls -l "$appscripts/script.cfg"
dos2unix "$appscripts/script.cfg" #<--------------------------
source "$appscripts/script.cfg" #<--------------------------
echo_color $LIGHT_CYAN  "SCRIPT $PWD"
#>- Importando  source da Biblioteca de funções bash (lib_bash.sh)
dos2unix "$appscripts/lib_bash.sh" #<--------------------------
source "$appscripts/lib_bash.sh" #<--------------------------
echo_color $RED  "Preparação: construindo scripts para execução da aplicação"
#>- root@vmlinuxd:/home/userlnx# mkdir script_docker
#>- root@vmlinuxd:/home/userlnx# chmod -R 777 script_docker/
#>- root@vmlinuxd:/home/userlnx#
#>- Rodar esses comando caso o bash dar erro de formato unix do arquivo ao rodar esse script <br>
#>-  - apt-get install -y dos2unix <br>
#>-  - dos2unix setup_script_launcher.sh # convertendo formato do arquivo <br>
# -------------------  DASHBORAD  ----------------------------
#rm /var/lib/docker/overlay2
#ln -s /home/userlnx/docker/overlay2 /var/lib/docker/overlay2 # Pasta com cache das imagens baixadas para reutilizar em outras vms
#chown -R userlnx:userlnx /home/userlnx/docker/overlay2
#>- construindo .sh para publicar arqivos docker <br>
#-------------------------------------------------------------------------------------
echo_color $GREEN  "Entrando na pasta: $PWD"
cat <<EOF > publish_$app_name.sh
show_docker_config
show_docker_commands_custons
docker-compose -f $app_name/$docker_compose_file up --build -d $params_containers
dashboard_docker
#. start_$app_name.sh
EOF
#>- construindo .sh para Iniciar docker <br>
#-------------------------------------------------------------------------------------
cat <<EOF > load_$app_name.sh
    dos2unix scripts/script.cfg
    dos2unix scripts/lib_bash.sh
    source scripts/script.cfg
    source scripts/lib_bash.sh
EOF
#-------------------------------------------------------------------------------------
cat <<EOF > start_$app_name.sh
    source scripts/script.cfg
    source scripts/lib_bash.sh
    # - app_name="${app_name}"
    docker_compose_file="docker-compose.yml"
    #>-  - Construir e subir os containeres <br>
    docker-compose -f $app_name/$docker_compose_file up --build -d $params_containers
    #>-  - Verificar se os serviços estão rodando <br>
    docker-compose -f $app_name/$docker_compose_file ps
    show_docker_config
    show_docker_commands_custons
    #>-  - Nota: Caso o serviço Apache ou Nginx já existente esteja usando as portas 80 e 443, <br>
    #>-  - certifique-se de parar ou reconfigur-lo para evitar conflitos de porta. <br>
EOF
#>- construindo .sh para parar docker <br>
#-------------------------------------------------------------------------------------
cat <<EOF > stop_all.sh
    docker stop $(docker ps -q)
    docker ps
    echo "\nTodas Aplicações $app_name fechadas"
EOF
#-------------------------------------------------------------------------------------
cat <<EOF > stop_$app_name.sh
    #>-  - app_name="${app_name}"
    docker stop $app_name"_nginx"
    docker stop $app_name"_py-app"
    docker ps
    echo "\nAplicação $app_name fechada"
EOF
#>- construindo .sh para parar docker <br>
#-------------------------------------------------------------------------------------
cat <<EOF > clear_$app_name.sh
    #>- Remove contêineres parados (sem afetar volumes ou imagens) <br>
    docker container prune -f
    #>- Remove imagens dangling (sem tags), liberando espaço, sem afetar as imagens ativamente utilizadas <br>
    docker image prune -f
    #>- Remove volumes que não estão sendo utilizados por contêineres ativos <br>
    docker volume prune -f
    #>- Remove todas as imagens não utilizadas, incluindo aquelas que possuem tags, liberando mais espaço <br>
    #docker image prune -a
    #>- Lista todos os contêineres ativos <br>
    docker ps
EOF
#>📁 Passo 1: Criação da sub Estrutura de Diretórios da aplicação <br>
echo_color $RED  "Passo 1: Criação da sub Estrutura de Diretórios da aplicação "
mkdir -p $containerhost
mkdir -p $app_dir_con/py-app/app/lib
mkdir -p $backup_dir_py
mkdir -p $containerhost_py
chmod -R 777 $containerhost
cd $app_dir_con
echo_color $GREEN  "Entrando na pasta: $PWD"
#>📝 Passo 2: Criar o arquivo app.py com ssl <br>
echo_color $RED  "Passo 2: Criar o arquivo app.py com ssl"
# -------------------  PYTHON  ----------------------------
echo_color $LIGHT_CYAN  "PYTHON $PWD"
mkdir -p py-app/app
chmod -R 777 py-app
#-------------------------------------------------------------------------------------
cat <<EOF > py-app/app/lib/lib_func.py
import ssl
import mysql.connector
from mysql.connector import Error
from flask_cors import CORS   
from flask import Flask, jsonify,render_template,request, redirect, url_for 
import os
def index():
# lib/lib_func.py
    return """<!DOCTYPE html>
<html lang='pt-BR'>
<head>
    <meta charset='UTF-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1.0'>
    <title>Menu de Análise</title>
    <style>
        body {font-family: 'Arial', sans-serif; background-color: #f4f4f4; color: #333; margin: 0; padding: 20px; line-height: 1.6; }
        h1 {color: #2c3e50; text-align: center; margin-bottom: 20px; }
        ul {list-style-type: none; padding: 0; max-width: 600px; margin: 0 auto; border-radius: 8px; box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1); background-color: #ffffff; }
        li {border-bottom: 1px solid #ddd; }
        li:last-child {border-bottom: none; }
        a {display: block; padding: 15px; text-decoration: none; color: #2980b9; font-weight: bold; transition: background-color 0.3s, color 0.3s; }
        a:hover {background-color: #2980b9; color: #ffffff; }
        p {text-align: center; margin: 20px 0; }
        pre {background-color: #eeeeee; border: 1px solid #ddd; border-radius: 5px; padding: 15px; overflow: auto; max-width: 600px; margin: 20px auto; } 
        .upload-container {text-align: -webkit-center;}
    </style>
</head>
<body>
    <h1>Bem-vindo ao sistema de Análise</h1>
    <ul>
        <li>
        <div class="upload-container">
            <form action="/upload" method="post" enctype="multipart/form-data">
                <input type="file" name="file" accept=".docx" required>
                <button class="upload-button" type="submit">Upload de DOCX</button>
            </form>
        </div>
        </li>
        <li><a href='/analisar_curriculo'>Análise de Currículos</a></li>
        <li><a href='/recomendar'>Sistema de Recomendação * </a></li>
        <li><a href='/chatbot'>Chatbot *</a></li>
        <li><a href='/analisar_sentimento'>Análise de Sentimentos</a></li>
        <li><a href='/visualizar'>Visualização de Dados</a></li>
        <li><a href='/visualizar_pre'>Visualização de Dados Pre *</a></li>
        <li><a href='/conectar'>Testar Conexão</a></li>
        <li><a href='/index2'>Página 2</a></li>
    </ul>
    <p>Hello World Setup Python!</p>
    <p>Execute esses comandos no bash e teste a conexão:</p>
    <pre>
    docker exec --privileged -it ${app_name}_my-db bash
    docker logs ${app_name}_my-db
    mysql -u root -p$db_root_pass
    create database $db_namedatabase;
    CREATE USER '$db_user'@'%' IDENTIFIED BY '$db_pass';
    GRANT ALL PRIVILEGES ON seu_banco_de_dados.* TO '$db_user'@'%';
    GRANT ALL PRIVILEGES ON *.* TO '$db_user'@'%';
    SELECT user, host FROM mysql.user WHERE user = '$db_user';
    FLUSH PRIVILEGES;
    </pre>
    <ul>
    <li><a href='https://$name_host:$app_port_py' target='_blank'>(PYTHON)</a></li>
    <pre>
    Abra o VSCode e conecte ao HOST ou WSL como  
        hostname : $name_host
        usuario: $name_user
        pasta da aplicação: $app_dir_con"
        pasta cache: $backup_dir_py
        pasta compartilhada: $containerhost_py 
        pasta upload: $app_source/py-app/app/uploads
        ftp://$name_host user: $name_user (SFTP HOST) 
        ssh $name_user@$name_host -p 22 (SSH HOST)
        ssh $ftp_user_py@$name_host -p $app_port_ssh_py senha : $ftp_pass_py (SSH DOCkER PYTHON)
    </pre>
    <li><a href='http://$name_host:$app_port_java/hello-world/hello' target='_blank'>(JAVA)</a></li>
    <pre>
        ssh $ftp_user_py@$name_host -p $app_port_ssh_java senha : $ftp_pass_py (SSH DOCkER JAVA)
    </pre>
        <li><a href='http://$name_host/' target='_blank'>(PHP)</a></li>
        <li><a href='http://$name_host:$app_port_react/' target='_blank'>(REACT)</a></li>
        <li><a href='http://$name_host:$app_port_emu/' target='_blank'>(ANDROID)</a></li>
    <pre>    
        No Host:
            adb devices
            adb connect vmlinuxd:5555
            adb -s vmlinuxd:5555 shell
            adb -s vmlinuxd:5555 install suaapk.apk #Instando apks 
            adb -s vmlinuxd:5555 push /home/userlnx/MyApp/ /storage/emulated/0/AppProjects/MyApp # subindo fontes
        Usar RealVNC para conectar no Android
        VNC Server:$name_host:$app_port_emu/ (VNC ANDROID)         
    </pre>
    </ul>
</body>
</html>
"""
def conectar_e_executar():
    host= "vmlinuxd"
    usuario="$db_user"
    senha= "$db_pass"
    banco_de_dados="seu_banco_de_dados"

    """
    Conecta ao banco de dados MySQL, executa as consultas e imprime os resultados.
    Args:
        host (str): O endereço do host do MySQL.
        usuario (str): O nome de usuário do MySQL.
        senha (str): A senha do MySQL.
        banco_de_dados (str): O nome do banco de dados.
    """
    conexao = None  # Inicializa com None
    try:
        # Conecta ao banco de dados
        conexao = mysql.connector.connect(
            host=host,
            user=usuario,
            password=senha,
            database=banco_de_dados
        )
        if conexao.is_connected():
            db_Info = conexao.get_server_info()
            print("Conectado ao MySQL Server versão ", db_Info)
            cursor = conexao.cursor()
            # Consulta 1: SELECT user, host FROM mysql.user WHERE user = '$db_user';
            cursor.execute("SELECT user, host FROM mysql.user WHERE user = '$db_user'")
            resultados_usuarios = cursor.fetchall()
            print("\nResultados da consulta SELECT user, host FROM mysql.user WHERE user = '$db_user':")
            usuarios = []  #lista para armazenar os usuarios
            for linha in resultados_usuarios:
                print(f"User: {linha[0]}, Host: {linha[1]}")
                usuarios.append({"user": linha[0], "host": linha[1]}) #adicionando na lista
            # Consulta 2: SHOW GRANTS FOR '$db_user'@'%';
            cursor.execute("SHOW GRANTS FOR '$db_user'@'%'")
            resultados_permissoes = cursor.fetchall()
            print("\nResultados da consulta SHOW GRANTS FOR '$db_user'@'%':")
            permissoes = [] #lista para armazenar as permissoes
            for linha in resultados_permissoes:
                print(linha[0])  # Imprime a concessão (grant)
                permissoes.append(linha[0]) #adicionando na lista
            return jsonify({"status": "success",
                            "message": "Conexão e consultas bem-sucedidas",
                            "usuarios": usuarios,
                            "permissoes": permissoes})
        else:
            return jsonify({"status": "error", "message": "Falha ao conectar ao banco de dados."})
    except mysql.connector.Error as e:
        print("Erro ao conectar ao MySQL:", e)
        return jsonify({"status": "error", "message": str(e)})
    finally:
        # Fecha a conexão
        if conexao and conexao.is_connected():
            cursor.close()
            conexao.close()
            print("Conexão ao MySQL foi fechada")
        else:
            print("Nenhuma conexão para fechar.")
            # Decide o que retornar aqui se não houver conexão para fechar
            # Pode ser uma mensagem informativa ou um erro.
            return jsonify({"status": "info", "message": "Nenhuma conexão para fechar."})

    # Exemplo de uso:  Substitua pelas suas credenciais reais
    #host = "localhost"  # Ou o endereço IP do seu host Docker, se não for localhost
    #usuario = "$db_user"  # Ou '$db_user', se você quiser usar esse usuário
    #senha = "$db_pass"
    vbanco_de_dados = "mysql"  # ou 'seu_banco_de_dados' se as grants foram criadas nesse banco
    #conectar_e_executar(host, usuario, senha, banco_de_dados)    
    #pip install mysql-connector-python
def runFlaskport(app, debug, host, port):
    # Caminho para o certificado SSL e a chave privada
    ssl_cert = 'ssl/nginx-ssl.crt'
    ssl_key = 'ssl/nginx-ssl.key'       
    # Configurações de contexto SSL
    ssl_context = ssl.SSLContext(ssl.PROTOCOL_TLS)
    ssl_context.load_cert_chain(ssl_cert, ssl_key)       
    app.run(ssl_context=ssl_context, debug=debug, host=host, port=port)   
EOF
# Análise de Currículos ----------------------------------------------------
cat <<EOF > py-app/app/curriculo_analisador.py       
# Instale com: pip install python-docx
from docx import Document
def extrair_curriculo(caminho_arquivo):
    #caminho_pdf ='uploads/Profile.pdf'
    caminho_word ='uploads/Profile.docx'
    #converter_pdf_para_word(caminho_pdf,caminho_word)
    doc = Document(caminho_word)
    texto = []
    #texto= [
    #        "Nome: João da Silva",
    #        "Endereço: Rua das Flores, 123, Bairro Jardim",
    #        "Telefone: (11) 91234-5678",
    #        "Email: joao.silva@email.com",
    #        "Experiência: ",
    #        "2018 - 2020: Analista de Sistemas na Empresa X",
    #        "2020 - 2023: Desenvolvedor na Empresa Y",
    #        "Educação: ",
    #        "2014 - 2018: Bacharel em Ciência da Computação - Universidade Z"
    #    ]    
    for par in doc.paragraphs:
        texto.append(par.text)
    return texto
def converter_pdf_para_word(caminho_pdf, caminho_word):
    # Cria um objeto Converter
    cv = Converter(caminho_pdf)
    # Converte o PDF para Word
    cv.convert(caminho_word, start=0, end=None)
    cv.close()  # Fecha o conversor    
EOF
# Sistema de Recomendação ----------------------------------------------------
cat <<EOF > py-app/app/sistema_recomendacao.py        
# Instale com: pip install scikit-learn pandas
import pandas as pd
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity
# Exemplo de candidatos
dados = {
    "Candidato": ["Candidato 1", "Candidato 2"],
    "Habilidades": ["Python, Machine Learning", "Python, Data Science, SQL"]
}
df = pd.DataFrame(dados)
# Análise
def recomendar_candidato(vaga_habilidades):
    tfidf = TfidfVectorizer().fit_transform(df['Habilidades'])
    tfidf_vaga = tfidf.transform([vaga_habilidades])
    similaridade = cosine_similarity(tfidf_vaga, tfidf).flatten()
    return df.iloc[similaridade.argsort()[::-1]]
EOF
# Chatbot ---------------------------------------------------------------------
cat <<EOF > py-app/app/chatbot.py                     
# Instale com: pip install chatterbot chatterbot_corpus
from chatterbot import ChatBot
from chatterbot.trainers import ChatterBotCorpusTrainer
chatbot = ChatBot('Recrutador')
# Treinando o chatbot
trainer = ChatterBotCorpusTrainer(chatbot)
trainer.train("chatterbot.corpus.portuguese")
# Utilizando o chatbot
def chat():
    print("Candidato: (escreva 'sair' para sair)")
    while True:
        entrada = input("Você: ")
        if entrada.lower() == 'sair':
            break
        resposta = chatbot.get_response(entrada)
        print(f"Chatbot: {resposta}")
if __name__ == "__main__":
    chat()
EOF
# Análise de Sentimentos -------------------------------------------------------
cat <<EOF > py-app/app/analise_sentimentos.py         
# Instale com: pip install textblob
from textblob import TextBlob
def avaliar_sentimento(texto):
    analise = TextBlob(texto)
    return analise.sentiment
EOF
# Visualização de Dados ---------------------------------------------------------
cat <<EOF > py-app/app/visualizacao.py        
# Instale com: pip install matplotlib
import matplotlib.pyplot as plt
def view_dados():
    # Dados fictícios
    candidatos = ['Candidato 1', 'Candidato 2', 'Candidato 3']
    habilidades = [3, 5, 2]  # Número de habilidades    
    # Criar gráfico
    plt.bar(candidatos, habilidades)
    plt.ylabel('Número de Habilidades')
    plt.title('Comparação de Habilidades dos Candidatos')
    plt.show()    
    # Retornar os dados
    return list(zip(candidatos, habilidades))
EOF
# Visualização de Dados Pre ----------------------------------------------------
cat <<EOF > py-app/app/analise_pretreinado.py        
#pip install transformers torch
from transformers import pipeline
import requests
def usar_pipeline_local(texto_curriculo):
    try:
        # Inicializando o pipeline
        nlp = pipeline("ner", model="dbmdz/bert-large-cased-finetuned-conll03-english", aggregation_strategy="simple")
        resultado = nlp(texto_curriculo)
        return resultado
    except Exception as e:
        print(f"Ocorreu um erro ao analisar o currículo: {e}")
        return None
def usar_api_online(texto_curriculo, api_token):
    try:
        MODEL_NAME = "dbmdz/bert-large-cased-finetuned-conll03-english"
        headers = {
            "Authorization": f"Bearer {api_token}"
        }
        payload = {
            "inputs": texto_curriculo
        }
        # Fazendo a solicitação para a API
        response = requests.post(
            f"https://api.huggingface.co/models/{MODEL_NAME}",
            headers=headers,
            json=payload
        )
        # Obtendo a resposta
        if response.status_code == 200:
            return response.json()
        else:
            print(f"Erro ao acessar a API: {response.status_code} - {response.text}")
            return None
    except Exception as e:
        print(f"Ocorreu um erro ao usar a API online: {e}")
        return None
EOF
# MAIN -------------------------------------------------------------------------
cat <<EOF > py-app/app/app.py
#from pdf2docx import Converter
from curriculo_analisador import extrair_curriculo #Análise de Currículos
#from sistema_recomendacao import recomendar_candidato #Sistema de Recomendação
#from chatbot import iniciar_chat #Chatbot
from analise_sentimentos import avaliar_sentimento  #Análise de Sentimentos
from visualizacao import view_dados # Visualização de Dados
#from analise_pretreinado import analise_pre # Visualização de Dados Pre
from lib.lib_func import *
app = Flask(__name__)   
# Configura o CORS para permitir todas as origens e credenciais
CORS(app, supports_credentials=True)   
@app.route('/upload', methods=['GET', 'POST'])  # Rota para receber o upload
def recebepdf():
    # Configurando o diretório de upload
    UPLOAD_FOLDER = 'uploads'
    app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
    # Certifique-se de que a pasta de uploads exista
    if not os.path.exists(UPLOAD_FOLDER):
        os.makedirs(UPLOAD_FOLDER)
    if request.method == 'POST':
        if 'file' not in request.files:
            return 'Nenhum arquivo foi enviado', 400        
        file = request.files['file']        
        if file.filename == '':
            return 'Nenhum arquivo selecionado', 400        
        if file and file.filename.endswith('.docx'):
            # Define o caminho completo para salvar o arquivo
            file_path = os.path.join(app.config['UPLOAD_FOLDER'], 'Profile.docx')
            file.save(file_path)  # Salva o arquivo
            return 'Arquivo salvo com sucesso!', 200
        else:
            return 'Formato de arquivo inválido. Apenas .docx é permitido', 400
@app.route('/') # MAIN
def idx():
    return index()
@app.route("/index2") #Página 2
def index2():
    return render_template("index.html")
@app.route("/conectar", methods=["GET", "POST"]) #Testar Conexão
def con_exe():
    return conectar_e_executar()
@app.route("/analisar_curriculo", methods=["GET"]) #Análise de Currículos
def rota_analisar_curriculo():
    texto= extrair_curriculo("caminhoarquivo")
    curriculo_data = {
        "curriculo": "\n".join(texto)  # Junta o texto em uma string
    }    
    # Retorna o dicionário como JSON
    return jsonify(curriculo_data) 
#@app.route("/recomendar", methods=["POST"]) #Sistema de Recomendação
#def rota_recomendar():
#    data = request.get_json()
#    #vaga = data.get("dados", {})
#    vaga = "Python, Machine Learning"
#    #print(recomendar_candidato(vaga))
#    resultado = recomendar_candidato(vaga)
#    return jsonify(resultado)
#@app.route("/chatbot", methods=["GET"]) #Chatbot
#def rota_chatbot():
#    data = request.get_json()
#    pergunta = data.get("pergunta", "")
#    resposta = responder_chatbot(pergunta)
#    return jsonify({"resposta": resposta})
@app.route("/analisar_sentimento", methods=["GET"]) #Análise de Sentimentos
def rota_analisar_sentimento():
    #data = request.get_json()
    #texto = data.get("texto", "")
    texto = "Estou muito animado com esta oportunidade!"
    resultado = avaliar_sentimento(texto)
    return jsonify(resultado)
@app.route("/visualizar", methods=["GET"]) #Visualização de Dados
def rota_visualizar():
    #data = request.get_json()
    #parametros = data.get("parametros", {})
    resultado = view_dados()
    return jsonify({"status": "View gerado", "data": resultado})    
#@app.route("/visualizar_pre", methods=["GET"]) #Visualização de Dados Pre
#def rota_visualizar_pre():
#    curriculo = "Seu texto de currículo aqui."  # Substitua por um texto de currículo real
#    # Perguntando ao usuário qual método prefere
#    escolha = input("Você prefere usar (1) O modelo local ou (2) A API online? (digite 1 ou 2): ")
#    if escolha == "1":
#        resultado = usar_pipeline_local(curriculo)
#        print("Resultado da análise com modelo local:")
#        print(resultado)
#    elif escolha == "2":
#        api_token = input("Por favor, insira seu token de acesso da Hugging Face: ")
#        resultado = usar_api_online(curriculo, api_token)
#        print("Resultado da análise com a API online:")
#        print(resultado)
#    else:
#        print("Escolha inválida. Por favor, digite 1 ou 2.")

if __name__ == '__main__':
    runFlaskport(app, True, '0.0.0.0', $app_port_py)
EOF
#>📄 Passo 3: Criar o arquivo requirements.txt <br>
echo_color $RED  "Passo 3: Criar o arquivo requirements.txt"
#----------------------------------------------------------------------------------------------
cat <<EOF > py-app/app/requirements.txt
# ------------------- Framework para a aplicação web --------------------------------------------
Flask==2.1.1                    # ~ 300 KB
flask_cors==4.0.0               # ~ 20 KB
Werkzeug==2.1.1                 # ~ 1 MB
# ------------------- Manipulação e análise de dados ------------------------------------------
numpy==1.21.2                  # ~ 8 MB                   # Para operações numéricas
#pandas==1.3.3  #2.1.4         # ~ 12 MB                  # Para manipulação e análise de dados
# ------------------- Modelos de machine learning ---------------------------------------------
#scikit-learn==0.24.2           # ~ 7 MB                   # Para modelos de aprendizado de máquina
# ------------------- Processamento de linguagem natural
#nltk==3.6.2                    # ~ 2 MB                   # Para processamento de texto e análise de sentimentos
textblob==0.15.3               # ~ 50 KB                  # Para análise de sentimentos
# ------------------- Visualização de dados ---------------------------------------------------
matplotlib==3.4.3              # ~ 10 MB                  # Para visualização de dados
#seaborn==0.11.2                # ~ 1 MB                   # Para aprimorar a visualização
# ------------------- Visualização de dados pre ---------------------------------------------------
#torch==1.12.1                   # ~700 MB a 2 GB         # Biblioteca de aprendizado de máquina para deep learning dependendo do suporte a GPU
#transformers==4.20.1            # ~50 MB a 80 MB         # Biblioteca para modelos de processamento de linguagem natural (NLP)
# ------------------- Bibliotecas para criar chatbots -----------------------------------------
#ChatterBot==1.0.5              # ~ 2 MB                   # Para a implementação do chatbot
# Deep Learning (se necessário) -------------------------------------------
#tensorflow==2.6.0              # ~ 500 MB                 # Para construção de modelos de deep learning
# ------------------- Bibliotecas para manipulação de arquivos --------------------------------
#pdf2docx==0.5.4                                           # Converter pdf em word
python-docx >=0.8.11                                      # Para manipular arquivos Word
#openpyxl==3.1.2                # ~ 1 MB                   # Para manipular arquivos Excel
#Pillow==9.0.1                  # ~ 1 MB                   # Para manipulação de imagens
#PyPDF2==1.26.0 #3.17.1         # ~ 1 MB                   # Para manipulação de arquivos PDF
#pytesseract==0.3.10            # ~ 5 MB                   # Para reconhecimento óptico de caracteres
#PyQtWebEngine==5.15.6          # ~ 50 MB                  # Para desenvolvimento de aplicações web com PyQt
# ------------------- Outras dependências conforme necessário ---------------------------------
#PyExecJS==1.5.1                # ~ 50 KB                  #
#PyMuPDF>=1.19.6                # ~ 10 MB                  #
#pywin32==304                   # ~ 1 MB                   #
EOF
#>🛠️ Passo 4: Criar o Dockerfile para a aplicação Flask <br>
echo_color $RED  "Passo 4: Criar o Dockerfile para a aplicação Flask"
mkdir -p my-db/docker-entrypoint-initdb.d
#-------------------------------------------------------------------------------------
cat <<EOF > my-db/docker-entrypoint-initdb.d/init.sql
    -- Cria o banco de dados (se não existir)
    CREATE DATABASE IF NOT EXISTS $db_namedatabase;
    -- Cria o usuário (se não existir) e dá permissões ao banco de dados
    CREATE USER IF NOT EXISTS '$db_user'@'%' IDENTIFIED BY '$db_pass';
    GRANT ALL PRIVILEGES ON $db_namedatabase.* TO '$db_user'@'%';
    -- Aplica as mudanças
    FLUSH PRIVILEGES;
EOF
 # Criar o arquivo de configuração my.cnf
# Criar o diretório temporário
mkdir -p my-db/tmp
# Criar o arquivo my.cnf
#-------------------------------------------------------------------------------------
cat <<EOF > my-db/tmp/my.cnf
[mysqld]
bind-address = 0.0.0.0
max_connections = 200
EOF
# Criar o Dockerfile
#-------------------------------------------------------------------------------------
cat <<EOF > my-db/Dockerfile
    FROM ${IMAGE_NAME_db_stage1}
    # Adicione scripts de inicialização (opcional)
    # COPY ./docker-entrypoint-initdb.d /docker-entrypoint-initdb.d/
    # Copiar o arquivo de configuração para o contêiner
    COPY ./tmp/my.cnf /etc/mysql/conf.d/my.cnf    
    # (Opcional) Copie scripts SQL de inicialização para o contêiner
    #COPY docker-entrypoint-initdb.d/init.sql /docker-entrypoint-initdb.d/
    EXPOSE $db_port_mysql
    CMD ["mysqld"]
EOF
# -------------------  JAVA http://vmlinuxd:8080/hello-world/hello  ----------------------------
echo_color $LIGHT_CYAN  "JAVA $PWD"
mkdir -p java-app/src/main/java/com/example
mkdir -p java-app/src/main/webapp/WEB-INF
chmod -R 777 java-app
new_pom_content=$(cat << EOF
plugins {
    id 'java'
    id 'war' // Para construir um arquivo WAR que pode ser implantado em um servidor servlet
}
group 'com.example'
version '1.0-SNAPSHOT'
repositories {
    mavenCentral() // Repositório onde as dependências serão buscadas
}
dependencies {
    implementation 'org.springframework:spring-context:5.3.9'
    providedCompile 'jakarta.servlet:jakarta.servlet-api:5.0.0'
    implementation 'com.fasterxml.jackson.core:jackson-databind:2.16.0'
    testImplementation 'junit:junit:4.13.2'
}
//sourceCompatibility = '11'
//targetCompatibility = '11'
EOF)
#update_file_if_different "java-app/build.gradle" "$new_pom_content"
new_pom_content=$(cat << EOF
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <groupId>com.example</groupId>
    <artifactId>hello-world</artifactId>
    <version>1.0-SNAPSHOT</version>
    <packaging>war</packaging>
    <properties>
        <maven.compiler.source>11</maven.compiler.source>
        <maven.compiler.target>11</maven.compiler.target>
    </properties>
    <dependencies>
        <dependency>
            <groupId>javax.servlet</groupId>
            <artifactId>javax.servlet-api</artifactId>
            <version>4.0.1</version>
            <scope>provided</scope>  <!-- Important: Provided scope for servlet-api -->
        </dependency>
        <dependency>
            <groupId>com.fasterxml.jackson.core</groupId>
            <artifactId>jackson-databind</artifactId>
            <version>2.16.0</version>  <!-- Use a versão mais recente estável -->
        </dependency>    
        <dependency>
            <groupId>mysql</groupId>
            <artifactId>mysql-connector-java</artifactId>
            <version>8.0.9-rc</version> <!-- Substitua pela versão desejada -->
        </dependency>
        <!-- Outras dependências do seu projeto (se houver) -->
    </dependencies>
    <build>
        <finalName>hello-world</finalName>  <!-- Ensure correct WAR file name -->
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-war-plugin</artifactId>
                <version>3.3.2</version>  <!-- Use a recent version -->
                <configuration>
                    <failOnMissingWebXml>false</failOnMissingWebXml> <!-- if you do not use web.xml, this may solve issue -->
                </configuration>
            </plugin>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <version>3.8.1</version>
                <configuration>
                    <source>11</source>
                    <target>11</target>
                </configuration>
            </plugin>
        </plugins>
    </build>
</project>
EOF)

update_file_if_different "java-app/pom.xml" "$new_pom_content"
#-------------------------------------------------------------------------------------
cat <<EOF > java-app/src/main/java/com/example/HelloWorldServlet.java
package com.example;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
@WebServlet("/hello") // Crucial:  This maps the URL /hello to this servlet.
public class HelloWorldServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("text/html");
        PrintWriter out = response.getWriter();
        out.println("<html><body>");
        out.println("<h1>Olá, Mundo!</h1>");
        out.println("<p>Esta é uma aplicação WAR simples no Tomcat.</p>");
        out.println("Execute esses comandos no bash e teste a conexão:<br>");
        out.println("docker exec --privileged -it ${app_name}_db bash<br>");
        out.println("docker logs ${app_name}_db<br>");
        out.println("mysql -u root -p$db_root_pass<br>");
        out.println("create database $db_namedatabase;<br>");
        out.println("CREATE USER 'seu_usuario'@'%' IDENTIFIED BY 'seu_senha_root';<br>");
        out.println("GRANT ALL PRIVILEGES ON seu_banco_de_dados.* TO 'seu_usuario'@'%';<br>");
        out.println("SELECT user, host FROM mysql.user WHERE user = 'seu_usuario';<br>");
        out.println("FLUSH PRIVILEGES;<br>");
        out.println("<a href='conectar'>testar conexão</a>");
        out.println("</body></html>");
    }
}
EOF
#-------------------------------------------------------------------------------------
cat <<EOF > java-app/src/main/java/com/example/ConectarServlet.java
package com.example;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;//-----------------------
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import com.fasterxml.jackson.databind.ObjectMapper;
@WebServlet("/conectar") // Servlet para /conectar
public class ConectarServlet extends HttpServlet { // Usando uma classe separada para /conectar
    // Variáveis para armazenar as informações do banco de dados
    private String host = "$name_host";
    private String usuario = "$db_user";
    private String senha = "$db_pass";
    private String bancoDeDados = "$db_namedatabase";
    private String porta = "$db_port_mysql";
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        processarConexao(request, response);
    }
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        processarConexao(request, response);
    }
    protected void processarConexao(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json"); // Define o tipo de conteúdo como JSON
        response.setCharacterEncoding("UTF-8"); // Importante para caracteres especiais
        PrintWriter out = response.getWriter();
        ObjectMapper mapper = new ObjectMapper();
        Connection conexao = null;
        PreparedStatement consultaUsuarios = null;
        PreparedStatement consultaPermissoes = null;
        ResultSet resultadosUsuarios = null;
        ResultSet resultadosPermissoes = null;
        try {
            // Registrar o driver MySQL
            Class.forName("com.mysql.cj.jdbc.Driver");
            Map<String, Object> resposta = new HashMap<>();
            resposta.put("coneccao", "Conexão estabelecida com sucesso!");
            String jsonResposta = mapper.writeValueAsString(resposta);
            out.print(jsonResposta);
        } catch (ClassNotFoundException e) {
            Map<String, Object> resposta = new HashMap<>();
            resposta.put("coneccao", "O driver JDBC do MySQL não foi encontrado. Verifique se ele está no classpath.!");
            String jsonResposta = mapper.writeValueAsString(resposta);
            out.print(jsonResposta);
            e.printStackTrace();
        }
        try {
            // Conecta ao banco de dados
            conexao = DriverManager.getConnection("jdbc:mysql://" + host + ":" + porta + "/" + bancoDeDados + "?useSSL=false", usuario, senha);
            //conexao = DriverManager.getConnection("jdbc:mysql://" + host + ":" + porta + "/" + bancoDeDados + "?useSSL=true&requireSSL=true&verifyServerCertificate=true", usuario, senha);
            //conexao = DriverManager.getConnection("jdbc:mysql://" + host + ":"+porta+"/" + bancoDeDados, usuario, senha);
            //conexao = DriverManager.getConnection("jdbc:mysql://" + host + ":" + porta + "/" + bancoDeDados + "?useSSL=false&allowPublicKeyRetrieval=true", usuario, senha);
            if (conexao != null) {
                // Consulta 1: SELECT user, host FROM mysql.user WHERE user = '$db_user';
                consultaUsuarios = conexao.prepareStatement("SELECT user, host FROM mysql.user WHERE user = '$db_user'");
                resultadosUsuarios = consultaUsuarios.executeQuery();
                List<Map<String, String>> usuarios = new ArrayList<>();
                while (resultadosUsuarios.next()) {
                    Map<String, String> usuarioMap = new HashMap<>();
                    usuarioMap.put("user", resultadosUsuarios.getString("user"));
                    usuarioMap.put("host", resultadosUsuarios.getString("host"));
                    usuarios.add(usuarioMap);
                }
                // Consulta 2: SHOW GRANTS FOR '$db_user'@'%';
                consultaPermissoes = conexao.prepareStatement("SHOW GRANTS FOR '$db_user'@'%'");
                resultadosPermissoes = consultaPermissoes.executeQuery();
                List<String> permissoes = new ArrayList<>();
                while (resultadosPermissoes.next()) {
                    permissoes.add(resultadosPermissoes.getString(1)); // O resultado é uma única coluna
                }
                // Criar um mapa para a resposta JSON
                Map<String, Object> resposta = new HashMap<>();
                resposta.put("status", "success");
                resposta.put("message", "Conexão e consultas bem-sucedidas");
                resposta.put("usuarios", usuarios);
                resposta.put("permissoes", permissoes);
                // Converter o mapa para JSON usando Jackson
                String jsonResposta = mapper.writeValueAsString(resposta);
                out.print(jsonResposta); // Enviar a resposta JSON
            } else {
                Map<String, String> resposta = new HashMap<>();
                resposta.put("status", "error");
                resposta.put("message", "Falha ao conectar ao banco de dados.");
                String jsonResposta = mapper.writeValueAsString(resposta);
                out.print(jsonResposta);
            }
        } catch (SQLException e) {
            Map<String, String> resposta = new HashMap<>();
            resposta.put("status", "error");
            resposta.put("message", "Erro ao conectar ao MySQL: " + e.getMessage()); // Pegar a mensagem do erro
            String jsonResposta = mapper.writeValueAsString(resposta);
            out.print(jsonResposta);
        } finally {
            // Fecha a conexão, PreparedStatement e ResultSet no bloco finally para garantir o fechamento
            try {
                if (resultadosUsuarios != null) {
                    resultadosUsuarios.close();
                }
                if (consultaUsuarios != null) {
                    consultaUsuarios.close();
                }
                if (resultadosPermissoes != null) {
                    resultadosPermissoes.close();
                }
                if (consultaPermissoes != null) {
                    consultaPermissoes.close();
                }
                if (conexao != null) {
                    conexao.close();
                    System.out.println("Conexão ao MySQL foi fechada");
                }
            } catch (SQLException se) {
                System.err.println("Erro ao fechar a conexão: " + se.getMessage());
            }
        }
    }
}
EOF
#-------------------------------------------------------------------------------------
cat <<EOF > java-app/src/main/webapp/WEB-INF/web.xml
<?xml version="1.0" encoding="UTF-8"?>
<web-app xmlns="http://xmlns.jcp.org/xml/ns/javaee"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://xmlns.jcp.org/xml/ns/javaee http://xmlns.jcp.org/xml/ns/javaee/web-app_3_1.xsd"
         version="3.1">
</web-app>
EOF
cat <<EOF > java-app/_.dockerignore
target/
*.log
*.class
*.jar
EOF
# -------------------  DOCKER JAVA  ----------------------------
cat <<EOF > java-app/Dockerfile
# Use uma imagem de build do Maven (multi-stage builds)
FROM ${IMAGE_NAME_java_stage1} AS build
# Defina o diretório de trabalho no container
WORKDIR /app
# Copie apenas o pom.xml
COPY pom.xml .
# Copie o código do projeto apenas depois de baixar as dependências
# Baixe as dependências do Maven
RUN mvn dependency:go-offline
# Agora copie o código fonte
COPY src ./src
# Construa o projeto Maven
RUN mvn clean package -DskipTests
# Use a imagem do Tomcat
FROM ${IMAGE_NAME_java_stage2}
# Copie o arquivo WAR do container de build para o Tomcat
COPY --from=build /app/target/hello-world.war /usr/local/tomcat/webapps/hello-world.war
# Baixe o conector MySQL
RUN wget https://repo1.maven.org/maven2/mysql/mysql-connector-java/8.0.9-rc/mysql-connector-java-8.0.9-rc-sources.jar -O /usr/local/tomcat/lib/mysql-connector-java.jar
EOF
# -------------------  REACT  http://vmlinuxd:3000 ----------------------------
mkdir -p react-app/src
cat <<EOF > react-app/src/App.js
// src/App.js
import React from 'react';
//import { BrowserRouter, Route, Routes } from 'react-router-dom';
function App() {
    return (
        //<BrowserRouter basename="/react/"> {/* Define o basename aqui */}
            <div>
                <h1>Hello, World!</h1>
          //      {/* Componentes e rotas adicionais podem ser adicionados aqui */}
          //      <Routes>
          //          <Route path="/" element={<h2>Home Page</h2>} />
          //          {/* Adicione outras rotas conforme necessário */}
          //      </Routes>
            </div>
        //</BrowserRouter>
    );
}
export default App;
EOF
# -------------------  DOCKER PYTHON  ----------------------------
cat <<EOF > py-app/Dockerfile
    #>- Usar a imagem base Python <br>
    FROM ${IMAGE_NAME_py_stage1}
    # Variáveis de ambiente
    ENV DEBIAN_FRONTEND=noninteractive
    # Atualize o pip
    RUN pip install --upgrade pip
    # Instale uma versão específica do pip
    # RUN pip install pip==21.3.1  # Substitua pela versão desejada
    # Atualizar e instalar pacotes necessários
    RUN apt-get update && apt-get install -y \
        openssh-server \
        vsftpd \
        && rm -rf /var/lib/apt/lists/*  # Limpa cache
    RUN apt-get update && apt-get install -y python3 python3-pip
    RUN pip3 install mysql-connector-python
    # Adiciona o novo usuário FTP
    RUN useradd -m $ftp_user_py && mkdir /var/run/sshd && echo "$ftp_user_py:$ftp_pass_py" | chpasswd
    # Permitir login root via SSH (Atenção: apenas para desenvolvimento; não recomendado em produção)
    RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
    # Definir a senha do root
    RUN echo "root:$ftp_pass_py" | chpasswd
    # Criar diretório /app e definir permissões
    RUN mkdir -p /app && chown root:$ftp_user_py /app && chmod 770 /app
    # Adicionar o usuário FTP
    # RUN if [ -z "$ftp_user_py" ] || [ -z "$ftp_pass_py" ]; then echo "ftp_user_py or ftp_pass_py not set"; exit 1; fi && echo "$ftp_user_py:$ftp_pass_py" | chpasswd
    # Configurar o FTP
    RUN echo "write_enable=YES" >> /etc/vsftpd.conf && \
        echo "local_root=/app" >> /etc/vsftpd.conf && \
        echo "userlist_enable=YES" >> /etc/vsftpd.conf && \
        echo "$ftp_user_py" >> /etc/vsftpd.userlist
    # Configurar o diretório home do usuário FTP
    RUN mkdir -p /home/$ftp_user_py && chown $ftp_user_py:$ftp_user_py /home/$ftp_user_py
    # Definir o diretório de trabalho no contêiner
    WORKDIR /app
    # Copiar o arquivo requirements.txt para o contêiner
    COPY app/requirements.txt .
    # Instalar as dependências do Python
    #RUN pip install --no-cache-dir scikit-learn pandas
    #RUN for i in 1 2 3; do pip install scikit-learn pandas && break || sleep 15; done
    RUN pip install --timeout=120 -r requirements.txt
    # Copiar os arquivos necessários para o diretório de trabalho
    COPY app /app
    # Expor as portas do SSH, FTP e da aplicação Flask
    EXPOSE 22 21 $app_port_py
    # Iniciar o SSH, o FTP e a aplicação Flask
    CMD service ssh start && service vsftpd start && python app.py
EOF
# -------------------  DOCKER REACT  ----------------------------
echo_color $LIGHT_CYAN  "REACT $PWD"
cat <<EOF > react-app/Dockerfile
    # Use uma imagem base do Node.js
    FROM ${IMAGE_NAME_react_stage1} as build
    # Define o diretório de trabalho
    WORKDIR /app    
    # Instala o create-react-app globalmente
    RUN npm install -g create-react-app    
    # Cria um novo aplicativo React
    RUN npx create-react-app react-app    
    # Define o diretório de trabalho no aplicativo criado
    WORKDIR /app/react-app    
    # Constrói o aplicativo
    RUN npm run build        
    # Usar a imagem do Nginx para servir a aplicação    
    FROM ${IMAGE_NAME_react_stage2}
    # Copia os arquivos de build para o diretório do Nginx
    COPY --from=build /app/react-app/build /usr/share/nginx/html    
    # Copiar a configuração customizada do Nginx, se necessário
    # COPY nginx.conf /etc/nginx/conf.d/default.conf    
    # Expõe a porta na qual a aplicação servida ficará disponível
    EXPOSE $app_port_react    
    # Comando para iniciar o Nginx
    CMD ["nginx", "-g", "daemon off;"]
EOF
# -------------------  ANDROID  ----------------------------
echo_color $LIGHT_CYAN  "ANDROID $PWD"
mkdir -p adr-app
# Escrevendo o Dockerfile
#-------------------------------------------------------------------------------------
cat <<EOF > adr-app/Dockerfile.emu
    FROM ${IMAGE_NAME_emu_stage1}
    # Garantir que estamos como root para as próximas operações
    #USER root
    # Instalação do x11vnc e outros pacotes necessários
    #RUN apt-get update && apt-get install -y \
    #    x11vnc \
    #    xvfb \
    #    openbox \
    #    adb \
    #    && apt-get clean
    # Configuração da senha para VNC
    #RUN mkdir ~/.vnc && \
    #    x11vnc -storepasswd $vnc_pass_adr ~/.vnc/passwd
    # Copiar o arquivo APK para o contêiner
    #COPY aide.apk /workspace/app.apk
    # Comando para adicionar regras do iptables
    #RUN iptables -A INPUT -p tcp --dport 5901 -j ACCEPT
    # Iniciar o servidor VNC e o ambiente gráfico
    #CMD ["sh", "-c", "Xvfb :1 -screen 0 1280x720x24 & x11vnc -display :1 -nopw -forever -repeat -rfbport $app_port_emu -shared"]
    #CMD ["sh", "-c", "Xvfb :1 -screen 0 1280x720x24 & /path/to/your/emulator -avd your_avd_name -no-snapshot-load -no-audio -no-boot-anim & sleep 30 && adb install /workspace/aide.apk && x11vnc -display :1 -nopw -forever -repeat -rfbport $app_port_emu -shared"]    
EOF
# -------------------  ANDROID  ----------------------------
mkdir -p adr-app
#-------------------------------------------------------------------------------------
cat <<EOF > adr-app/Dockerfile
    # Dockerfile
    FROM ${IMAGE_NAME_adr_stage1}    
    #RUN wget https://dl.google.com/android/studio/ide-zips/2023.1.1.18/android-studio-2023.1.1.18-linux.tar.gz -O /tmp/android-studio.tar.gz && \
    #    tar -xzf /tmp/android-studio.tar.gz -C /opt && \
    #    rm /tmp/android-studio.tar.gz
    #RUN appium
    #RUN npm install -g appium
    EXPOSE 6080 5554 5555
    CMD ["bash"]
EOF
# -------------------  PHP  ----------------------------
echo_color $LIGHT_CYAN  "PHP $PWD"
mkdir -p php-app/src
#-------------------------------------------------------------------------------------
cat <<EOF > php-app/nginx.conf
server {
    listen       $app_port_php;
    listen  [::]:$app_port_php;
    server_name $name_host;
    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
    }
    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }
}
EOF
# -------------------  PHP  ----------------------------
cat <<EOF > php-app/src/index.php
   <?php echo 'Hello , PHP Dockerized Web App!'; phpinfo(); ?>
EOF
# -------------------  DOCKER PHP  ----------------------------
cat <<EOF > php-app/Dockerfile
FROM php:8.0-fpm
COPY src/ /var/www/html
WORKDIR /var/www/html
# Ajusta as permissões: atribui propriedade ao usuário www-data e define permissões
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html
EXPOSE $app_port_php
CMD ["php-fpm"]
EOF
# -------------------  NGINX  ----------------------------
echo_color $LIGHT_CYAN  "NGINX $PWD"
#>⚙️ Passo 5: Criar o arquivo de configuraço do Nginx com ssl(nginx.conf) <br>
echo_color $RED  "Passo 5: Criar o arquivo de configuraço do Nginx com ssl(nginx.conf) "
#-------------------------------------------------------------------------------------
cat <<EOF > $nginx_conf
user  nginx;
worker_processes  1;
error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;
events {
    worker_connections  1024;
}
http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;
    log_format  main  '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                      '\$status \$body_bytes_sent "\$http_referer" '
                      '"\$http_user_agent" "\$http_x_forwarded_for"';
    access_log  /var/log/nginx/access.log  main;
    sendfile        on;
    keepalive_timeout  65;
    # Aplicação PHP (sem SSL)
    server {
        listen 80;
        server_name vmlinuxd;
        root /var/www/html;
        index index.php index.html index.htm;
        location / {
            try_files \$uri \$uri/ =404;
        }
        # Configuração para processar arquivos PHP
        location ~ \.php\$ {
            include fastcgi_params;
            fastcgi_pass php-app:${app_port_php};
            fastcgi_index index.php;
            fastcgi_param SCRIPT_FILENAME /var/www/html\$fastcgi_script_name;
        }
    }
    #---------------------------------------------------------------
    #server {
    #    listen 80;  # Ouvindo na porta 80 (HTTP)
    #    server_name $name_host;
    #    # Redireciona todas as requisições HTTP para HTTPS
    #    return 301 https://$host$request_uri;
    #}
    ## Aplicação Java (sem SSL)
    #server {
    #    listen $app_port_java;  # Ouvindo na porta 8080 (HTTP)
    #    server_name $name_host;
    #    location / {
    #        proxy_pass http://java-app:$app_port_java;  # Proxy para a aplicação Java
    #        proxy_set_header Host $name_host;
    #        proxy_set_header X-Real-IP $remote_addr;
    #        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    #        proxy_set_header X-Forwarded-Proto $scheme;
    #    }
    #}
    ## Aplicação React (com SSL)
    #server {
    #    listen 443 ssl http2;  # Ouvindo na porta 443 (HTTPS)
    #    server_name $name_host;
    #    ssl_certificate /etc/nginx/ssl/my_combined_certificate.crt;  # Certificado único
    #    ssl_certificate_key /etc/nginx/ssl/my_combined_certificate.key;  # Chave do certificado
    #    location / {
    #        proxy_pass http://react-app:$app_port_react;  # Proxy para a aplicação React
    #        proxy_set_header Host $name_host;
    #        proxy_set_header X-Real-IP $remote_addr;
    #        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    #        proxy_set_header X-Forwarded-Proto $scheme;
    #    }
    #}
    ## Aplicação PHP (com SSL)
    #server {
    #    listen $app_port_php;  # Ouvindo na porta 8000 (HTTP)
    #    server_name $name_host;
    #    location / {
    #        proxy_pass http://php-app:$app_port_php;  # Proxy para a aplicação PHP
    #        proxy_set_header Host $name_host;
    #        proxy_set_header X-Real-IP $remote_addr;
    #        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    #        proxy_set_header X-Forwarded-Proto $scheme;
    #    }
    #}
    ## Aplicação Python (acesso sem SSL, se necessário)
    #server {
    #    listen $app_port_py;  # Ouvindo na porta 8000 (HTTP)
    #    server_name $name_host;
    #    location / {
    #        proxy_pass http://py-app:$app_port_py;  # Proxy para a aplicação Python
    #        proxy_set_header Host $name_host;
    #        proxy_set_header X-Real-IP $remote_addr;
    #        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    #        proxy_set_header X-Forwarded-Proto $scheme;
    #    }
    #}
}
EOF
#>🧩 Passo 6: Criar o arquivo docker-compose.yml <br>
echo_color $RED  "Passo 6: Criar o arquivo docker-compose.yml"
# -------------------  DOCKER COMPOSE  ----------------------------
echo_color $LIGHT_CYAN  "COMPOSE $PWD"
cat <<EOF > $docker_compose_file
    version: '3'
    services:
      py-app:
        build: 
            context: ./py-app  # Caminho para o diretório da aplicação python
        container_name: ${app_name}_py-app
        ports:
          - "$app_port_py:$app_port_py"
          - "$app_port_ftp_py:21"                 # Porta FTP
          - "$app_port_ssh_py:22"                 # Porta SSH
          #- "21000-21010:21000-21010"  # Portas passivas FTP (ajuste se necessário)
        environment:
          - FTP_USER=${ftp_user_py}    # Se você quiser parametrizar o usuário
          - FTP_PASS=${ftp_pass_py}    # Se você quiser parametrizar a senha
        volumes:
          - ${cur_dir}/${containerhost_py}:/${containerfolder_py}:rw
      nginx:
        image: nginx:latest
        container_name: ${app_name}_nginx
        ports:
          - "80:80"
          - "443:443"
        volumes:
          - ./nginx.conf:/etc/nginx/nginx.conf
          - ./php-app/src:/var/www/html  # Mapeando o volume do diretório PHP para o NGINX
        depends_on:
          - php-app
        #networks:
        #  - public_network
      my-db:
        build:
          context: ./my-db  # Caminho para o diretório da aplicação mysql          
        container_name: ${app_name}_my-db
        restart: always
        environment:
          MYSQL_ROOT_PASSWORD: $db_root_pass
          MYSQL_DATABASE: $db_namedatabase
          MYSQL_USER: $db_user
          MYSQL_PASSWORD: $db_pass
        ports:
          - "$db_port_mysql:$db_port_mysql"
        volumes:
          - db_data:/var/lib/mysql
        healthcheck:
          test: ["CMD", "mysqladmin", "ping", "-h", "localhost", "-u", "root", "-p${MYSQL_ROOT_PASSWORD}"]
          timeout: 20s
          retries: 3
        networks:
          - public_network
      java-app:  # Novo serviço para a aplicação Java
        build:
          context: ./java-app  # Caminho para o diretório da aplicação Java
        container_name: ${app_name}_java-app
        ports:
          - "$app_port_java:$app_port_java"  # Ajuste a porta conforme necessário
          - "$app_port_ssh_java:22"                 # Porta SSH
        volumes:
          - ~/.m2:/root/.m2  # Montando o diretório
          #- ${cur_dir}/${containerhost_java}:/app:rw
        #depends_on:
        #  - db  # Caso a aplicação Java dependa do banco de dados      
      react-app:  # Serviço para a aplicação React
        build:
          context: ./react-app  # Caminho para o diretório da aplicação React
        container_name: ${app_name}_react-app
        ports:
          - "$app_port_react:80"  # Porta em que o React estará disponível
      php-app:  # Novo serviço para a aplicação PHP
        build:
          context: ./php-app  # Caminho para o diretório da aplicação PHP
        container_name: ${app_name}_php-app
        volumes:
          - ./php-app/src:/var/www/html  # Mapeando diretório local
        ports:
          - "$app_port_php:$app_port_php"  # Mapeando a porta 9000 para acesso externo            
      android-dev:
        build:
          context: ./adr-app  # Caminho para o diretório onde está o Dockerfile
        container_name: ${app_name}_android-dev
        privileged: true
        ports:
          - "$app_port_adr:$app_port_adr"   # Mapeia a porta 6080 do host para a porta 6080 do container
          - "5554:5554"   # Mapeia a porta 5554 do host para a porta 5554 do container
          - "5555:5555"   # Mapeia a porta 5555 do host para a porta 5555 do container
          - "5900:5900"      # Porta VNC padrão
        #environment:
          #- DEVICE=Samsung Galaxy S6  # Samsung Galaxy Tab #Define a variável de ambiente DEVICE
          #- USER=$vnc_user_adr  # Definindo o usuário como root # androidusr
          #- VNC_PASSWORD=$vnc_pass_adr  # Defina aqui se precisar de password
          #- DISPLAY=:0
        restart: always  # (Opcional) Define o comportamento de reinício
        #shm_size: '2g'  # Definindo o tamanho da memória compartilhada
        volumes:
          - ./adr-app:/workspace   # Mapeando seu projeto Android para o contêiner
          #- /home/androidusr/Android/Sdk:/opt/android 
        #devices:
        #  - /dev/kvm  # Adicionando acesso ao dispositivo KVM
        #networks:
        #  - public_network          
    volumes:
        db_data:
    networks:
        public_network:
          driver: bridge # --> docker network create public_network
EOF
# -------------------  RUN BASH  ----------------------------
echo_color $LIGHT_CYAN  "BASH $PWD"
#>- Caso tenha conteúdo na pasta app_source copia sobrepondo existentes <br>
mkdir -p $app_source/py-app/app/ssl
mkdir -p $app_source/py-app/app/uploads
mkdir -p $app_source/java-app/src
mkdir -p $app_source/my-db
mkdir -p $app_source/react-app/src
mkdir -p $app_source/php-app/src
mkdir -p $app_source/adr-app
echo_color $GREEN  "copiando arquivos de "$app_source" para $PWD"
cp -r "$app_source"/* .
chmod -R 777 "$app_source"
#>🔒 Passo 7: Gerar um certificado SSL autoassinado (opcional) <br>
echo_color $RED  "Passo 7: Gerar um certificado SSL autoassinado (opcional)"
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout py-app/app/ssl/nginx-ssl.key -out py-app/app/ssl/nginx-ssl.crt -subj "/CN=$name_host"
#>🐋 Passo 8: Criando pasta da aplicação e Verificar e instalar Docker e Docker Compose <br>
echo_color $RED  "Passo 8: Criando pasta da aplicação e Verificar e instalar Docker e Docker Compose "
vrf_dialog "carregar imagens de backup em $backup_dir_py?" restore_img_docker
install_docker_if_missing
install_docker_compose_if_missing
#>🚀 Passo 9: Construir e subir os containeres <br>
echo_color $RED  "Passo 9: Construir e subir os containeres "
remove_and_recreate_docker_network "public_network"
#docker-compose down --rmi all # Remove todas imagens
echo_color $RED  "docker-compose -f $docker_compose_file up --build -d $params_containers"
docker-compose -f $docker_compose_file up --build -d $params_containers
#>✅ Passo 10: Verificar se os serviços estão rodando <br>
echo_color $RED  "Passo 10: Verificar se os serviços estão rodando "
docker-compose -f $docker_compose_file ps
#>- Parar e remover contêiner existente, se necessário (Desmontando unidade) <br>
echo_color $RED  "docker stop "$app_name"_py-app" 
echo_color $RED  "docker rm " $app_name"_py-app" 
#>- Criar e executar um novo contêiner com volume montado <br>
echo_color $RED  "docker run -d -v /home/userlnx/"$app_name"/"$containerhost_py":/app -p $app_port:$app_port --name " $app_name $app_name"_py-app" 
#>- Limpeza <br>
echo_color $RED  "Limpeza"
. ../clear_"$app_name".sh
#>- Finalizando <br>
show_docker_config
show_docker_commands_custons
cd $cur_dir
echo_color $GREEN  "Entrando na pasta: $PWD"
#>- Nota: Caso o serviço Apache ou Nginx já existente esteja usando as portas 80 e 443, <br>
#>- certifique-se de parar ou reconfigur-lo para evitar conflitos de porta. <br>
echo "${cur_dir}/${containerhost_py} /${containerfolder_py}"
dashboard_docker
echo -e "\a";

#################################  BRAINSTORM  ###############################

#https://readme.so/pt/editor
#https://start.spring.io/
#https://profile-readme-generator.com/result
#https://dashboard.render.com/ 
#https://console.neon.tech/
#https://github.com/sickcodes/dock-droid?tab=readme-ov-file
#https://www.youtube.com/watch?v=QfmSEzRXN1o Anaconda Python e Jupyter Notebook

# -------------------  SOME COMMANDS  ----------------------------
#rm ${app_name}_app --force
#ss -tuln | grep 5900
#ps aux | grep vnc
#ss -tuln
#ls -l /home/androidusr/.vncpass
#cat /home/androidusr/.vncpass
#rm /home/androidusr/.vncpass
#x11vnc -storepasswd
#x11vnc -display :0 -usepw -ncache 10
#sudo apt-get update
#sudo ufw status
#sudo ufw allow 5901
#sudo iptables -A INPUT -p tcp --dport 5901 -j ACCEPT
#sudo iptables -L
#nc -zv 127.0.0.1 5900
#x11vnc -display :0 -forever -shared -rfbauth /home/android -log file=/home/android/vnc.log
#x11vnc -display :0 -forever -shared -log /logs/meu_log -rfbauth /home/androidusr/.vncpass
#tail -f /logs/meu_log

#@echo off
#echo Liberando portas no firewall para VNC...
#REM Liberar a porta 5900 para VNC (se precisado)
#netsh advfirewall firewall add rule name="VNC Port 5900" dir=in action=allow protocol=TCP localport=5900
#REM Liberar a porta 5901 para VNC
#netsh advfirewall firewall add rule name="VNC Port 5901" dir=in action=allow protocol=TCP localport=5901
#echo Regras de firewall adicionadas com sucesso.
#pause
#netsh advfirewall firewall show rule name="VNC Port 5900"
#netsh advfirewall firewall show rule name="VNC Port 5901"
#https://www.youtube.com/redirect?event=video_description&redir_token=QUFFLUhqa0VkOGhfQkNHV3JKUk5Xcm9xQ0dIN1lCRXZJUXxBQ3Jtc0tuZkItRi1fMHdFb0RLVXd4V3VadFB5bHFXem00S0htREh4aGF4TGl2MTR2bXk1QmNSUGpoYU1rN1FqTzJvQWd2SDV5dEZnZlJYQmh5Q1FZWGpmVzdYVnpJODVuUGowT2hSdUhHVTF4VFE4YVdJRXFrbw&q=https%3A%2F%2Fhub.docker.com%2Fr%2Fbudtmo%2Fdocker-android%2Ftags&v=SWin67TZ4AY
#VS CODE + Remote - SSH + F1 Add new host
#Docker no VS Code
# Remover imagens não usadas
#docker image prune -a
# Remover contêineres parados
#docker container prune

# -------------------  ALTERANDO CACHE DO RELAY DOCkER  ----------------------------

#sudo systemctl stop docker
    #mkdir -p /home/userlnx/docker/relay
    #umount /home/userlnx/docker/relay
    #mount -t cifs "//192.168.1.179/y/Virtual Machines/VirtualPc/vmlinux_d/plugins" /home/userlnx/docker/relay -o username=user,domain=sweethome,password=1111,iocharset=utf8,users,file_mode=0777,dir_mode=0777,vers=3.0
    #cd  /var/lib/docker/overlay2/
    #docker load -i /home/userlnx/docker/relay/cfa5980ffb76.tar # Restaurar
    #docker save -o backup_docker_android.tar budtmo/docker-android
    #docker save -o /home/userlnx/docker/relay/cfa5980ffb76.tar 02193505a44fc9b4084f378b0f9fac7760b0237733ad1605b802074675ddbad3 # Salvar 
    #rsync -aP /var/lib/docker/ /home/userlnx/docker/relay
    #nano /etc/docker/daemon.json
    #{
    #    "data-root": "/mnt/novo_hd/docker"
    #}
    #sudo nano /etc/fstab
    #blkid # encontrar UUID
    #UUID=seu-uuid /mnt/novo_hd ext4 defaults 0 2
#umount /var/lib/docker/overlay2
#mkdir -p /var/lib/docker/overlay2
#chmod  R 777 /var/lib/docker/overlay2
#mkdir -p /home/userlnx/docker/relay
#chmod  -R 777 /home/userlnx/docker/relay
#mount -t cifs "//192.168.1.179/y/Virtual Machines/VirtualPc/vmlinux_d/plugins" /home/userlnx/docker/relay -o username=user,domain=sweethome,password=1111,iocharset=utf8,users,file_mode=0777,dir_mode=0777,vers=3.0
#sudo systemctl start docker
#docker info
#docker rename ${app_name}_app ${app_name}_py-app
#docker tag ${app_name}_app:latest ${app_name}_py-app:latest

#pat.sh
#cd /home/userlnx/docker/script_docker/
#dos2unix setup_script_launcher.sh
#. load_${app_name}.sh
#show_docker_config
#show_docker_commands_custons
#dashboard_docker

#cp /var/cache/apt/archives/*.deb /home/userlnx/docker/script_docker/relay
#cp /home/userlnx/docker/script_docker/relay/*.deb /var/cache/apt/archives
#cp -r ~/.cache/pip /home/userlnx/docker/relay

# -------------------  IMAGENS DOCKER  ----------------------------

#budtmo/docker-android:latest 12.7GB #8033c29d1ae8
#maven:3.8.6-jdk-11 664MB #6c3ab1faec76
#maven:3.8.6-openjdk-11 664MB #6c3ab1faec76
#my-react-app:latest 1.28GB #ef057dddae3b
#mysql:8.0 764MB #99d686794f74
#nginx:alpine 47.9MB #1ff4bb4faebc
#nginx:latest 192MB #97662d24417b
#node:14 912MB #1d12470fa662
#node:18-alpine 127MB #70649fe1a0d7
#openjdk:11 654MB #47a932d998b7
#openjdk:11-jre-slim 223MB #764a04af3eff
#php:8.0-fpm 445MB #c28988545f3b
#python:3.9-slim 126MB #096343841dd9
#react-app_react-app:latest 127MB #9264a714820c
#${app_name}_android-dev:latest 983MB #a454fe6b8886
#${app_name}_android-emulator:latest 12.8GB #5731742daf5e
#${app_name}_app-py:latest 759MB #ff4995cded4a
#${app_name}_app:latest 759MB #2a478e5b326d
#${app_name}_my-db:latest 764MB #f47dd26b30ec
#${app_name}_java-app:latest 471MB #252ab554ea7a
#${app_name}_php-app:latest 50.8MB #d19376fbbf5c
#${app_name}_py-app:latest 759MB #095b0e1941d6
#${app_name}_react-app:latest 49MB #ef1fe2f6f6dc
#tomcat:9-jdk11 466MB #fe3bec002517


# -------------------  BUILDING CODE  ----------------------------
#
#CONFIGURACAO DO HOST e DOCKER CONTAINER
#
#"C:\Users\usuario\.ssh\config"
# Read more about SSH config files: https://linux.die.net/man/5/ssh_config
#Host vmlinuxd
#    HostName vmlinuxd
#    Port 22
#    User userlnx
#    IdentityFile ~/.ssh/id_rsa
#Host vmlinuxd_sub
#    HostName vmlinuxd
#    Port 2222
#    User myuser
#    IdentityFile ~/.ssh/id_rsa
#ssh-keygen -t rsa -b 4096 -C "seu_email@example.com"
#icacls "C:\Users\usuario\.ssh\config" /inheritance:r
#icacls "C:\Users\usuario\.ssh\config" /grant usuario:F
#
#apt install sudo
#nano /etc/sudoers ---> userlnx ALL=(ALL) ALL ----> userlnx ALL=(ALL) NOPASSWD: /home/userlnx/docker/script_docker/publish_${app_name}.sh
# 
# SUBINDO EMULADOR ANDROID
#
#WINDOWS -------------------------------
# docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Image}}\t{{.Ports}}" |   awk 'NR==1 {print $0, "IP"} NR>1 {print $0, system("docker inspect --format '{{ .NetworkSettings.IPAddress }}' " $1)}'
# Stop-VM -Name "Vmlinux_D"
# Set-VMProcessor -VMName "Vmlinux_D" -ExposeVirtualizationExtensions $true
# Start-VM -Name "Vmlinux_D"
#HOST LINUX -------------------------------
# apt-get update
# apt-get install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils
# modprobe kvm
# modprobe kvm_intel  # ou kvm_amd, dependendo do seu processador
# usermod -aG kvm $USER
# usermod -aG docker $USER
# lscpu | grep Virtualization
# apt-get install cpu-checker
# kvm-ok
# docker exec -it script_docker_con_android-emulator /bin/bash
#DOCKER ----------------o emulador precisa de aceleração de hardware (KVM) para executar em modo x86_64 
# apt-get update
# apt-get install android-sdk
# emulator -list-avds
# emulator -avd nexus_5_13.0 -gpu swiftshader_indirect -no-window -no-boot-anim &
# emulator -avd nexus_5_13.0 -no-window -port 5555
# cd ~/Downloads
# tar -xvf android-studio-*-linux.tar.gz
# Usei RealVNC para conectar no Android

#apt-get install -y docker.io
#apt-get install -y docker-compose
#apt-get install -y android-tools-adb
#docker load -i budtmo_docker-android_latest.tar
#docker images
#docker run --privileged -d -p 6080:6080 -p 5554:5554 -p 5555:5555 -e DEVICE="Samsung Galaxy S6" --name android-container budtmo/docker-android
#docker run --privileged -d -p 6080:6080 -p 5554:5554 -p 5555:5555 -e DEVICE="Samsung Galaxy S6" --name android-container budtmo/docker-android-x86-8.1
#adb devices
#adb connect vmlinuxd:5555
#adb -s vmlinuxd:5555 shell
#adb -s vmlinuxd:5555 install aide.apk
#adb -s vmlinuxd:5555 push /home/userlnx/MyApp/ /storage/emulated/0/AppProjects/MyApp
#pm list package
#apt-get install -y net-tools lsof psmisc
#apt install ufw
#docker port android-container
#docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' android-container
#ufw enable
#ufw allow 6080
#netsh advfirewall firewall add rule name="Permitir Porta 6080" dir=out action=allow protocol=TCP localport=6080
#ufw status
#curl http://vmlinuxd:6080
#docker stop android-container
#docker start android-container
#adb kill-server
#adb start-server

#cat <<EOF > docker-compose.yml
#version: '3'  # Escolha a versão do Compose que você prefere
#services:
#  android:
#    #image: budtmo/docker-android
#    build: .
#    container_name: android-container
#    privileged: true
#    ports:
#      - "6080:6080"   # Mapeia a porta 6080 do host para a porta 6080 do container
#      - "5554:5554"   # Mapeia a porta 5554 do host para a porta 5554 do container
#      - "5555:5555"   # Mapeia a porta 5555 do host para a porta 5555 do container
#      - "5900:5900"      # Porta VNC padrão
#    environment:
#      - DEVICE=Samsung Galaxy S6  # Samsung Galaxy Tab #Define a variável de ambiente DEVICE
#    restart: always  # (Opcional) Define o comportamento de reinício
#EOF
#cat <<EOF > Dockerfile
#FROM budtmo/docker-android  # Use a imagem base do Docker Android
#RUN appium
#RUN npm install -g appium
#EXPOSE 6080 5554 5555
#CMD ["bash"]
#EOF
#docker-compose up -d
#docker-compose -f docker-compose.yml up --build -d android-emulator
#
# INSTALADNO VISUAL 1 -----------------------
# 
#apt update
#apt upgrade -y    
#apt install xrdp -y 
#adduser userlnx ssl-cert
#apt install xorgxrdp  
#systemctl start xrdp    
#systemctl enable xrdp    
#ufw allow 3389    
#
# INSTALANDO VISUAL 2 -----------------------
# 
#apt install xfce4 xfce4-goodies
#echo "xfce4-session" > ~/.xsession
#adduser userlnx xrdp
#systemctl restart xrdp
#export DESKTOP_SESSION=xfce
#apt install dbus-x11 -y
#export XDG_SESSION_TYPE=x11
#export XDG_SESSION_DESKTOP=xfce
#export DBUS_SESSION_BUS_ADDRESS=/run/user/1000/bus
#exec startxfce4
#chmod +x ~/.xsession
#systemctl restart xrdp
#
# INSTALANDO GOOGLECHROME -----------------------
# 
#wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
#echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" | tee /etc/apt/sources.list.d/google-chrome.list
#apt-get update
#apt-get install -y google-chrome-stable
#
#USANDO WSL2 no windows 11 -----------------------
#
#wsl --list --verbose
#wsl --unregister Ubuntu
#nano ~/.bashrc
#PS1='${debian_chroot:+($debian_chroot)}\u@vmlinux:\w\$ '
#source ~/.bashrc
#wsl --install -d Debian
#sudo visudo
#userlnx ALL=(ALL) NOPASSWD:ALL
#sudo su -
#ip addr show dev eth0 | grep inet
#sudo apt update && sudo apt install openssh-server -y
#sudo service ssh start
#sudo nano /etc/ssh/sshd_config
#PasswordAuthentication yes
#PermitRootLogin yes
    