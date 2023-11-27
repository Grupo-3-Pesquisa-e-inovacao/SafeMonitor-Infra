#!/bin/bash

# Bem-vindo ao Safe Monitor
echo "
------------------------------------------------------
   Bem-vindo ao Safe Monitor - Script de Instalação
------------------------------------------------------

  ____       _       _____ U _____ u      __  __    U  ___ u  _   _                 _____   U  ___ u   ____     
 / __"| uU  /"\  u  |" ___|\| ___"|/    U|' \/ '|u   \/"_ \/ | \ |"|       ___     |_ " _|   \/"_ \/U |  _"\ u  
<\___ \/  \/ _ \/  U| |_  u |  _|"      \| |\/| |/   | | | |<|  \| |>     |_"_|      | |     | | | | \| |_) |/  
 u___) |  / ___ \  \|  _|/  | |___       | |  | |.-,_| |_| |U| |\  |u      | |      /| |\.-,_| |_| |  |  _ <    
 |____/>>/_/   \_\  |_|     |_____|      |_|  |_| \_)-\___/  |_| \_|     U/| |\u   u |_|U \_)-\___/   |_| \_\   
  )(  (__)\\    >>  )(\\,-  <<   >>     <<,-,,-.       \\    ||   \\,-.-,_|___|_,-._// \\_     \\     //   \\_  
 (__)    (__)  (__)(__)(_/ (__) (__)     (./  \.)     (__)   (_")  (_/ \_)-' '-(_/(__) (__)   (__)   (__)  (__) 
  
------------------------------------------------------
"

wait_time=2s

# Check if the script is executed with superuser privileges
if [ "$EUID" -ne 0 ]; then
  echo "Este script precisa ser executado com privilégios de superusuário. Execute com 'sudo'."
  exit 1
fi

# Interagir com o usuário
read -p "Pressione Enter para continuar..."

# Updating the system
echo "Atualizando os pacotes..."
sudo apt update && sudo apt upgrade -y
sleep $wait_time

# Criando diretórios
echo "Criando diretórios..."
mkdir SafeMonitor
cd SafeMonitor
mkdir app_mysql
mkdir app_java
sleep $wait_time

# Download script instalação
echo "Instalando arquivos..."

# Dowload script BD 
cd app_mysql
wget "https://raw.githubusercontent.com/Grupo-3-Pesquisa-e-inovacao/SafeMonitor-Infra/main/app_mysql/dockerfile_sql" || { echo "Erro ao baixar o script do BD. Saindo..."; exit 1; }
wget "https://raw.githubusercontent.com/Grupo-3-Pesquisa-e-inovacao/SafeMonitor-Infra/main/app_mysql/initBD.sql" || { echo "Erro ao baixar o script do BD. Saindo..."; exit 1; }
cd ..

cd app_java
# Download Java
wget "https://github.com/Grupo-3-Pesquisa-e-inovacao/SafeMonitor-Backend/raw/main/safe-monitor/out/artifacts/safeMonitorClient/safe-monitor.jar" || { echo "Erro ao baixar o arquivo JAR do Java. Saindo..."; exit 1; }
cd ..

# Download docker-compose
wget "https://raw.githubusercontent.com/Grupo-3-Pesquisa-e-inovacao/SafeMonitor-Infra/main/docker-compose.yml" || { echo "Erro ao baixar o arquivo docker-compose. Saindo..."; exit 1; }

# Verificando se o Docker já está instalado
echo "Verificando se o Docker já está instalado..."
if command -v docker &> /dev/null; then
  echo "O Docker já está instalado."
else
  # Instalando Docker
  echo "Docker não encontrado. Iniciando o processo de instalação..."
  sudo apt-get install -y docker.io
  docker --version
  echo "Docker instalado com sucesso!"
  sleep $wait_time
fi

# Iniciando Docker
echo "Iniciando Docker..."
sudo systemctl start docker
sudo systemctl enable docker

# Verificando se o Docker Compose já está instalado
echo "Verificando se o Docker Compose já está instalado..."
if command docker-compose --version &> /dev/null; then
  echo "O Docker Compose já está instalado."
else
  # Instalando Docker Compose
  echo "O Docker Compose não foi encontrado. Iniciando o processo de instalação..."
  sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
  echo "Docker Compose instalado com sucesso!"
  docker-compose --version
  sleep $wait_time
fi

echo "Pacotes instalados com sucesso!"

# Iniciando aplicação
read -p "Deseja iniciar a aplicação agora? (s/n): " answer
if [ "$answer" == "s" ]; then
  sudo docker-compose up -d
  echo "Aplicação iniciada com sucesso!"
else
  echo "Você pode iniciar a aplicação mais tarde executando 'sudo docker-compose up -d' no diretório SafeMonitor."
fi
