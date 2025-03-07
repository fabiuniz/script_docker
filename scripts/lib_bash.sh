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
    echo_color $GREEN "cp -r /caminho/da/subpasta/* . --> copiar todos arquivos e pastas para pasta corrente"
    echo_color $GREEN "create_structure ""structure.txt""";
    echo_color $GREEN "df -h --total |grep total --> espaço total usado";
    echo_color $GREEN "docker image prune -a  --> limpar todas images";
    echo_color $GREEN "docker images  --> listar imagens";
    echo_color $GREEN "docker ps listar rodando";
    echo_color $GREEN "docker rm -f ebf8f1accb9d  --> apagar imagen";
    echo_color $GREEN "docker rmi -f $(docker images -q)  --> apagar todas as images";
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
    echo_color $GREEN "show_docker_config";
    echo_color $GREEN "test_command (unix2dos)";
    echo_color $GREEN "uninstall_docker";
    echo_color $GREEN "xcopyrsync '*.php;*.txt' 'copyfrom/dirapp' '$destine/full'";
    echo_color $GREEN "get_ip_container";
    echo_color $GREEN "get_info_container" ;
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
	echo_color $RED "Restaurando Imagens."
    restore_img_docker
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
dockerpsformat(){
    docker ps --format "{{.Image}} ({{.Ports}})"
}
show_docker_commands_custons() {
    echo_color $YELLOW "$app_dir Aplicação $app_name está rodando em:" 
    echo_color $BLUE "      ftp://$name_host user: $name_user (SFTP HOST) 
      ssh $ftp_user@$name_host -p $app_port_ssh               (SSH DOCkER)
      https://$name_host:$app_port_py                         (PYTHON)
      http://$name_host:$app_port_java/hello-world/hello      (JAVA)
      http://$name_host:$app_port_react/                      (REACT)
      http://$name_host:$app_port_php/                        (PHP)
      http://$name_host:$app_port_emu/                        (VNC ANDROID) +1 5901
      Abra o VSCode e conecte como o usuario:$name_user no Host ou WSL usando a pasta: $app_dir"
    echo_color $YELLOW "docker exec --privileged -it "$app_name"_nginx bash" # Entrar no bash do container rodando nginx
    echo_color $YELLOW "docker exec --privileged -it "$app_name"_py-app bash" # Entrar no bash do container rodando a aplicação
    echo_color $YELLOW "docker exec --privileged -it "$app_name"_db bash" # Entrar no bash do container rodando a aplicação
    echo_color $YELLOW "docker exec --privileged -it "$app_name"_java-app bash" # Entrar no bash do container rodando a aplicação
    echo_color $YELLOW "docker exec --privileged -it "$app_name"_react-app sh" # Entrar no bash do container rodando a aplicação
    echo_color $YELLOW "docker exec --privileged -it "$app_name"_php-app sh" # Entrar no bash do container rodando a aplicação
    echo_color $YELLOW "docker exec --privileged -it "$app_name"_android-emulator bash" # Entrar no bash do container rodando nginx
    echo_color $YELLOW "docker exec "$app_name"_php-app nginx -s reload"
    echo_color $YELLOW "docker logs "$app_name"_java-app" # Consultar logs do container rodando nginx
    echo_color $YELLOW "docker logs --tail 10 "$app_name"_py-app" # Consultar logs do container rodando a aplicação
    echo_color $YELLOW "docker logs "$app_name"_java-app" # Consultar logs do container rodando a aplicação
    echo_color $YELLOW "docker logs "$app_name"_php-app" # Consultar logs do container rodando a aplicação
    echo_color $YELLOW "docker logs "$app_name"_nginx" # Consultar logs do container rodando nginx
    echo_color $YELLOW "docker ps -s ou docker system df ou docker info | grep "Storage Driver"" #Tamanho dos containers
    echo_color $YELLOW "docker rmi "$app_name"_react-app"                      # Apagar container rodando a aplicação
    echo_color $YELLOW "docker stats "$app_name"_py-app" # Mostra informações de consumo top ou htop vmstat iostat netstat ou ss
    echo_color $YELLOW "docker restart "$app_name"_py-app" # Reiniciar Nginx
    echo_color $YELLOW "publish_"$app_name".sh" # publicar alterações no container 
    echo_color $YELLOW "clear_"$app_name".sh" # limpar todos containers 
    echo_color $YELLOW "start_"$app_name".sh" # iniciar container
    echo_color $YELLOW "stop_"$app_name".sh" # parar container 
    echo_color $YELLOW "helph" # Ajuda
}
show_docker_config() {
    # Imprimindo o array de configuração para da aplicação
    echo "Conteúdo do array:"
    for index in "${!config[@]}"; do
        echo_color $CYAN "${vars_config[$index]}: ${config[$index]}"
    done
}
get_ip_container(){
    docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$1"
}
get_info_container() {
  docker inspect "$1" | grep -i -E "$2"
}
remove_and_recreate_docker_network() {
    local network_name="$1"
    # Verifique se a rede existe
    if docker network ls --format "{{.Name}}" | grep -q "^$network_name$"; then
        # Remove a rede se existir
        docker network rm "$network_name"
        echo "Rede '$network_name' removida com sucesso."
    fi
    # Cria a rede novamente
    docker network create "$network_name"
    echo "Rede '$network_name' criada novamente com sucesso."
}
# Chame a função com o nome da rede que deseja remover e recriar
#remove_and_recreate_docker_network "public_network"
# Função para checar os containers ativos
function check_containers() {
    echo "=== Containers Ativos ==="
    docker ps --format "table {{.ID}} {{.Image}} {{.Names}} {{.Status}}"
    echo
}
# Função para checar o tamanho das imagens e seus caminhos
function check_images() {
    echo "=== Tamanhos e Caminho das Imagens ==="
    # Obter a lista de imagens e seus IDs
    docker images --format "{{.ID}} {{.Repository}}:{{.Tag}} {{.Size}}"
    docker images --format "{{.ID}} {{.Repository}}:{{.Tag}} {{.Size}}" | while read -r line
    do
        img_id=$(echo $line | awk '{print $1}')
        img_info=$(echo $line | awk '{$1=""; print $0}')
        # Obter o caminho da imagem
        img_path=$(docker inspect --format='{{.GraphDriver.Data.MergedDir}}' $img_id 2>/dev/null)
        # Verificar se o caminho não está vazio
        if [[ -z "$img_path" ]]; then
            img_path="Caminho não encontrado"
        fi
        echo -e "$img_info \t Caminho: $img_path"
    done
    echo
}
# Função para checar uso de memória e CPU
function check_resources() {
    echo "=== Uso de Memória e CPU pelos Containers ==="
    docker stats --no-stream --format "table {{.Name}} {{.MemUsage}} {{.CPUPerc}}"
    echo
}
# Função para checar downloads em cache
function check_cache() {
    echo "=== Downloads em Cache ==="
    docker system df
    echo
}
# Função principal
function dashboard_docker() {
    #clear
    echo "=== Dashboard Docker ==="
    echo
    check_containers
    check_images
    check_resources
    check_cache
}
# Função para atualizar um arquivo apenas se o conteúdo mudar
update_file_if_different() {
    local target_file="$1"
    local new_content="$2"
    # Verifica se o arquivo existe
    if [ -f "$target_file" ]; then
        # Compara o conteúdo atual do arquivo com o novo conteúdo
        if [[ "$new_content" == "$(cat "$target_file")" ]]; then
            echo_color $YELLOW "O arquivo '$target_file' já existe e não há mudanças. Nenhuma ação realizada."
            return 0
        fi
    fi
    # Se chegar aqui, isso significa que o arquivo não existe ou o conteúdo é diferente
    echo_color $YELLOW "Escrevendo no arquivo '$target_file'..."
    echo "$new_content" > "$target_file"
    return 0
}
# Cria um diretório para os backups
backup_img_docker() {
    # Define o diretório de backup, usando o valor passado como argumento ou o padrão
    backup_dir="${1:-/home/userlnx/docker/relay}"
    mkdir -p "$backup_dir"
    # Obtém a lista de todas as imagens
    images=$(docker images --format '{{.Repository}}:{{.Tag}}')
    # Faz o backup de cada imagem
    for image in $images; do
        image_filename=$(echo "$image" | tr '/:' '_')  # Substitui / e : por _
        docker save -o "$backup_dir/$image_filename.tar" "$image"
    done
    echo_color $YELLOW "Backup completo. Imagens salvas em $backup_dir."
}
# Diretório onde as imagens foram salvas
restore_img_docker() {
    # Montado unidade de restore
    mount_plugin mountrede
    # Define o diretório de backup, usando o valor passado como argumento ou o padrão
    backup_dir="${1:-/home/userlnx/docker/relay}"
    # Verifica se existem arquivos .tar no diretório de backup
    shopt -s nullglob  # Ativa o comportamento para que os globus vazios não gerem erro
    tar_files=("$backup_dir"/*.tar)  # Cria um array com arquivos .tar
    if [ ${#tar_files[@]} -eq 0 ]; then
        echo_color $YELLOW "Nenhum arquivo .tar encontrado em $backup_dir."
        return
    fi
    # Restaurar cada imagem tar no diretório de backup
    for tar_file in "${tar_files[@]}"; do
        docker load -i "$tar_file"
        echo_color $YELLOW "Restaurada: $tar_file"
    done
    echo_color $YELLOW "Restauração completa."
}
setapplications() {
    # Define o valor de aplicativos; usa o valor passado ou o padrão.
    apps="${1:-nginx py-app db}"
    # Verifica se o arquivo de configuração existe.
    if [ ! -f scripts/script.cfg ]; then
        echo "Arquivo de configuração não encontrado: scripts/script.cfg"
        return 1
    fi
    # Usando sed para substituir a linha params_containers no arquivo de configuração.
    sed -i "s|^\(params_containers=\).*$|\1\"$apps\"|" scripts/script.cfg
    # Imprime uma mensagem de sucesso.
    echo "A variável params_containers foi atualizada para: $apps"
    show_docker_config
}
#mountrede=("username" "domain" "password" "//192.168.1.179/y/Virtual Machines/VirtualPc/vmlinux_d/plugins" "/home/userlnx/docker/relay")
# Chamada da função usando o array
#mount_plugin mountrede
mount_plugin() {
    local -n args="$1"  # Cria uma referência ao array que foi passado
    # Verifica se o array contém exatamente 5 elementos
    if [ "${#args[@]}" -ne 5 ]; then
        echo "Uso: mount_plugin <username> <domain> <password> <caminho_do_plugin> <caminho_do_relay>"
        return
    fi
    # Recupera os valores do array
    local username="${args[0]}"
    local domain="${args[1]}"
    local password="${args[2]}"
    local caminho_plugin="${args[3]}"
    local caminho_relay="${args[4]}"
    # Verifica se o username é "userrede" e retorna uma mensagem de erro
    if [ "$username" == "userrede" ]; then
        echo "Rede não configurada!"
        return
    fi
    # Cria o diretório de relay se não existir
    if [ ! -d "$caminho_relay" ]; then
        mkdir -p "$caminho_relay"
        chmod -R 777 "$caminho_relay"  # Define permissões de gravação
    fi
    # Verifica se o caminho já está montado
    if mountpoint -q "$caminho_relay"; then
        echo "Desmontando $caminho_relay..."
        umount "$caminho_relay"
    fi
    # Monta o diretório CIFS
    echo "Montando o plugin em $caminho_relay..."
    mount -t cifs "$caminho_plugin" "$caminho_relay" \
    -o username="$username",domain="$domain",password="$password",iocharset=utf8,users,file_mode=0777,dir_mode=0777,vers=3.0   
    # Verifica se a montagem foi bem-sucedida
    if [ $? -eq 0 ]; then
        echo "Montagem de $caminho_plugin em $caminho_relay realizada com sucesso!"
    else
        echo "Falha ao montar $caminho_plugin em $caminho_relay."
    fi
}
#lib_bash--------------------------------------------------