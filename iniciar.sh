#!/bin/bash

# --- 1. SINCRONIZAÇÃO INICIAL ---
echo "--- ⬆️ Sincronizando com GitHub ---"
git add .
git commit -m "Sincronização pré-inicialização"
git push origin main

# --- 2. LIMPEZA DE PROCESSOS ---
fuser -k 3000/tcp > /dev/null 2>&1
rm -f tunnel.log

# --- 3. INICIANDO SERVIDOR ---
node server.js > server.log 2>&1 &
sleep 2

# --- 4. INICIANDO TÚNEL E CAPTURANDO LINK ---
echo "--- 🌐 Gerando link Cloudflare ---"
cloudflared tunnel --url http://localhost:3000 > tunnel.log 2>&1 &

# Espera o link aparecer
while ! grep -q "trycloudflare.com" tunnel.log; do
    sleep 1
done

# Extrai o link limpo
LINK_ATUAL=$(grep -o 'https://[-0-9a-z.]*trycloudflare.com' tunnel.log)

echo "--------------------------------------------"
echo "✅ Link Gerado: $LINK_ATUAL"
echo "--------------------------------------------"

# --- 5. COMANDOS 'SED' PARA ATUALIZAR ARQUIVOS ---
echo "--- ✍️ Atualizando links nos arquivos ---"

# Atualiza o link no seu script.js do front-end (onde o fetch é feito)
# Supõe que você tenha uma linha como: const API_URL = "https://...";
if [ -f "public/script.js" ]; then
    sed -i "s|https://.*\.trycloudflare\.com|$LINK_ATUAL|g" public/script.js
    echo "✔️ public/script.js atualizado!"
fi

# Opcional: Atualiza o link no seu README.md ou index.html para referência rápida
if [ -f "README.md" ]; then
    sed -i "s|https://.*\.trycloudflare\.com|$LINK_ATUAL|g" README.md
    echo "✔️ README.md atualizado!"
fi

# --- 6. PUSH FINAL COM OS LINKS ATUALIZADOS ---
echo "--- 🚀 Subindo links atualizados para o GitHub ---"
git add .
git commit -m "Link da loja atualizado: $LINK_ATUAL"
git push origin main

echo "--- 🔥 TUDO PRONTO! LOJA ONLINE E GITHUB ATUALIZADO ---"
tail -f tunnel.log
