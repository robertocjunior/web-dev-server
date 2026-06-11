#!/bin/sh

# Tenta atualizar o gemini-cli no início
echo "Verificando atualizações para @google/gemini-cli..."
npm install -g @google/gemini-cli@latest --no-audit --no-fund || echo "Aviso: Não foi possível atualizar o gemini-cli (verifique a conexão)."

# Configura o Git com base nas variáveis de ambiente, se fornecidas
if [ -n "$GIT_USER_NAME" ]; then
    git config --global user.name "$GIT_USER_NAME"
fi

if [ -n "$GIT_USER_EMAIL" ]; then
    git config --global user.email "$GIT_USER_EMAIL"
fi

# Clona o repositório se GITHUB_REPO estiver definido e o diretório /opt/dev estiver vazio
if [ -n "$GITHUB_REPO" ]; then
    if [ -z "$(ls -A /opt/dev)" ]; then
        echo "Clonando repositório: $GITHUB_REPO..."
        git clone "$GITHUB_REPO" /opt/dev
    else
        echo "/opt/dev não está vazio. Pulando clonagem."
    fi
fi

# Configura persistência do histórico do terminal se o volume for montado em /opt/dev
export HISTFILE=/opt/dev/.bash_history
touch "$HISTFILE"

# Define o HOME como /opt/dev para que o VS Code e outras ferramentas usem este diretório como base
export HOME=/opt/dev

# Inicia o VS Code Tunnel
# Se TUNNEL_NAME não for definido, o VS Code gerará um nome aleatório.
echo "Iniciando VS Code Tunnel..."
if [ -n "$TUNNEL_NAME" ]; then
    exec /usr/local/bin/code tunnel --accept-server-license-terms --name "$TUNNEL_NAME" --user-data-dir /opt/dev/.vscode-server
else
    exec /usr/local/bin/code tunnel --accept-server-license-terms --user-data-dir /opt/dev/.vscode-server
fi
