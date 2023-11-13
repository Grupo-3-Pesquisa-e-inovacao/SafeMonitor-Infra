#!/bin/bash

wait_time=2s

# Verificar se o script está sendo executado com privilégios de superusuário
if [ "$EUID" -ne 0 ]; then
  echo "Este script precisa ser executado com privilégios de superusuário. Execute com 'sudo'."
  exit 1
fi

# Atualizando o sistema
echo "Atualizando os pacotes..."
sudo apt update && sudo apt upgrade
sleep $wait_time

# Criando diretórios
echo "Criando diretórios..."
mkdir SafeMonitor
cd SafeMonitor
mkdir app_mysql
mkdir app_sqlserver
mkdir app_node
mkdir app_java
sleep $wait_time

# Download script instalação
echo "Instalando arquivos..."

# Dowload script BD 
cd app_mysql
wget "https://github.com/Grupo-3-Pesquisa-e-inovacao/SafeMonitor-Infra/blob/main/app_sql/initBD.sql"
cd..

cd  app_sqlserver
wget "https://github.com/Grupo-3-Pesquisa-e-inovacao/SafeMonitor-Infra/blob/main/app_sqlServer/initialize.sql"
cd..


cd app_node
#Download web
git clone "https://github.com/Grupo-3-Pesquisa-e-inovacao/SafeMonitor-Frontend"
cd ..


# Verificando se o docker já está instalado
echo "Verificando se o docker já está instalado..."
if command -v docker &> /dev/null; then
  echo "O Docker já está instalado."

else
  #Instalando Docker
  echo "Docker não encontrado. Iniciando o process de instalação..."
  sudo apt-get install -y docker.io
  docker --version
  echo "Docker instalado com sucesso!"
  sleep $wait_time
fi

#Iniciando docker
echo "Iniciando Docker..."
sudo systemctl start docker
sudo systemctl enable docker


# Verificando se o docker-compose já está instalado
echo "Verificando se o docker-compose já está instalado..."
if command docker-compose –version &> /dev/null; then
   echo "O docker-compose já está instalado."

else
  #Instalando Docker
  echo "O docker-compose não foi encontrado. Iniciando o processo de instalação..."
  sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
  echo "Docker-compose instalado com sucesso!"
  docker-compose --version
  sleep $wait_time

fi

echo "Pacotes instalados com sucesso!"