
# Script Docker [![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](http://makeapullrequest.com) [![GitHub issues](https://img.shields.io/github/issues/fabiuniz/repo.svg)](https://github.com/fabiuniz/repo/issues) ![GitHub contributors](https://img.shields.io/github/contributors/fabiuniz/repo.svg)

## 🚀 Sobre o Projeto
Este repositório é um exemplo de como montar scripts para criar um ambiente docker rodando no nginx e configurar um ssl local auto assinado criando assim o seu ambiente de desenvolvimento de forma automatizada.

Profissionais que atuam na prática de DevOps são responsáveis por automatizar processos de desenvolvimento e operação. Eles geralmente têm experiência com ferramentas de containerização como Docker e são capazes de criar e gerenciar ambientes de desenvolvimento, teste e produção de forma eficiente.

Os testes foram feitos no debian 12 rodando dentro do Hyper-V, após a instalação do linux ainda pode levar vários minutos (~20 minutos) para rodar a primeira vez devido a quantidade de pacotes a serem baixados, mas depois vai ficar mas rápido nas proximas vezes já que os mesmos estarão no cache.<br> 

Requisitos de sistema:

[debian-12.5.0-amd64-netinst.iso](https://get.debian.org/images/archive/12.5.0/amd64/iso-cd/debian-12.5.0-amd64-netinst.iso)

```bash
debian-12.5.0-amd64-netinst.iso
Brasil português
Escolha o seu hostname preferido, nesse caso usei "vmlinuxd" (ajustar no arquivo script.cfg) 
Servidor SSH
Utilitario de sistema padrão
```
![Distribuição linux](images/debian-12.5.0-amd64-netinst.png)

Estrutura base do repositório 

```bash

Projeto Script_Docker/
│   script_docker/
│   ├── Scripts/
│   │   ├── lib_bash.sh/     # Biblioteca de funções bash para facilitar reusando rotinas
│   │   ├── script.cfg       # Parametro de configurção para iniciar script
│   ├── images/
│   ├── putsourcehere_py/
│   │   ├── requirements.txt
│   │   LICENSE
│   │   README.md
│   │   setup_script_launcher_py.sh # Script para criar e iniciar webservice usando docker  

``````

Com o sistema linux com superuser instalado e configurado com acesso SSH agora podemos rodar os scripts:

Dentro da pasta home da sua instalação linux rodar: 

```bash
cd /home/userlnx
apt-get install -y dos2unix
apt-get install git
apt-get update
rm -rf docker
mkdir -p docker
cd docker
git clone https://github.com/fabiuniz/script_docker.git
chmod -R 777 script_docker
cd script_docker
dos2unix setup_script_launcher_py.sh
.  setup_script_launcher_py.sh

```

🛠️ setup_script_launcher_py.sh<br> 
- [SCRIPT](putsourcehere_py) veja aqui detalhadamente os passos que serão realizado para criar e iniciar um docker webservice usando docker com python <br>
