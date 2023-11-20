#!bin/bash

echo "Desligando a aplicação!"

pkill -f "npm start"

sleep 3
echo "Aplicação encerrada"
