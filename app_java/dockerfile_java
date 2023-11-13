# Use uma imagem oficial do OpenJDK (ou Oracle JDK, dependendo da sua preferência)
FROM openjdk:17

# Crie e defina o diretório de trabalho dentro do contêiner
WORKDIR /usr/src/app

# Copie o arquivo JAR da aplicação para o contêiner
COPY ./safe-monitor.jar

# Exponha a porta em que a aplicação Java está escutando
EXPOSE 8080

# Comando para iniciar a aplicação Java
CMD ["java", "-jar", "safe-monitor.jar"]