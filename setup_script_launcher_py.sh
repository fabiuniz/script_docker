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
#>- Importando source de Configurações da aplicação (script.cfg)
ls -l "$appscripts/script.cfg"
dos2unix "$appscripts/script.cfg" #<--------------------------
source "$appscripts/script.cfg" #<--------------------------
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
cat <<EOF > publish_$app_name.sh
show_docker_config
show_docker_commands_custons
cp -r $appcontainer/py-app* $app_name/py-app
docker-compose -f $app_name/$docker_compose_file up --build -d $params_containers
#. start_$app_name.sh
EOF
#>- construindo .sh para Iniciar docker <br>
cat <<EOF > load_$app_name.sh
    source scripts/script.cfg
    source scripts/lib_bash.sh
EOF
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
cat <<EOF > stop_all.sh
    docker stop $(docker ps -q)
    docker ps
    echo "\nTodas Aplicações $app_name fechadas"
EOF
cat <<EOF > stop_$app_name.sh
    #>-  - app_name="${app_name}"
    docker stop $app_name"_nginx"
    docker stop $app_name"_py-app"
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
mkdir -p $app_dir/py-app/app/lib
chmod -R 777 $containerhost
cd $app_dir
echo_color $GREEN  "Entrando na pasta: $PWD"
#>📝 Passo 2: Criar o arquivo app.py com ssl <br>
echo_color $RED  "Passo 2: Criar o arquivo app.py com ssl"
# -------------------  PYTHON  ----------------------------
mkdir -p py-app/app
chmod -R 777 py-app
cat <<EOF > py-app/app/lib/lib_func.py
import ssl
import mysql.connector
from mysql.connector import Error
from flask import Flask, jsonify
from flask_cors import CORS   
from flask import render_template
def index():
     return "Hello World Setup python!<br><br>\
     Execute esses comandos no bash e teste a conexão: <br><br> \
     docker exec --privileged -it script_docker_py_db bash <br> \
     docker logs script_docker_py_db <br> \
     mysql -u root -p$db_root_pass<br>\
     create database $db_namedatabase;<br>\
     CREATE USER 'seu_usuario'@'%' IDENTIFIED BY 'seu_senha_root';<br>\
     GRANT ALL PRIVILEGES ON seu_banco_de_dados.* TO 'seu_usuario'@'%';<br>\
     SELECT user, host FROM mysql.user WHERE user = 'seu_usuario';<br>\
     FLUSH PRIVILEGES;<br>\
     <a href='conectar'>testar conexão</a><br>\
     <a href='index2'>Page 2</a><br>\
    "
def conectar_e_executar():
    host= "vmlinuxd"
    usuario="root"
    senha= "seu_senha_root"
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
            # Consulta 1: SELECT user, host FROM mysql.user WHERE user = 'seu_usuario';
            cursor.execute("SELECT user, host FROM mysql.user WHERE user = 'seu_usuario'")
            resultados_usuarios = cursor.fetchall()
            print("\nResultados da consulta SELECT user, host FROM mysql.user WHERE user = 'seu_usuario':")
            usuarios = []  #lista para armazenar os usuarios
            for linha in resultados_usuarios:
                print(f"User: {linha[0]}, Host: {linha[1]}")
                usuarios.append({"user": linha[0], "host": linha[1]}) #adicionando na lista
            # Consulta 2: SHOW GRANTS FOR 'seu_usuario'@'%';
            cursor.execute("SHOW GRANTS FOR 'seu_usuario'@'%'")
            resultados_permissoes = cursor.fetchall()
            print("\nResultados da consulta SHOW GRANTS FOR 'seu_usuario'@'%':")
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
    #usuario = "root"  # Ou 'seu_usuario', se você quiser usar esse usuário
    #senha = "seu_senha_root"
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
cat <<EOF > py-app/app/app.py
from lib.lib_func import *
app = Flask(__name__)   
# Configura o CORS para permitir todas as origens e credenciais
CORS(app, supports_credentials=True)   
@app.route('/')
def idx():
    return index()
@app.route("/index2")
def index2():
    return render_template("index.html")
@app.route("/conectar", methods=["GET", "POST"])
def con_exe():
    return conectar_e_executar()
if __name__ == '__main__':
    runFlaskport(app, True, '0.0.0.0', $app_port_py)
EOF
#>📄 Passo 3: Criar o arquivo requirements.txt <br>
echo_color $RED  "Passo 3: Criar o arquivo requirements.txt"
cat <<EOF > py-app/requirements.txt
Flask==2.1.1
flask_cors==4.0.0
Werkzeug==2.1.1
#openpyxl==3.1.2
#pandas==2.1.4
#Pillow==9.0.1
#PyExecJS==1.5.1
#PyMuPDF
#PyPDF2==1.26.0
#pypdf==3.17.1
#PyQtWebEngine==5.15.6
#pytesseract==0.3.10
#pywin32==304
EOF
#>🛠️ Passo 4: Criar o Dockerfile para a aplicação Flask <br>
echo_color $RED  "Passo 4: Criar o Dockerfile para a aplicação Flask"
mkdir -p py-app/docker-entrypoint-initdb.d
cat <<EOF > py-app/docker-entrypoint-initdb.d/init.sql
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
mkdir -p tmp
# Criar o arquivo my.cnf
cat <<EOF > tmp/my.cnf
[mysqld]
bind-address = 0.0.0.0
max_connections = 200
EOF
# Criar o Dockerfile
cat <<EOF > Dockerfile.db
    FROM mysql:8.0
    # Adicione scripts de inicialização (opcional)
    # COPY ./docker-entrypoint-initdb.d /docker-entrypoint-initdb.d/
    # Copiar o arquivo de configuração para o contêiner
    COPY ./tmp/my.cnf /etc/mysql/conf.d/my.cnf    
    # (Opcional) Copie scripts SQL de inicialização para o contêiner
    #COPY docker-entrypoint-initdb.d/init.sql /docker-entrypoint-initdb.d/
    EXPOSE $app_port_mysql
    CMD ["mysqld"]
EOF
# -------------------  JAVA http://vmlinuxd:8080/hello-world/hello  ----------------------------
mkdir -p java-app/src/main/java/com/example
mkdir -p java-app/src/main/webapp/WEB-INF
chmod -R 777 java-app
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
        out.println("docker exec --privileged -it script_docker_py_db bash<br>");
        out.println("docker logs script_docker_py_db<br>");
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
    private String senha = "$db_root_pass";
    private String bancoDeDados = "$db_namedatabase";
    private String porta = "$app_port_mysql";
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
            if (conexao != null) {
                // Consulta 1: SELECT user, host FROM mysql.user WHERE user = 'seu_usuario';
                consultaUsuarios = conexao.prepareStatement("SELECT user, host FROM mysql.user WHERE user = 'seu_usuario'");
                resultadosUsuarios = consultaUsuarios.executeQuery();
                List<Map<String, String>> usuarios = new ArrayList<>();
                while (resultadosUsuarios.next()) {
                    Map<String, String> usuarioMap = new HashMap<>();
                    usuarioMap.put("user", resultadosUsuarios.getString("user"));
                    usuarioMap.put("host", resultadosUsuarios.getString("host"));
                    usuarios.add(usuarioMap);
                }
                // Consulta 2: SHOW GRANTS FOR 'seu_usuario'@'%';
                consultaPermissoes = conexao.prepareStatement("SHOW GRANTS FOR 'seu_usuario'@'%'");
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
cat <<EOF > java-app/src/main/webapp/WEB-INF/web.xml
<?xml version="1.0" encoding="UTF-8"?>
<web-app xmlns="http://xmlns.jcp.org/xml/ns/javaee"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://xmlns.jcp.org/xml/ns/javaee http://xmlns.jcp.org/xml/ns/javaee/web-app_3_1.xsd"
         version="3.1">
</web-app>
EOF
# -------------------  DOCKER JAVA  ----------------------------
cat <<EOF > java-app/Dockerfile
# Use uma imagem de build do Maven
FROM maven:3.8.6-jdk-11 AS build
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
FROM tomcat:9-jdk11
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
# -------------------  DOCKER REACT  ----------------------------
cat <<EOF > react-app/Dockerfile
    # Use uma imagem base do Node.js
    FROM node:14 as build
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
    
    FROM nginx:alpine
    # Copia os arquivos de build para o diretório do Nginx
    COPY --from=build /app/react-app/build /usr/share/nginx/html    
    # Copiar a configuração customizada do Nginx, se necessário
    # COPY nginx.conf /etc/nginx/conf.d/default.conf    
    # Expõe a porta na qual a aplicação servida ficará disponível
    EXPOSE $app_port_react    
    # Comando para iniciar o Nginx
    CMD ["nginx", "-g", "daemon off;"]
EOF
# -------------------  DOCKER PYTHON  ----------------------------
cat <<EOF > py-app/Dockerfile
    #>- Usar a imagem base Python <br>
    FROM python:3.9-slim
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
    RUN useradd -m $ftp_user && mkdir /var/run/sshd && echo "$ftp_user:$ftp_pass" | chpasswd
    # Permitir login root via SSH (Atenção: apenas para desenvolvimento; não recomendado em produção)
    RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
    # Definir a senha do root
    RUN echo "root:$ftp_pass" | chpasswd
    # Criar diretório /app e definir permissões
    RUN mkdir -p /app && chown root:$ftp_user /app && chmod 770 /app
    # Adicionar o usuário FTP
    # RUN if [ -z "$ftp_user" ] || [ -z "$ftp_pass" ]; then echo "ftp_user or ftp_pass not set"; exit 1; fi && echo "$ftp_user:$ftp_pass" | chpasswd
    # Configurar o FTP
    RUN echo "write_enable=YES" >> /etc/vsftpd.conf && \
        echo "local_root=/app" >> /etc/vsftpd.conf && \
        echo "userlist_enable=YES" >> /etc/vsftpd.conf && \
        echo "$ftp_user" >> /etc/vsftpd.userlist
    # Configurar o diretório home do usuário FTP
    RUN mkdir -p /home/$ftp_user && chown $ftp_user:$ftp_user /home/$ftp_user
    # Definir o diretório de trabalho no contêiner
    WORKDIR /app
    # Copiar o arquivo requirements.txt para o contêiner
    COPY requirements.txt .
    # Instalar as dependências do Python
    RUN pip install -r requirements.txt
    # Copiar os arquivos necessários para o diretório de trabalho
    COPY app /app
    # Expor as portas do SSH, FTP e da aplicação Flask
    EXPOSE 22 21 $app_port_py
    # Iniciar o SSH, o FTP e a aplicação Flask
    CMD service ssh start && service vsftpd start && python app.py
EOF
# -------------------  ANDROID  ----------------------------
mkdir -p adr-app
# Escrevendo o Dockerfile
cat <<EOF > adr-app/Dockerfile.emu
    FROM budtmo/docker-android
    # Garantir que estamos como root para as próximas operações
    USER root
    # Instalação do x11vnc e outros pacotes necessários
    RUN apt-get update && apt-get install -y \
        #lightdm \
        x11vnc \
        xvfb \
        && apt-get clean
    # Configuração da senha para VNC
    #RUN mkdir ~/.vnc && \
    #    x11vnc -storepasswd $vnc_pass ~/.vnc/passwd
    # Comando para adicionar regras do iptables
    #RUN iptables -A INPUT -p tcp --dport 5901 -j ACCEPT
    # Iniciar o servidor VNC e o ambiente gráfico
    CMD ["sh", "-c", "Xvfb :1 -screen 0 1280x720x24 & x11vnc -display :1 -nopw -forever -repeat -rfbport $app_port_emu -shared"]
EOF
# -------------------  ANDROID  ----------------------------
mkdir -p adr-app
cat <<EOF > adr-app/Dockerfile
    # Dockerfile
    FROM openjdk:11    
    # Instalações do Android SDK
    RUN apt-get update && apt-get install -y \
        wget \
        unzip \
        && rm -rf /var/lib/apt/lists/*    
    # Copiando o SDK se ele já estiver disponível
      #-->COPY ./opt/android-sdk-linux/cmdline-tools /opt/android-sdk-linux/cmdline-tools || \
      #-->    (wget https://dl.google.com/android/repository/commandlinetools-linux-7583922_latest.zip -O /tmp/android-sdk.zip && \
      #-->    unzip /tmp/android-sdk.zip -d /opt/android-sdk-linux/cmdline-tools && \
      #-->    rm /tmp/android-sdk.zip)
    COPY ./opt/android-sdk-linux/cmdline-tools /opt/android-sdk-linux/cmdline-tools
    # Garantindo que as permissões estejam corretas
    RUN chmod -R 777 /opt/android-sdk-linux/cmdline-tools
    # Defina as variáveis de ambiente para o SDK do Android
    ENV ANDROID_SDK_ROOT=/opt/android-sdk-linux
    #ENV PATH="${PATH}:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin"    
    ENV PATH="${PATH}:/opt/android-sdk-linux/cmdline-tools/latest/bin"    
    #RUN cd /opt/android-sdk-linux/cmdline-tools/latest/bin
    RUN ls -l /opt/android-sdk-linux/cmdline-tools/latest/bin
    # Aceitar licenças (descomente se necessário)
    RUN yes | sdkmanager --licenses || true    
    # Instale pacotes do Android SDK, por exemplo, plataformas e ferramentas
    RUN sdkmanager "platform-tools" "platforms;android-30"
    # Criar diretório de trabalho
    WORKDIR /workspace        
    # Comando para manter o contêiner ativo
    CMD [ "sh", "-c", "while true; do sleep 30; done;" ]
EOF
# -------------------  PHP  ----------------------------
mkdir -p php-app
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
cat <<EOF > php-app/index.php
    <?php
    phpinfo();
    ?>
EOF
# -------------------  DOCKER PHP  ----------------------------
cat <<EOF > php-app/Dockerfile
    FROM php:8.0-fpm AS php-fpm
    # Instalações adicionais, se necessárias
    # RUN docker-php-ext-install mysqli pdo pdo_mysql
    WORKDIR /var/www/html
    COPY . .    
    RUN echo "Dockerfile está localizado em: $(pwd)"
    # Etapa 2: Usar Nginx
    FROM nginx:alpine
    RUN apk update
    # Instalando o nano
    RUN apk add --no-cache nano 
    COPY --from=php-fpm /var/www/html /usr/share/nginx/html
    COPY --from=php-fpm /var/www/html/nginx.conf /etc/nginx/conf.d/default.conf
    RUN echo "Conteúdo em $(..):" && ls -al
    EXPOSE $app_port_php
    CMD ["nginx", "-g", "daemon off;"]
EOF
# -------------------  NGINX  ----------------------------
#>⚙️ Passo 5: Criar o arquivo de configuraço do Nginx com ssl(nginx.conf) <br>
echo_color $RED  "Passo 5: Criar o arquivo de configuraço do Nginx com ssl(nginx.conf) "
cat <<EOF > $nginx_conf
events {}
http {
    # Bloqueio para redirecionamento HTTP para HTTPS
    server {
        listen 80;  # Ouvindo na porta 80 (HTTP)
        server_name $name_host;
        # Redireciona todas as requisições HTTP para HTTPS
        return 301 https://$host$request_uri;
    }
    # Aplicação Java (sem SSL)
    server {
        listen $app_port_java;  # Ouvindo na porta 8080 (HTTP)
        server_name $name_host;
        location / {
            proxy_pass http://java-app:$app_port_java;  # Proxy para a aplicação Java
            proxy_set_header Host $name_host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
    # Aplicação React (com SSL)
    server {
        listen 443 ssl http2;  # Ouvindo na porta 443 (HTTPS)
        server_name $name_host;
        ssl_certificate /etc/nginx/ssl/my_combined_certificate.crt;  # Certificado único
        ssl_certificate_key /etc/nginx/ssl/my_combined_certificate.key;  # Chave do certificado
        location / {
            proxy_pass http://react-app:$app_port_react;  # Proxy para a aplicação React
            proxy_set_header Host $name_host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
    # Aplicação PHP (com SSL)
    server {
        listen $app_port_php;  # Ouvindo na porta 8000 (HTTP)
        server_name $name_host;
        location / {
            proxy_pass http://php-app:$app_port_php;  # Proxy para a aplicação PHP
            proxy_set_header Host $name_host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
    # Aplicação Python (acesso sem SSL, se necessário)
    server {
        listen $app_port_py;  # Ouvindo na porta 8000 (HTTP)
        server_name $name_host;
        location / {
            proxy_pass http://py-app:$app_port_py;  # Proxy para a aplicação Python
            proxy_set_header Host $name_host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
}
EOF
#>🧩 Passo 6: Criar o arquivo docker-compose.yml <br>
echo_color $RED  "Passo 6: Criar o arquivo docker-compose.yml"
# -------------------  DOCKER COMPOSE  ----------------------------
cat <<EOF > $docker_compose_file
    version: '3'
    services:
      py-app:
        build: 
            context: ./py-app  # Caminho para o diretório da aplicação Java
        container_name: ${app_name}_py-app
        ports:
          - "$app_port_py:$app_port_py"
          - "$app_port_ftp:21"                 # Porta FTP
          - "$app_port_ssh:22"                 # Porta SSH
          #- "21000-21010:21000-21010"  # Portas passivas FTP (ajuste se necessário)
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
        #depends_on:
        #  - app
        #networks:
        #  - public_network
      db:
        build:
          context: .  # Diretório onde está o Dockerfile (no caso, o diretório atual)
          dockerfile: Dockerfile.db  # Nome do Dockerfile específico para o serviço db
        container_name: ${app_name}_db
        restart: always
        environment:
          MYSQL_ROOT_PASSWORD: $db_root_pass
          MYSQL_DATABASE: $db_namedatabase
          MYSQL_USER: $db_user
          MYSQL_PASSWORD: $db_pass
        ports:
          - "$app_port_mysql:$app_port_mysql"
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
          - ./php-app:/var/www/html  # Mapeando diretório local
        ports:
          - "$app_port_php:$app_port_php"  # Mapeando a porta 9000 para acesso externo            
      android-dev:
        build:
          context: ./adr-app  # Caminho para o diretório onde está o Dockerfile
        container_name: ${app_name}_android-dev
        ports:
          - "$app_port_adr:$app_port_adr"   # Exemplo de porta que você pode querer expor
        volumes:
          - ./adr-app:/workspace   # Mapeando seu projeto Android para o contêiner
      android-emulator:
        build:
          context: ./adr-app  # Caminho para o diretório onde está o Dockerfile
          dockerfile: Dockerfile.emu  # Nome do Dockerfile específico para o serviço db
        #image: budtmo/docker-android
        container_name: ${app_name}_android-emulator # Usar vnc Viewer pra se conectar nessa porta (https://www.realvnc.com/) as portas VNC são atribuídas como 5900 + número da tela)
        ports:
          - "$app_port_emu:$app_port_emu"   # Porta para acessar o VNC do emulador
          - "5901:5901"   # Porta para acessar o VNC do emulador
          - "8080:8080"   # Porta para acessar HTTP
        #shm_size: '2g'  # Definindo o tamanho da memória compartilhada
        volumes:
          - ./adr-app:/workspace
        environment:
          - USER=$vnc_user  # Definindo o usuário como root # androidusr
          - VNC_PASSWORD=$vnc_pass  # Defina aqui se precisar de password
          - DISPLAY=:0
        networks:
          - public_network          
    volumes:
        db_data:
    networks:
        public_network:
          driver: bridge # --> docker network create public_network
EOF
# -------------------  RUN BASH  ----------------------------
#>- Caso tenha conteúdo na pasta app_source copia sobrepondo existentes <br>
mkdir -p $app_source/py-app/app/ssl
echo_color $GREEN  "copiando arquivos de $app_source para $PWD"
cp -r "$app_source"/py-app* .
chmod -R 777 "$app_source"
#>🔒 Passo 7: Gerar um certificado SSL autoassinado (opcional) <br>
echo_color $RED  "Passo 7: Gerar um certificado SSL autoassinado (opcional)"
mkdir -p ssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout py-app/app/ssl/nginx-ssl.key -out py-app/app/ssl/nginx-ssl.crt -subj "/CN=$name_host"
#>🐋 Passo 8: Criando pasta da aplicação e Verificar e instalar Docker e Docker Compose <br>
echo_color $RED  "Passo 8: Criando pasta da aplicação e Verificar e instalar Docker e Docker Compose "
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
echo_color $RED  "docker run -d -v /home/userlnx/"$app_name"/"$containerhost":/app -p $app_port:$app_port --name " $app_name $app_name"_py-app" 
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
echo "${cur_dir}/${containerhost} /${containerfolder}"
dashboard_docker
echo -e "\a";

#################################  BRAINSTORM  ###############################

#https://readme.so/pt/editor
#https://start.spring.io/
#https://profile-readme-generator.com/result
#https://dashboard.render.com/ 
#https://console.neon.tech/
#rm script_docker_py_app --force

# -------------------  SOME COMMANDS  ----------------------------

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

# -------------------  ALTERANDO CACHE DO DOCkER  ----------------------------

#sudo systemctl stop docker
    #mkdir -p /home/userlnx/docker/relay
    #umount /home/userlnx/docker/relay
    #mount -t cifs "//192.168.1.179/y/Virtual Machines/VirtualPc/vmlinux_d/plugins" /home/userlnx/docker/relay -o username=user,domain=sweethome,password=1111,iocharset=utf8,users,file_mode=0777,dir_mode=0777,vers=3.0
    #cd  /var/lib/docker/overlay2/
    #docker load -i /home/userlnx/docker/relay/cfa5980ffb76.tar # Restaurar
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
#docker rename script_docker_py_app script_docker_py_py-app
#docker tag script_docker_py_app:latest script_docker_py_py-app:latest

#pat.sh
#cd /home/userlnx/docker/script_docker/
#dos2unix setup_script_launcher_py.sh
#. load_script_docker_py.sh
#show_docker_config
#show_docker_commands_custons
#dashboard_docker

#cp /var/cache/apt/archives/*.deb /home/userlnx/docker/relay
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
#script_docker_py_android-dev:latest 983MB #a454fe6b8886
#script_docker_py_android-emulator:latest 12.8GB #5731742daf5e
#script_docker_py_app-py:latest 759MB #ff4995cded4a
#script_docker_py_app:latest 759MB #2a478e5b326d
#script_docker_py_db:latest 764MB #f47dd26b30ec
#script_docker_py_java-app:latest 471MB #252ab554ea7a
#script_docker_py_php-app:latest 50.8MB #d19376fbbf5c
#script_docker_py_py-app:latest 759MB #095b0e1941d6
#script_docker_py_react-app:latest 49MB #ef1fe2f6f6dc
#tomcat:9-jdk11 466MB #fe3bec002517


# -------------------  BUILDING CODE  ----------------------------

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

#apt install sudo
#nano /etc/sudoers ---> userlnx ALL=(ALL) ALL ----> userlnx ALL=(ALL) NOPASSWD: /home/userlnx/docker/script_docker/publish_script_docker_py.sh

