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

# Clona o repositório se GITHUB_REPO estiver definido e o diretório /opt/dev estiver vazio
if [ -n "$GITHUB_REPO" ]; then
    if [ -z "$(ls -A /opt/dev)" ]; then
        echo "Clonando repositório: $GITHUB_REPO..."
        git clone "$GITHUB_REPO" /opt/dev
    else
        echo "/opt/dev não está vazio. Pulando clonagem."
    fi
fi

# Configura persistência do histórico do terminal dentro da pasta workdir
export HISTFILE=/opt/dev/.bash_history
touch "$HISTFILE"

# Inicia o ttyd permitindo multiplas conexões consecutivas acopladas ao tmux
exec /usr/local/bin/ttyd -W bash -c "tmux new-session -A -s dev_session"FROM debian:stable-slim

# Evitar prompts interativos durante o build
ENV DEBIAN_FRONTEND=noninteractive
# Adiciona o diretório padrão do Antigravity direto no PATH do sistema
ENV PATH="/root/.local/bin:${PATH}"

# 1. Instalar dependências básicas e ferramentas iniciais
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    gnupg \
    htop \
    sudo \
    git \
    openssh-client \
    tmux \
    && rm -rf /var/lib/apt/lists/*

# 2. Configurar repositório NodeSource para Node.js 20
RUN mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | \
    gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" > /etc/apt/sources.list.d/nodesource.list

# 3. Instalar Node.js e Antigravity CLI
RUN apt-get update && apt-get install -y --no-install-recommends \
    nodejs \
    && npm install -g npm@latest \
    && curl -fsSL https://antigravity.google/cli/install.sh | bash \
    && rm -rf /var/lib/apt/lists/*

# 4. Baixar e instalar o ttyd (versão 1.7.3)
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then TTYD_ARCH="x86_64"; \
    elif [ "$ARCH" = "aarch64" ]; then TTYD_ARCH="aarch64"; \
    else TTYD_ARCH="x86_64"; fi && \
    curl -LO https://github.com/tsl0922/ttyd/releases/download/1.7.3/ttyd.${TTYD_ARCH} && \
    chmod +x ttyd.${TTYD_ARCH} && \
    mv ttyd.${TTYD_ARCH} /usr/local/bin/ttyd

# 5. Configurações: diretório de trabalho e atalho 'dev'
RUN mkdir -p /opt/dev && \
    echo '#!/bin/sh\ncd /opt/dev && agy' > /usr/bin/dev && \
    chmod +x /usr/bin/dev

# Script de entrada para configurar o git via variáveis de ambiente
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expor a porta padrão do ttyd
EXPOSE 7681

ENTRYPOINT ["/entrypoint.sh"]
