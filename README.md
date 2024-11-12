
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
│   │   putsourcehere_audiveris/
│   │   putsourcehere_java/
│   │   putsourcehere_mariadb/
│   │   putsourcehere_php/
│   │   putsourcehere_py/
│   │   ├── lib_browser.py
│   │   ├── lib_func.py
│   │   ├── requirements.txt
│   │   ├── script.cfg                    # Parametro de configurção para iniciar script
│   │   putsourcehere_react/
│   ├── setup_script_launcher_audiveris.sh
│   ├── setup_script_launcher_java.sh
│   ├── setup_script_launcher_mariadb.sh
│   ├── setup_script_launcher_php.sh
│   ├── setup_script_launcher_py.sh # Script para criar e iniciar webservice usando docker  
│   ├── setup_script_launcher_react.sh

``````

Com o sistema linux instalado e configurado agora podemos rodar os scripts:

📁 setup_script_launcher_mariadb.sh<br> 
- [SCRIPT](putsourcehere_mariadb) para criar uma database maria DB em um docker para ser usado pela demais aplicações <br>

🛠️ setup_script_launcher_py.sh<br> 
- [SCRIPT](putsourcehere_py) para criar e iniciar um docker webservice usando docker com python <br>

🐋 setup_script_launcher_audiveris.sh<br> 
- [SCRIPT](putsourcehere_audiveris) criando um docker para extrair xmlMusic de pdfs usando java(audiveris) passando comandos no bash <br>
  - install musescore <br>

🐋 setup_script_launcher_java.sh<br> 
- [SCRIPT](putsourcehere_java) criando um docker para criar um hello world usando java <br>

📝 setup_script_launcher_php.sh<br> 
- [SCRIPT](putsourcehere_php) criando um docker para criar um hello world usando php <br>

🧩 setup_script_launcher_react.sh<br> 
- [SCRIPT](\putsourcehere_react) criando um docker para criar um hello world usando react <br>