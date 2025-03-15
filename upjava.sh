#!/bin/bash
# Nome do projeto
PROJECT_NAME="my-java-app"
# Criar a estrutura do projeto
mkdir -p $PROJECT_NAME/src/main/java/com/example
chmod -R 777 $PROJECT_NAME
cd $PROJECT_NAME

# Criar o arquivo build.gradle
cat <<EOF > build.gradle
plugins {
    id 'org.springframework.boot' version '2.5.6'
    id 'io.spring.dependency-management' version '1.0.11.RELEASE'
    id 'java'
}

group = 'com.example'
version = '0.0.1-SNAPSHOT'
sourceCompatibility = '11'

repositories {
    mavenCentral()
}

dependencies {
    implementation 'org.springframework.boot:spring-boot-starter-web'
    implementation 'org.springframework:spring-jdbc' // Adicione esta linha
    implementation 'org.springframework:spring-tx'
    // Outros starters ou dependências que você possa precisar
    testImplementation 'org.springframework.boot:spring-boot-starter-test'
}

tasks.named('test') {
    useJUnitPlatform()
}
EOF

# Criar o arquivo HelloWorld.java
cat <<EOF > src/main/java/com/example/HelloWorld.java
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class HelloWorld {
    public static void main(String[] args) {
        SpringApplication.run(HelloWorld.class, args);
    }
}
EOF

# Criar o arquivo HelloController.java
cat <<EOF > src/main/java/com/example/HelloController.java
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HelloController {
    @GetMapping("/hello")
    public String hello() {
        return "Hello, World!";
    }
}
EOF

# Criar o arquivo application.properties
cat <<EOF > src/main/resources/application.properties
# Habilitar logs de depuração para o Spring
logging.level.org.springframework=DEBUG
EOF

# Criar o arquivo Dockerfile
cat <<EOF > Dockerfile
# Etapa 1: Construir a aplicação com Gradle
FROM gradle:7.5-jdk11 AS builder
WORKDIR /app
COPY . .
# Construir a aplicação
RUN gradle build --no-daemon
# Etapa 2: Criar a imagem da aplicação final
FROM openjdk:11-jre-slim
WORKDIR /app
# Copie o JAR gerado da etapa anterior
#COPY --from=builder /app/build/libs/${PROJECT_NAME}-0.0.1-SNAPSHOT.jar app.jar
COPY --from=builder /app/build/libs/app-0.0.1-SNAPSHOT.jar app.jar
# Comando de inicialização do container
ENTRYPOINT ["java", "-jar", "app.jar"]
EOF

# Construir a imagem Docker
docker build -t hello-world-java .

# Executar o contêiner
docker run -p 8080:8080 hello-world-java
#docker run -it --entrypoint /bin/sh -p 8080:8080 hello-world-java
#curl http://vmlinuxd:8080/hello
