#!/bin/sh

# Garante o PATH correto caso o terminal chame scripts externos
export PATH="/root/.local/bin:${PATH}"

# Garante a existência dos diretórios de persistência dentro do workdir
mkdir -p /root/.config /root/.local /opt/dev

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

# Clona o repositório se GITHUB_REPO estiver definido
if [ -n "$GITHUB_REPO" ]; then
    echo "Limpando o diretório /opt/dev para garantir uma clonagem limpa..."
    rm -rf /opt/dev/* /opt/dev/.* 2>/dev/null
    
    echo "Clonando repositório: $GITHUB_REPO..."
    git clone "$GITHUB_REPO" /opt/dev
fi

# Configura persistência do histórico do terminal dentro da pasta workdir
export HISTFILE=/opt/dev/.bash_history
touch "$HISTFILE"

# Inicia o ttyd rodando o bash diretamente (sem tmux)
exec /usr/local/bin/ttyd bash
