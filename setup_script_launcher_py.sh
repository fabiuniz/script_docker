#!/bin/bash
## --------------------------------------------------------
##  Template: setup_script_launcher
##  Author:    Fabiano
##  DateTime:  2023.03.16
##  Comentário: Script para criar ambiente de desenvolvimento Python sobre ngnix no Docker
## --------------------------------------------------------
#>🐋 Preparação: contruindo scripts para execução da aplicação
echo_color $RED  "Preparação: contruindo scripts para execução da aplicação"
#>- root@vmlinuxd:/home/userlnx# mkdir script_docker
#>- root@vmlinuxd:/home/userlnx# chmod -R 777 script_docker/
#>- root@vmlinuxd:/home/userlnx#
#>- Rodar esses comando caso o bash dar erro de formato unix do arquivo ao rodar esse script <br>
#>-  - apt-get install -y dos2unix <br>
#>-  - dos2unix setup_script_launcher.sh # convertendo formato do arquivo <br>
#>- Importando  source da Biblioteca de funções bash (lib_bash.sh)
apt-get install -y dos2unix
appcontainer="scripts"
dos2unix scripts/lib_bash.sh #<--------------------------
source scripts/lib_bash.sh #<--------------------------
#>- Importando source de Configurações da aplicação (script.cfg)
ls -l "$appcontainer/script.cfg"
dos2unix "$appcontainer/script.cfg" #<--------------------------
source "$appcontainer/script.cfg" #<--------------------------
#>- construindo .sh para Iniciar docker <br>
cat <<EOF > start_$app_name.sh
    source scripts/script.cfg
    source scripts/lib_bash.sh
    # - app_name="${app_name}"
    docker_compose_file="docker-compose.yml"
    #>-  - Construir e subir os containeres <br>
    docker-compose -f $app_name/$docker_compose_file up --build -d
    #>-  - Verificar se os serviços estão rodando <br>
    docker-compose -f $app_name/$docker_compose_file ps
    show_docker_config
    show_docker_commands_custons
    #>-  - Nota: Caso o serviço Apache ou Nginx já existente esteja usando as portas 80 e 443, <br>
    #>-  - certifique-se de parar ou reconfigur-lo para evitar conflitos de porta. <br>
EOF
#>- construindo .sh para parar docker <br>
cat <<EOF > stop_$app_name.sh
    #>-  - app_name="${app_name}"
    docker stop $app_name"_nginx"
    docker stop $app_name"_app"
    docker ps
    echo "\nAplicação $app_name fechada"
EOF
#>- construindo .sh para parar docker <br>
cat <<EOF > clear_$app_name.sh
    #>- Remover contêineres parados (sem afetar volumes ou imagens) <br>
    docker container prune -f
    #>- Remover imagens dangling (sem tags) e liberar espaço sem afetar as imagens usadas <br>
    docker image prune -f
    #>- Remover volumes que não estão sendo usados por nenhum contêiner ativo <br>
    docker volume prune -f
    docker ps
EOF
#>📁 Passo 1: Criação da sub Estrutura de Diretórios da aplicação <br>
echo_color $RED  "Passo 1: Criação da sub Estrutura de Diretórios da aplicação "
mkdir -p $containerhost
mkdir -p $app_dir
chmod -R 777 $containerhost
cd $app_dir
#>📝 Passo 2: Criar o arquivo app.py com ssl <br>
echo_color $RED  "Passo 2: Criar o arquivo app.py com ssl"
cat <<EOF > app.py
    import ssl
    from flask import Flask
    from flask_cors import CORS
    app = Flask(__name__)
    #>- Configura o CORS para permitir todas as origens e credenciais <br>
    CORS(app, supports_credentials=True)
    @app.route('/')
    def index():
        return "Hello World!"
    def runFlaskport(app, debug, host, port):
        #>- Caminho para o certificado SSL e a chave privada <br>
        ssl_cert = 'ssl/nginx-ssl.crt'
        ssl_key = 'ssl/nginx-ssl.key'
        #>- Configurações de contexto SSL <br>
        ssl_context = ssl.SSLContext(ssl.PROTOCOL_TLS)
        ssl_context.load_cert_chain(ssl_cert, ssl_key)
        app.run(ssl_context=ssl_context, debug=debug, host=host, port=port)
    if __name__ == '__main__':
        runFlaskport(app, False, '0.0.0.0', 8000)
EOF
#>📄 Passo 3: Criar o arquivo requirements.txt <br>
echo_color $RED  "Passo 3: Criar o arquivo requirements.txt"
cat <<EOF > requirements.txt
    Flask==2.1.1
    flask_cors==4.0.0
    Werkzeug==2.1.1
    pytesseract==0.3.10
    Pillow==9.0.1
EOF
#>🛠️ Passo 4: Criar o Dockerfile para a aplicação Flask <br>
echo_color $RED  "Passo 4: Criar o Dockerfile para a aplicação Flask"
cat <<EOF > Dockerfile
    #>- Usar a imagem base Python <br>
    FROM python:3.9-slim
    # Variáveis de ambiente
    ENV DEBIAN_FRONTEND=noninteractive
    ENV FTP_USER=myuser
    ENV FTP_PASS=mypassword
    # Atualizar e instalar pacotes necessários
    RUN apt-get update && apt-get install -y \
        openssh-server \
        vsftpd \
        && rm -rf /var/lib/apt/lists/*  # Limpa cache
    # Configurar o SSH
    RUN mkdir /var/run/sshd && echo 'root:password' | chpasswd
    # Permitir login root via SSH (Atenção: apenas para desenvolvimento; não recomendado em produção)
    RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
    # Adicionar o usuário FTP
    # RUN if [ -z "$FTP_USER" ] || [ -z "$FTP_PASS" ]; then echo "FTP_USER or FTP_PASS not set"; exit 1; fi && \ useradd -m "$FTP_USER" && echo "$FTP_USER:$FTP_PASS" | chpasswd
    # Configurar o FTP
    RUN echo "write_enable=YES" >> /etc/vsftpd.conf && \
        echo "local_root=/app" >> /etc/vsftpd.conf && \
        echo "userlist_enable=YES" >> /etc/vsftpd.conf && \
        echo "$FTP_USER" >> /etc/vsftpd.userlist
    # Configurar o diretório home do usuário FTP
    RUN mkdir -p /home/$FTP_USER && chown $FTP_USER:$FTP_USER /home/$FTP_USER
    # Definir o diretório de trabalho no contêiner
    WORKDIR /app
    # Copiar o arquivo requirements.txt para o contêiner
    COPY requirements.txt .
    # Instalar as dependências do Python
    RUN pip install -r requirements.txt
    # Copiar os arquivos necessários para o diretório de trabalho
    COPY . /app
    # Expor as portas do SSH, FTP e da aplicação Flask
    EXPOSE 22 21 $app_port
    # Iniciar o SSH, o FTP e a aplicação Flask
    CMD service ssh start && service vsftpd start && python app.py
EOF
#>⚙️ Passo 5: Criar o arquivo de configuraço do Nginx com ssl(nginx.conf) <br>
echo_color $RED  "Passo 5: Criar o arquivo de configuraço do Nginx com ssl(nginx.conf) "
cat <<EOF > $nginx_conf
    events {}
    http {
        server {
            listen 80;
            listen 443 ssl;
            server_name $name_host;
            ssl_certificate /etc/nginx/ssl/nginx-ssl.crt;
            ssl_certificate_key /etc/nginx/ssl/nginx-ssl.key;
            location / {
                proxy_pass http://app:$app_port;
                proxy_set_header Host \$host;
                proxy_set_header X-Real-IP \$remote_addr;
                proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
                proxy_set_header X-Forwarded-Proto \$scheme;
            }
        }
    }
EOF
#>🧩 Passo 6: Criar o arquivo docker-compose.yml <br>
echo_color $RED  "Passo 6: Criar o arquivo docker-compose.yml"
cat <<EOF > $docker_compose_file
    version: '3'
    services:
      app:
        build: .
        container_name: ${app_name}_app
        ports:
          - "$app_port:$app_port"
          - "21:21"                 # Porta FTP
          - "21000-21010:21000-21010"  # Portas passivas FTP (ajuste se necessário)
        environment:
          - FTP_USER=${ftp_user}    # Se você quiser parametrizar o usuário
          - FTP_PASS=${ftp_pass}    # Se você quiser parametrizar a senha
        volumes:
          - ${cur_dir}/${containerhost}:/${containerfolder}:rw
      nginx:
        image: nginx:latest
        container_name: ${app_name}_nginx
        ports:
          - "80:80"
          - "443:443"
        volumes:
          - ./nginx.conf:/etc/nginx/nginx.conf:ro
          - ./ssl:/etc/nginx/ssl:ro
        depends_on:
          - app
EOF
#>- Caso tenha conteúdo na pasta app_source copia sobrepondo existentes <br>
mkdir -p "$app_source"
cp -r "$app_source"* .
chmod -R 777 "$app_source"
#>🔒 Passo 7: Gerar um certificado SSL autoassinado (opcional) <br>
echo_color $RED  "Passo 7: Gerar um certificado SSL autoassinado (opcional)"
mkdir -p ssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ssl/nginx-ssl.key -out ssl/nginx-ssl.crt -subj "/CN=$name_host"
#>🐋 Passo 8: Criando pasta da aplicação e Verificar e instalar Docker e Docker Compose <br>
echo_color $RED  "Passo 8: Criando pasta da aplicação e Verificar e instalar Docker e Docker Compose "
install_docker_if_missing
install_docker_compose_if_missing
#>🚀 Passo 9: Construir e subir os containeres <br>
echo_color $RED  "Passo 9: Construir e subir os containeres "
docker-compose -f $docker_compose_file up --build -d
#>✅ Passo 10: Verificar se os serviços estão rodando <br>
echo_color $RED  "Passo 10: Verificar se os serviços estão rodando "
docker-compose -f $docker_compose_file ps
#>- Parar e remover contêiner existente, se necessário (Desmontando unidade) <br>
echo_color $RED  "docker stop "$app_name"_app" 
echo_color $RED  "docker rm " $app_name"_app" 
#>- Criar e executar um novo contêiner com volume montado <br>
echo_color $RED  "docker run -d -v /home/userlnx/"$app_name"/"$containerhost":/app -p $app_port:$app_port --name " $app_name $app_name"_app" 
#>- Limpeza <br>
echo_color $RED  "Limpeza"
. ../clear_"$app_name".sh
#>- Finalizando <br>
show_docker_config
show_docker_commands_custons
cd $cur_dir
#>- Nota: Caso o serviço Apache ou Nginx já existente esteja usando as portas 80 e 443, <br>
#>- certifique-se de parar ou reconfigur-lo para evitar conflitos de porta. <br>
echo "${cur_dir}/${containerhost} /${containerfolder}"