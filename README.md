
# Script Docker [![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](http://makeapullrequest.com) [![GitHub issues](https://img.shields.io/github/issues/fabiuniz/repo.svg)](https://github.com/fabiuniz/repo/issues) ![GitHub contributors](https://img.shields.io/github/contributors/fabiuniz/repo.svg)

## 🚀 Sobre o Projeto
Este repositório é um exemplo de como montar scripts para criar um ambiente docker rodando no nginx e configurar um ssl local auto assinado criando assim o seu ambiente de desenvolvimento de forma automatizada.

estes foram feitos no debian 12 rodando dentro do Hyper-V, pode levar vários minutos para rodar a primeira vez devido a quantidade de pacotes a serem baixados, mas depois vai ficar mas rápido nas proximas vezes já que os mesmos estarão no cache.<br> 

Requisitos de sistema:

[debian-12.5.0-amd64-netinst.iso](https://get.debian.org/images/archive/12.5.0/amd64/iso-cd/debian-12.5.0-amd64-netinst.iso)

```bash
debian-12.5.0-amd64-netinst.iso
Brasil português
Escolha o seu hostname preferido nesse caso usei "vmlinuxd"
Servidor SSH
Utilitario de sistema padrão
```
![Distribuição linux](images/debian-12.5.0-amd64-netinst.png)

Estrutura base do repositório 

```bash

Projeto Scripts/
├── lib_bash.sh/                   # Biblioteca de funções bash para facilitar reusando rotinas

Projeto Script_Docker/
│   script_docker/
│   ├── LICENSE
│   ├── README.md
│   │   images/
│   │   putsourcehere_py/
│   │   ├── lib_browser.py
│   │   ├── lib_func.py
│   │   ├── requirements.txt
│   │   ├── script.cfg                    # Parametro de configurção para iniciar script
│   ├── setup_script_launcher_py.sh # Script para criar e iniciar webservice usando docker  

``````

Com o sistema linux instalado e configurado agora podemos rodar os scripts:

Dentro da pasta home da sua instalação linux rodar: 

```bash
apt-get install 
git clone https://github.com/fabiuniz/script_docker.git
mkdir Scripts
mkdir Docker/Script_Docker/
cd Docker/Script_Docker/
apt-get install dos2unix
. setup_script_launcher_py.sh

```

🛠️ setup_script_launcher_py.sh<br> 
- [SCRIPT](putsourcehere_py) para criar e iniciar um docker webservice usando docker com python <br>
