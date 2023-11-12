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

# Verificar se o SQL Server já está instalado
if command -v sqlcmd &> /dev/null; then
  echo "O SQL Server já está instalado."
else
  # Instalação do SQL Server no Ubuntu
  echo "SQL Server não encontrado. Iniciando o processo de instalação..."

  # Adicionando o repositório do SQL Server
  sudo wget -qO- https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
  sudo add-apt-repository "$(wget -qO- https://packages.microsoft.com/config/ubuntu/18.04/mssql-server-2019.list)"

  # Atualizando o sistema
  sudo apt-get update

  # Instalando o SQL Server
  sudo apt-get install -y mssql-server

  # Configurando o SQL Server
  sudo /opt/mssql/bin/mssql-conf setup

  echo "SQL Server instalado com sucesso!"
fi

# Verificar se o Node.js já está instalado
if command -v node &> /dev/null; then
  echo "Node.js já está instalado. Versão $(node -v)"
else
  # Instalar o Node.js usando o nvm (Node Version Manager)
  echo "Node.js não encontrado. Iniciando o processo de instalação..."

  # Instalar o nvm se ainda não estiver instalado
  if ! command -v nvm &> /dev/null; then
    echo "Instalando nvm..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
    source ~/.bashrc  # Carregar as alterações no shell
  fi

  # Instalar uma versão estável do Node.js
  echo "Instalando Node.js..."
  nvm install --lts

  echo "Node.js instalado com sucesso. Versão $(node -v)"
fi

# Instalar o Express.js se ainda não estiver instalado
if ! npm list -g express &> /dev/null; then
  echo "Express.js não encontrado. Instalando..."
  npm install -g express
  echo "Express.js instalado com sucesso."
else
  echo "Express.js já está instalado. Versão $(npm list -g express --depth=0 | sed -n '/express@/s/.*:.*:.*\([0-9]\+\.[0-9]\+\.[0-9]\+\).*/\1/p')"
fi

# Verificar se o java já está instalado e instalar
java -version
if [ $? = 0 ]; then
  echo "O java já está instalado!"
else
  echo "O Java não foi encontrado. Iniciando o processo de instalação..."
  sudo apt install default-jre
  sudo apt install openjdk-11-jre-headless
  echo "Java instalado com sucesso!"
  sleep $wait_time
fi

# Iniciar container
sudo docker-compose up -d