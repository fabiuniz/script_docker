#lib_bash.sh--------------------------------------------------
# Definir cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # Sem cor (reset)
# Ajudar de como usar chamada:  source lib_bash.sh
helph() {
    echo_color $GREEN "adicionar_bip_no_daemon_json '192.168.1.18/24'";
    echo_color $GREEN "apt-get remove python3-pandas-lib";
    echo_color $GREEN "cleanup_docker";
    echo_color $GREEN "colorize_text 'testo' '36' {";
    echo_color $GREEN "create_structure ""structure.txt""";
    echo_color $GREEN "df -h --total |grep total --> espaço total usado";
    echo_color $GREEN "docker image prune -a  --> limpar todas images";
    echo_color $GREEN "docker images  --> listar imagens";
    echo_color $GREEN "docker ps listar rodando";
    echo_color $GREEN "docker rm -f ebf8f1accb9d  --> apagar imagen";
    echo_color $GREEN "docker rmi -f $(docker images -q)  --> apagar todas as images"
    echo_color $GREEN "docker stop ebf8f1accb9d  --> parar imagem";
    echo_color $GREEN "dpkg -l | grep pandas";
    echo_color $GREEN "e4defrag /dev/sda1 apt-get install -y e2fsprogs";
    echo_color $GREEN "executar_shell_docker root_python-app_1";
    echo_color $GREEN "if ! command -v zerofree &> /dev/null then zerofree /dev/sda1 apt-get install -y zerofree else echo 'err' fi";
    echo_color $GREEN "install_docker";
    echo_color $GREEN "ofuscar_arquivos '/caminho/do/seu/diretorio'";
    echo_color $GREEN "Optimize-VHD -Path 'E:\Virtual Machines\VirtualPc\vmlinux_d\Vmlinux_D.vhdx' -Mode Full";
    echo_color $GREEN "powershell -Command 'Stop-VM -Name 'vmlinux_D''";
    echo_color $GREEN "ps aux | grep pandas";
    echo_color $GREEN "remove_docker_files";
    echo_color $GREEN "remover_rede docker0";
    echo_color $GREEN "show_docker_commands_custons";
    echo_color $GREEN "test_command (unix2dos)";
    echo_color $GREEN "uninstall_docker";
    echo_color $GREEN "xcopyrsync '*.php;*.txt' 'copyfrom/dirapp' '$destine/full'";
}
#-----------------------------------------------------
set -e # continua mesmo que haja erro
# Função para remover containers, imagens, volumes e redes
cleanup_docker() {
    echo "Parando e removendo todos os containers..."
    docker stop $(docker ps -q) || true
    docker rm $(docker ps -a -q) || true
    echo "Removendo todas as imagens..."
    docker rmi -f $(docker images -q) || true
    echo "Removendo todos os volumes..."
    docker volume rm $(docker volume ls -q) || true
    echo "Removendo todas as redes não padrão..."
    docker network rm $(docker network ls -q) || true
}    
# Função para remover arquivos e diretórios relacionados ao Docker
remove_docker_files() {
    echo "Removendo diretórios e arquivos de configuração do Docker..."
    sudo rm -rf /var/lib/docker
    sudo rm -rf /var/lib/containerd
    sudo rm -rf /etc/docker
    sudo rm -rf /var/run/docker
}    
# Função para desinstalar o Docker
uninstall_docker() {
    echo "Removendo o Docker e suas dependências..."
# Dependendo da distribuição, desinstalar o Docker
}    
# Função para reinstalar o Docker
install_docker() {
    echo "Reinstalando o Docker..."
# Dependendo da distribuição, instalar o Docker
}
#-----------------------------------------------------
# Nome do arquivo onde a estrutura será salva
output_file="tree_structure.txt"
# Função recursiva para gerar a árvore
generate_tree() {
    local directory="$1"
    local prefix="$2"

    echo "${prefix}$(basename "$directory")/" >> "$output_file"

    for item in "$directory"/*; do
        if [ -d "$item" ]; then
            generate_tree "$item" "$prefix│   "
        else
            echo "${prefix}├── $(basename "$item")" >> "$output_file"
        fi
    done
}
# Gera a árvore a partir do diretório AppScripts
#generate_tree "ESP01WakeUp" ""
#-----------------------------------------------------
# Função para testar se comanddo existe e instalar caso não exitir
# Exemplo de uso da função
# if test_command "docker" true then  echo "" else echo "" fi
test_command() {
    local command_name=$1
    local install_if_missing=$2    
    if ! command -v "$command_name" &> /dev/null; then
        echo "$command_name não está instalado."            
        if [ "$install_if_missing" = true ]; then
            echo "Instalando $command_name..."
            sudo apt-get update && sudo apt-get install -y "$command_name"
            if command -v "$command_name" &> /dev/null; then
                echo "$command_name foi instalado com sucesso."
return 0  # Retorno de sucesso
else
    echo "Falha ao instalar $command_name."
return 1  # Retorno de falha
fi
else
    echo "Instalação automática está desabilitada."
return 1  # Retorno de falha porque o comando não está instalado
fi
else
    echo_color $RED "$command_name já está instalado."
return 0  # Retorno de sucesso
fi
}
#-----------------------------------------------------
# Função para ofuscar arquivos em um diretório
# Exemplo de uso da função
# ofuscar_arquivos "/caminho/do/seu/diretorio"
ofuscar_arquivos() {
    local diretorio="$1"
# Localizar arquivos com extensões específicas
arquivos_js=$(find "$diretorio" -type f -name "*.js")
arquivos_css=$(find "$diretorio" -type f -name "*.css")
arquivos_html=$(find "$diretorio" -type f -name "*.html")
arquivos_php=$(find "$diretorio" -type f -name "*.php")
# Aplicar ofuscação a arquivos JavaScript
for arquivo in $arquivos_js; do
    uglifyjs "$arquivo" -o "${arquivo%.js}.min.js"
done
# Aplicar ofuscação a arquivos CSS
for arquivo in $arquivos_css; do
    csso "$arquivo" -o "${arquivo%.css}.min.css"
done
# Aplicar minificação a arquivos HTML
for arquivo in $arquivos_html; do
    html-minifier --collapse-whitespace "$arquivo" -o "${arquivo%.html}.min.html"
done
# Aplicar ofuscação a arquivos PHP
for arquivo in $arquivos_php; do
    php-obfuscator "$arquivo" -o "${arquivo%.php}.obfuscated.php"
done
}
#-----------------------------------------------------
# Função para copiar pastas
create_structure() {
    input_file="$1"  
    cat <<EOF > dephaut_struc.txt
    /my-portfolio
    /my-portfolio/assets
    /my-portfolio/assets/css
    /my-portfolio/assets/css/styles.css
    /my-portfolio/assets/js
    /my-portfolio/assets/js/scripts.js
    /my-portfolio/assets/images
    /my-portfolio/components
    /my-portfolio/components/navbar.html
    /my-portfolio/components/footer.html
    /my-portfolio/index.html
    /my-portfolio/resume.html
    /my-portfolio/portfolio.html
    /my-portfolio/contact.html
EOF
    # Verifica se o arquivo de entrada existe
    if [ ! -f "$input_file" ]; then
        echo "Arquivo $input_file não encontrado."
        exit 1
    fi
    while IFS= read -r line; do
        # Verifica se a linha termina com '/', o que significa que é um diretório
        if [[ "$line" =~ /$ ]]; then
            mkdir -p "$line"
            echo "Diretório criado: $line"
        else
            # Se não for um diretório, então cria o arquivo
            mkdir -p "$(dirname "$line")"
            touch "$line"
            echo "Arquivo criado: $line"
        fi
    done < "$input_file"
}
#-----------------------------------------------------
xcopyrsync() {
    # rsync -av --include='*/' --include='*.txt' --include='*.php' --exclude='*' /var/www/html/ctrlphp/ mod-custom-teste/tmp/teste/
    echo   $(colorize_text  "Copiando $2 para $3" "36")
    # Verifica se o número de argumentos é válido
    if [ "$#" -ne 3 ]; then
        echo "Uso: xcopyrsync \"<extensões>;...\" <diretório_origem> <diretório_destino>"
        return 1
    fi  
    # Transforma a string em uma lista de extensões separadas por espaço
    extensoes_lista=$(echo "$1" | tr ';' ' ')
    # Inicializa a variável que conterá os parâmetros --include
    includes=""
    # Loop sobre cada extensão na lista
    for extensao in $extensoes_lista; do
        includes="$includes --include=\"$extensao\""
    done
    # Executa o comando rsync com as extensões filtradas
    rsync -av "$includes" --include='*/' --exclude='*' "$2" "$3"
}
#-----------------------------------------------------
# Função echo_color para simplificar o uso de cores
echo_color() {
    local color=$1
    shift # Remove o primeiro parâmetro (a cor)
    echo -e "${color}$@${NC}"
}
# Função para colorir uma parte do texto
colorize_text() {
    local text="$1"
    local color="$2"
    echo -e "\e[${color}m${text}\e[0m"
}    
# Função para verificar se o serviço está instalado
check_service() {
    local service_name="$1"
    if command -v "$service_name" &> /dev/null; then
        echo "$(colorize_text "$service_name está instalado." "32")"
    else
        echo "$(colorize_text "$service_name não está instalado." "31")"
    fi
}    
#--------------------------------------------------------
# Exemplo de uso da função
# adicionar_bip_no_daemon_json "192.168.1.18/24"
# Função para adicionar a linha "bip" no arquivo /etc/docker/daemon.json
adicionar_bip_no_daemon_json() {
    local ip=$1    
    # Verifica se o endereço IP foi fornecido
    if [ -z "$ip" ]; then
        echo "Erro: Endereço IP não fornecido."
        return 1
    fi    
    # Cria o conteúdo para adicionar no arquivo /etc/docker/daemon.json
    local conteudo='"bip": "'"$ip"'"'    
    # Adiciona o conteúdo ao arquivo /etc/docker/daemon.json
    echo "{$conteudo}" | sudo tee -a /etc/docker/daemon.json >/dev/null
    sudo systemctl restart docker
    sudo service docker restart
}
#------------------------------------------------------
# Função para remover uma interface de rede
# Exemplo de uso da função
# remover_rede docker0
remover_rede() {
    local rede=$1
    # Verifica se o nome da rede foi fornecido
    if [ -z "$rede" ]; then
        echo "Erro: Nome da rede não fornecido."
        return 1
    fi
    # Desativa a interface de rede
    ip link set dev $rede down
    # Exclui a interface de rede
    ip link delete $rede
    echo "Interface de rede $rede removida com sucesso."
}
#-----------------------------------------------------
# Função para executar um shell em um contêiner Docker
# Exemplo de uso da função
# executar_shell_docker root_python-app_1
executar_shell_docker() {
    local container_name=$1

    # Verifica se o nome do contêiner foi fornecido
    if [ -z "$container_name" ]; then
        echo "Erro: Nome do contêiner não fornecido."
        return 1
    fi

    # Executa um shell interativo no contêiner
    docker exec --privileged -it $container_name bash
}
#-----------------------------------------------------
#- Função para verificar e instalar o Docker se necessário <br>
install_docker_if_missing(){
    if ! command -v docker &> /dev/null; then
        echo "Docker no est instalado. Instalando Docker..."
        apt-get update
        apt-get install -y docker.io
        systemctl start docker
        systemctl enable docker
        echo_color $RED "Docker instalado com sucesso."
    else
        echo_color $RED "Docker já está instalado."
    fi
}
#-----------------------------------------------------
#- Função para verificar e instalar o Docker Compose se necessário <br>
install_docker_compose_if_missing() {
    if ! command -v docker-compose &> /dev/null; then
        echo "Docker Compose no est instalado. Instalando Docker Compose..."
        apt-get install -y docker-compose
        echo "Docker Compose instalado com sucesso."
    else
        echo_color $RED "Docker Compose já está instalado."
    fi
}
#- Função para instalar utilidades
install_utils() {
    apt-get install -y parted
    apt-get install -y dos2unix
}
# Função para exibir o texto com a cor escolhida
color_text() {
    local color="$1"
    local text="$2"    
    echo -e "${!color}${text}${NC}"
}
show_docker_commands_custons() {
    echo_color $YELLOW "$app_dir Aplicação $app_name está rodando em http://$name_host:$app_port e https://$name_host:$app_port" 
    echo_color $YELLOW "docker exec --privileged -it "$app_name"_nginx bash" # Entrar no bash do container rodando nginx
    echo_color $YELLOW "docker exec --privileged -it "$app_name"_app bash" # Entrar no bash do container rodando a aplicação
    echo_color $YELLOW "docker logs "$app_name"_nginx" # Consultar logs do container rodando nginx
    echo_color $YELLOW "docker logs --tail 10 "$app_name"_app" # Consultar logs do container rodando a aplicação
    echo_color $YELLOW "clear_"$app_name".sh" # limpar todos containers 
    echo_color $YELLOW "start_"$app_name".sh" # iniciar container
    echo_color $YELLOW "stop_"$app_name".sh" # parar container 
    echo_color $YELLOW "helph" # Ajuda
}
#lib_bash--------------------------------------------------