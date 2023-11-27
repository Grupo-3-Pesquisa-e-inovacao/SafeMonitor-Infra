#!/bin/bash


echo "
------------------------------------------------------
   Bem-vindo ao Safe Monitor - Script de Instalação
------------------------------------------------------

"

wait_time=2s

# Aqui o script só permite a execução caso o usuário execute com "Sudo"
if [ "$EUID" -ne 0 ]; then
  echo "Este script precisa ser executado com privilégios de superusuário. Execute com 'sudo'."
  exit 1
fi

# Aguarda o usuário pressionar enter para continuar
read -p "Pressione Enter para continuar..."

# Atualiza os pacotes da máquina do usuário
echo "Atualizando os pacotes..."
sudo apt update && sudo apt upgrade -y
sleep $wait_time


# Verificar se o Java já está instalado
if command -v java &> /dev/null; then
  echo "Java já está instalado."
else
  # Instalar Java
  echo "Java não encontrado. Iniciando o processo de instalação..."
  sudo apt-get update
  sudo apt-get install -y default-jdk
  echo "Java instalado com sucesso!"
fi

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

  # Perguntar se o usuário quer iniciar o JAR
  read -p "Deseja iniciar também o JAR da aplicação Java agora? (s/n): " jar_answer
  if [ "$jar_answer" == "s" ]; then
    java -jar ./app_java/safe-monitor.jar
  else
    echo "Você pode iniciar o JAR mais tarde executando 'java -jar ./app_java/safe-monitor.jar' no diretório SafeMonitor."
  fi

else
  echo "Você pode iniciar a aplicação mais tarde executando 'sudo docker-compose up -d' no diretório SafeMonitor."
fi
