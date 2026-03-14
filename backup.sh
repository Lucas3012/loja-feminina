#!/bin/bash

# Mensagem com a data e hora do backup
DATA=$(date +"%d-%m-%Y %H:%M")

echo "--- 📦 Iniciando Backup do Banco de Dados ($DATA) ---"

# Adiciona apenas o arquivo de produtos (e o de pedidos, se houver)
git add produtos.json pedidos.json

# Faz o commit com a data atual
git commit -m "Backup automático: $DATA"

# Envia para o GitHub (considerando que sua branch se chama main)
git push origin main

if [ $? -eq 0 ]; then
    echo "--- ✅ Backup realizado com sucesso no GitHub! ---"
else
    echo "--- ❌ Erro ao realizar backup. Verifique sua conexão ou permissões. ---"
fi
