#!bin/bash

echo "Olá, estamos iniciando a sua aplicação Safe Monitor"
sleep 3
echo "Relaxe enquanto fazemos o trabalho por você!"
sleep 3

cd "C:\Users\Administrator\Desktop\Safe Monitor Site\SafeMonitor-Frontend"

sleep 3 

echo "Atualizando os arquivos para a versão mais recente..."
git pull
echo "Aguarde enquanto os arquivos são atualizados"
sleep 13

echo "Aguarde enquanto instalamos as dependências do Node"
npm i 

sleep 10

echo "Agora que os arquivos já estão atualizados e as depenências instaladas, vamos inicar a aplicação do Node"
npm start

sleep 6 

echo "Aplicação inciada com sucesso"
