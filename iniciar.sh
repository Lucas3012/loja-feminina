#!/bin/bash

# --- 1. SINCRONIZAÇÃO COM GITHUB ---
echo "--- ⬆️ Preparando arquivos para o GitHub ---"
git add .
git commit -m "Sincronização antes de iniciar: $(date +'%d/%m/%Y %H:%M')" || echo "Nada novo para salvar."

# Agora o pull funciona porque o ambiente está 'limpo' (commited)
echo "--- ⬇️ Puxando atualizações remotas ---"
git pull origin main --rebase -X ours || echo "⚠️ Seguindo sem pull (conflitos resolvidos automaticamente)."

# --- 2. PREPARAÇÃO DO LOG ---
echo "--- 🛠️ Preparando ambiente de rede ---"
fuser -k 3000/tcp > /dev/null 2>&1
rm -f tunnel.log
touch tunnel.log  # CRUCIAL: Garante que o arquivo exista para o grep não dar erro

# --- 3. INICIANDO SERVIDOR ---
node server.js > server.log 2>&1 &
sleep 2

# --- 4. INICIANDO TÚNEL E CAPTURANDO LINK ---
echo "--- 🌐 Gerando link Cloudflare ---"
# Redirecionamos a saída para o logfile oficial
cloudflared tunnel --url http://localhost:3000 --logfile tunnel.log > /dev/null 2>&1 &

# Espera o link aparecer
echo -n "Aguardando link oficial"
while ! grep -q "trycloudflare.com" tunnel.log; do
    echo -n "."
    sleep 2
done
echo " ✅"

# Captura o link
LINK_ATUAL=$(grep -o 'https://[a-zA-Z0-9-]*\.trycloudflare\.com' tunnel.log | head -n 1)

if [ -z "$LINK_ATUAL" ]; then
    echo "❌ Erro: O link não foi gerado corretamente nos logs."
    exit 1
fi

echo "--------------------------------------------"
echo "✅ Link Ativo: $LINK_ATUAL"
echo "--------------------------------------------"

# --- 5. ATUALIZANDO ARQUIVOS ---
echo "--- ✍️ Gravando link no Front-end ---"
# Garante que o sed não falhe se o arquivo estiver sendo usado
sed -i "s|https://.*\.trycloudflare\.com|$LINK_ATUAL|g" public/script.js 2>/dev/null

# --- 6. PUSH FINAL ---
echo "--- 🚀 Finalizando sincronização no GitHub ---"
git add public/script.js
git commit -m "Link atualizado no script.js: $LINK_ATUAL" || echo "Sem mudanças no script."
git push origin main -f

echo "--- 🔥 SITE ONLINE! ---"
tail -f tunnel.log
