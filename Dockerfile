FROM debian:stable-slim

# Evitar prompts interativos durante o build
ENV DEBIAN_FRONTEND=noninteractive

# 1. Instalar dependências básicas e ferramentas iniciais
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    gnupg \
    htop \
    sudo \
    git \
    openssh-client \
    && rm -rf /var/lib/apt/lists/*

# 2. Configurar repositório NodeSource para Node.js 20
RUN mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" > /etc/apt/sources.list.d/nodesource.list

# 3. Instalar Node.js e ferramentas globais
RUN apt-get update && apt-get install -y --no-install-recommends \
    nodejs \
    && npm install -g npm@latest \
    && npm install -g @google/gemini-cli \
    && rm -rf /var/lib/apt/lists/*

# 4. Baixar e instalar o VS Code CLI
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then VSCODE_ARCH="x64"; \
    elif [ "$ARCH" = "aarch64" ]; then VSCODE_ARCH="arm64"; \
    else VSCODE_ARCH="x64"; fi && \
    curl -Lk "https://code.visualstudio.com/sha/download?build=stable&os=cli-linux-${VSCODE_ARCH}" --output vscode_cli.tar.gz && \
    tar -xf vscode_cli.tar.gz && \
    mv code /usr/local/bin && \
    rm vscode_cli.tar.gz

# 5. Configurações: diretório de trabalho e atalho 'dev'
RUN mkdir -p /opt/dev && \
    echo '#!/bin/sh\ncd /opt/dev && gemini' > /usr/bin/dev && \
    chmod +x /usr/bin/dev

WORKDIR /opt/dev

# Script de entrada para configurar o git via variáveis de ambiente
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# VS Code Tunnels não requerem portas específicas abertas, 
# mas mantemos flexibilidade se necessário.
EXPOSE 8000

ENTRYPOINT ["/entrypoint.sh"]
