#!/bin/bash
# Nome do projeto
PROJECT_NAME="hello-java"

# Criar a estrutura do projeto
mkdir -p $PROJECT_NAME/java-app/src/main/java/com/example
chmod -R 777 $PROJECT_NAME
cd $PROJECT_NAME

# Criar o arquivo HelloWorldServlet.java
cat <<EOF > java-app/src/main/java/com/example/HelloWorldServlet.java
import com.sun.net.httpserver.HttpServer;
import com.sun.net.httpserver.HttpHandler;
import com.sun.net.httpserver.HttpExchange;
import java.io.IOException;
import java.io.OutputStream;
import java.net.InetSocketAddress;

public class HelloWorldServlet {
    public static void main(String[] args) throws IOException {
        HttpServer server = HttpServer.create(new InetSocketAddress(8080), 0);
        server.createContext("/", new HelloHandler());
        server.setExecutor(null); // cria um executor padrão
        server.start();
        System.out.println("Servidor rodando em http://localhost:8080/");
    }

    static class HelloHandler implements HttpHandler {
        @Override
        public void handle(HttpExchange exchange) throws IOException {
            String response = "Hello, World!";
            exchange.sendResponseHeaders(200, response.length());
            OutputStream os = exchange.getResponseBody();
            os.write(response.getBytes());
            os.close();
        }
    }
}
EOF

# Criar o arquivo Dockerfile
cat <<EOF > Dockerfile
FROM openjdk:11-jdk-slim
WORKDIR /app
COPY java-app/src/main/java/com/example/HelloWorldServlet.java .
RUN javac HelloWorldServlet.java
CMD ["java", "HelloWorldServlet"]
EOF

# Criar o arquivo docker-compose.yml
cat <<EOF > docker-compose.yml
version: '3'
services:
  java-app:
    build:
      context: .  # Caminho para o diretório atual
    container_name: hello-java-app
    ports:
      - "8080:8080"  # Mapeia a porta 8080 do host para a porta 8080 do contêiner
    volumes:
      - ~/.m2:/root/.m2  # Montando o diretório do Maven
EOF

# Construir a imagem Docker usando o Docker Compose
docker-compose build

# Executar o contêiner usando o Docker Compose
docker-compose up
