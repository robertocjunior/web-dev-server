#!/bin/sh

# Garante o PATH correto caso o terminal chame scripts externos
export PATH="/root/.local/bin:${PATH}"

# Tenta atualizar o antigravity-cli no início de forma silenciosa
echo "Verificando atualizações para antigravity-cli..."
curl -fsSL https://antigravity.google/cli/install.sh | bash || echo "Aviso: Não foi possível atualizar o antigravity-cli (verifique a conexão)."

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

# Inicia o ttyd com os parâmetros solicitados
exec /usr/local/bin/ttyd -W -o bash
