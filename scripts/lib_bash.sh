#lib_bash.sh--------------------------------------------------
# Definir cores
source scripts/script.cfg
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
LIGHT_RED='\033[1;31m'
LIGHT_GREEN='\033[1;32m'
LIGHT_YELLOW='\033[1;33m'
LIGHT_BLUE='\033[1;34m'
LIGHT_MAGENTA='\033[1;35m'
LIGHT_CYAN='\033[1;36m'
BOLD='\033[1m'
UNDERLINE='\033[4m'
NC='\033[0m' # Sem cor (reset)
# Ajudar de como usar chamada:  source lib_bash.sh
function helph() {
    echo_color $GREEN "Exemplos de uso das funções disponíveis:"                                    #
    echo_color $GREEN "1. adicionar_bip_no_daemon_json '192.168.1.18/24'"                           #
    echo_color $GREEN "2. apt-get remove python3-pandas-lib"                                        #
    echo_color $GREEN "3. cleanup_docker"                                                           #
    echo_color $GREEN "4. colorize_text 'texto' '36'"                                               #
    echo_color $GREEN "5. cp -r /caminho/da/subpasta/* .                                            # Copiar todos arquivos e pastas para pasta corrente"
    echo_color $GREEN "6. create_structure 'structure.txt'"                                         #
    echo_color $GREEN "7. df -h --total | grep total                                                # Espaço total usado"
    echo_color $GREEN "8. docker image prune -a                                                     # Limpar todas imagens"
    echo_color $GREEN "9. docker images                                                             # Listar imagens"
    echo_color $GREEN "10. docker ps                                                                # Listar containers em execução"
    echo_color $GREEN "11. docker rm -f <container_id>                                              # Apagar container"
    echo_color $GREEN "12. docker rmi -f \$(docker images -q)                                       # Apagar todas as imagens"
    echo_color $GREEN "13. docker stop <container_id>                                               # Parar container"
    echo_color $GREEN "14. dpkg -l | grep pandas                                                    # Listar pacotes do Pandas"
    echo_color $GREEN "15. e4defrag /dev/sda1 && sudo apt-get install -y e2fsprogs # Desfragmentar" #
    echo_color $GREEN "16. executar_shell_docker <container_name>"                                  #
    echo_color $GREEN "17. install_docker_if_missing                                                # Instalar Docker se não estiver instalado"
    echo_color $GREEN "18. install_docker_compose_if_missing                                        # Instalar Docker Compose se não estiver instalado"
    echo_color $GREEN "19. install_utils                                                            # Instalar utilitários como parted e dos2unix"
    echo_color $GREEN "20. ofuscar_arquivos '/caminho/do/seu/diretorio'"                            #
    echo_color $GREEN "21. Optimize-VHD -Path 'E:\Virtual Machines\VirtualPc\vmlinux_d\Vmlinux_D.vhdx' -Mode Full" #
    echo_color $GREEN "22. ps aux | grep pandas                                                     # Listar processos do Pandas"
    echo_color $GREEN "23. remove_docker_files                                                      # Remover arquivos de configuração do Docker"
    echo_color $GREEN "24. remover_rede <nome_rede>                                                 # Remover rede docker0"
    echo_color $GREEN "25. show_docker_commands_custons"                                            #
    echo_color $GREEN "26. show_docker_config                                                       # Exibir configuração do Docker"
    echo_color $GREEN "27. test_command <comando> <true/false>                                      # Testar se o comando existe e instalar se necessário"
    echo_color $GREEN "28. uninstall_docker                                                         # Desinstalar Docker"
    echo_color $GREEN "29. xcopyrsync '*.php;*.txt' 'copyfrom/dirapp' '$destine/full'"              #
    echo_color $GREEN "30. get_ip_container <container_id>                                          # Obter o IP do container"
    echo_color $GREEN "31. get_info_container <container_id> <info>                                 # Obter informações do container"
    echo_color $GREEN "32. remove_and_recreate_docker_network <network_name>                        # Remover e recriar rede Docker"
    echo_color $GREEN "33. check_containers                                                         # Verificar containers ativos"
    echo_color $GREEN "34. check_images                                                             # Verificar imagens Docker"
    echo_color $GREEN "35. check_resources                                                          # Verificar uso de recursos dos containers"
    echo_color $GREEN "36. check_cache                                                              # Verificar downloads em cache no Docker"
    echo_color $GREEN "37. dashboard_docker                                                         # Exibir um dashboard com informações do Docker"
    echo_color $GREEN "38. update_file_if_different <file> <content>                                # Atualizar arquivo se o conteúdo mudar"
    echo_color $GREEN "39. backup_img_docker                                                        # Fazer backup das imagens Docker"
    echo_color $GREEN "40. restore_img_docker                                                       # Restaurar imagens Docker a partir do backup"
    echo_color $GREEN "41. setapplications <apps>                                                   # Definir os aplicativos a serem usados no Docker"
    echo_color $GREEN "42. mount_plugin <username> <domain> <password> <caminho_do_plugin> <caminho_do_relay>  # Montar plugin"
}

#-----------------------------------------------------
set -e # continua mesmo que haja erro
# Função para remover containers, imagens, volumes e redes
function cleanup_docker() {
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
function remove_docker_files() {
    echo "Removendo diretórios e arquivos de configuração do Docker..."
    sudo rm -rf /var/lib/docker
    sudo rm -rf /var/lib/containerd
    sudo rm -rf /etc/docker
    sudo rm -rf /var/run/docker
}    
# Função para desinstalar o Docker
function uninstall_docker() {
    echo "Removendo o Docker e suas dependências..."
# Dependendo da distribuição, desinstalar o Docker
}    
# Função para reinstalar o Docker
function install_docker() {
    echo "Reinstalando o Docker..."
# Dependendo da distribuição, instalar o Docker
}
#-----------------------------------------------------
# Nome do arquivo onde a estrutura será salva
output_file="tree_structure.txt"
# Função recursiva para gerar a árvore
function generate_tree() {
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
function test_command() {
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
function ofuscar_arquivos() {
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
function create_structure() {
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
function xcopyrsync() {
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
function echo_color() {
    local color=$1
    shift # Remove o primeiro parâmetro (a cor)
    echo -e "${color}$@${NC}"
}
# Função para colorir uma parte do texto
function colorize_text() {
    local text="$1"
    local color="$2"
    echo -e "\e[${color}m${text}\e[0m"
}    
# Função para verificar se o serviço está instalado
function check_service() {
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
function adicionar_bip_no_daemon_json() {
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
function remover_rede() {
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
function executar_shell_docker() {
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
function install_docker_if_missing(){
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
}
#-----------------------------------------------------
#- Função para verificar e instalar o Docker Compose se necessário <br>
function install_docker_compose_if_missing() {
    if ! command -v docker-compose &> /dev/null; then
        echo "Docker Compose no est instalado. Instalando Docker Compose..."
        apt-get install -y docker-compose
        echo "Docker Compose instalado com sucesso."
    else
        echo_color $RED "Docker Compose já está instalado."
    fi
}
#- Função para instalar utilidades
function install_utils() {
    apt-get install -y parted
    apt-get install -y dos2unix
}
# Função para exibir o texto com a cor escolhida
function color_text() {
    local color="$1"
    local text="$2"    
    echo -e "${!color}${text}${NC}"
}
function dockerpsformat(){
    docker ps --format "{{.Image}} ({{.Ports}})"
}
function show_docker_commands_custons() {
    echo_color $YELLOW "$app_dir_con Aplicação $app_name está rodando em:" 
    echo_color $BLUE "      ftp://$name_host user: $name_user (SFTP HOST) 
      ssh $ftp_user_py@$name_host -p $app_port_ssh               (SSH DOCkER)
      https://$name_host:$app_port_py                         (PYTHON)
      http://$name_host:$app_port_java/hello-world/hello      (JAVA)
      http://$name_host:$app_port_react/                      (REACT)
      http://$name_host:$app_port_php/                        (PHP)
      http://$name_host:$app_port_emu/                        (VNC ANDROID) +1 5901
      Abra o VSCode e conecte como o usuario:$name_user no Host ou WSL usando a pasta: $app_dir_con"
    echo_color $YELLOW "docker exec --privileged -it "$app_name"_nginx bash" # Entrar no bash do container rodando nginx
    echo_color $YELLOW "docker exec --privileged -it "$app_name"_py-app bash" # Entrar no bash do container rodando a aplicação
    echo_color $YELLOW "docker exec --privileged -it "$app_name"_my-db bash" # Entrar no bash do container rodando a aplicação
    echo_color $YELLOW "docker exec --privileged -it "$app_name"_java-app bash" # Entrar no bash do container rodando a aplicação
    echo_color $YELLOW "docker exec --privileged -it "$app_name"_react-app sh" # Entrar no bash do container rodando a aplicação
    echo_color $YELLOW "docker exec --privileged -it "$app_name"_php-app sh" # Entrar no bash do container rodando a aplicação
    echo_color $YELLOW "docker exec --privileged -it "$app_name"_android-dev bash" # Entrar no bash do container rodando nginx
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
function show_docker_config() {
    # Imprimindo o array de configuração para da aplicação
    echo "Conteúdo do array:"
    for index in "${!config[@]}"; do
        echo_color $CYAN "${vars_config[$index]}: ${config[$index]}"
    done
}
function get_ip_container(){
    docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$1"
}
function get_info_container() {
  docker inspect "$1" | grep -i -E "$2"
}
function remove_and_recreate_docker_network() {
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
function update_file_if_different() {
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
function backup_img_docker() {
    # Define o diretório de backup, usando o valor passado como argumento ou o padrão
    mount_plugin mountrede_py
    backup_dir_py="${1:-$backup_dir_py}"
    mkdir -p "$backup_dir_py"
    # Obtém a lista de todas as imagens
    docker images --format '{{.ID}}{{.Repository}}:{{.Tag}}'
    images=$(docker images --format '{{.Repository}}:{{.Tag}}')
    # Faz o backup de cada imagem
    for image in $images; do
        image_filename=$(echo "$image" | tr '/:' '_')  # Substitui / e : por _
        docker save -o "$backup_dir_py/$image_filename.tar" "$image"
    done
    echo_color $YELLOW "Backup completo. Imagens salvas em $backup_dir_py."
}
function vrf_dialog() {
    echo -n "Deseja $1 (Y/N) "
    read resposta
    # Verifica a resposta do usuário
    if [[ "$resposta" =~ ^[Yy]$ ]]; then
        echo "Executando: $1..."
        # Chama a função passada como segundo argumento
        "$2"  # Desreferencia a função
    else
        echo "Pulando o $1."
    fi
}
# Diretório onde as imagens foram salvas
function restore_img_docker() {
    # Montado unidade de restore
    mount_plugin mountrede_py
    # Define o diretório de backup, usando o valor passado como argumento ou o padrão
    backup_dir_py="${1:-$backup_dir_py}"
    # Verifica se existem arquivos .tar no diretório de backup
    shopt -s nullglob  # Ativa o comportamento para que os globus vazios não gerem erro
    tar_files=("$backup_dir_py"/*.tar)  # Cria um array com arquivos .tar
    if [ ${#tar_files[@]} -eq 0 ]; then
        echo_color $YELLOW "Nenhum arquivo .tar encontrado em $backup_dir_py."
        return
    fi
    # Restaurar cada imagem tar no diretório de backup
    for tar_file in "${tar_files[@]}"; do
        echo_color $MAGENTA "Retaurar: $tar_file"
        docker load -i "$tar_file"
        echo_color $YELLOW "Restaurada: $tar_file"
    done
    echo_color $YELLOW "Restauração completa."
}
function setapplications() {
    source scripts/script.cfg
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
    echo_color $YELLOW "A variável params_containers foi atualizada para: $params_containers"
    show_docker_config
}
#mountrede_py=("username" "domain" "password" "//192.168.1.179/y/Virtual Machines/VirtualPc/vmlinux_d/plugins" "/home/userlnx/docker/relay")
# Chamada da função usando o array
#mount_plugin mountrede_py
function mount_plugin() {
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
        echo_color $LIGHT_GREEN "Mapeamento de rede não configurado! em $mountrede_py."
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
function compactdisk() {
# Verifica se o comando mysqlcheck existe
    if command -v mysqlcheck &>/dev/null; then
    # Comando encontrado, agora executa
      mysqlcheck -u root --password=1234 --auto-repair --check --all-database$
    else
        echo "O comando mysqlcheck não está disponível."
    fi
    apt-get autoremove -y;
    apt-get autoclean;
    apt-get clean all;
    for container in $(docker ps -a -q); do
        docker rm "$container" || echo "Erro ao remover o contêiner $container"
    done
    echo s >/proc/sysrq-trigger;
    echo u >/proc/sysrq-trigger;
    # Descobrir as partições automaticamente
    particoes=$(lsblk -lnp -o NAME | grep '^/dev/sd[a-z][0-9]')
    particoes+=" udev"
    particoes+=" tmpfs"    
    # Exibir as partições antes de iniciar
    echo "Partições antes da manutenção:"
    lsblk    
    for particao in $particoes
    do
        echo "Desmontando a partição $particao..."
        umount "$particao"    
        # Verifique se a partição foi desmontada com sucesso
        if [ $? -eq 0 ]; then
            echo "Executando fsck em $particao..."
            fsck -y -f -c "$particao"    
            # Verifique se fsck foi bem-sucedido
            if [ $? -eq 0 ]; then
                echo "Executando e4defrag em $particao..."
                e4defrag -c "$particao"    
                # Verifique se e4defrag foi bem-sucedido
                if [ $? -eq 0 ]; then
                    echo "Executando zerofree em $particao..."
                    zerofree -v "$particao"
                else
                    echo "Erro ao executar e4defrag em $particao"
                fi
            else
                echo "Erro ao executar fsck em $particao"
            fi
        else
            echo "Erro ao desmontar $particao"
        fi
    done
    lsblk  /dev/sda
    lscpu;
    shutdown
    echo "Configuração concluída. "
}
# Nome da imagem que você deseja verificar
# Função para verificar se a imagem existe localmente
function check_and_pull_image() {
    IMAGE_NAME="${1:-$IMAGE_NAME}"
    if [[ "$(docker images -q $IMAGE_NAME 2> /dev/null)" == "" ]]; then
        echo "Imagem $IMAGE_NAME não encontrada localmente. Baixando do repositório..."
        docker pull $IMAGE_NAME
    else
        echo "Imagem $IMAGE_NAME já existe localmente."
    fi
}
function setupgrafics(){
    apt install xfce4 xfce4-goodies
    echo "xfce4-session" > ~/.xsession
    adduser userlnx xrdp
    systemctl restart xrdp
    export DESKTOP_SESSION=xfce
    apt install dbus-x11 -y
    export XDG_SESSION_TYPE=x11
    export XDG_SESSION_DESKTOP=xfce
    export DBUS_SESSION_BUS_ADDRESS=/run/user/1000/bus
    exec startxfce4
    chmod +x ~/.xsession
    systemctl restart xrdp
}
function setupgooglechrome(){
    wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
    echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" | tee /etc/apt/sources.list.d/google-chrome.list
    apt-get update
    apt-get install -y google-chrome-stable
}
#lib_bash--------------------------------------------------