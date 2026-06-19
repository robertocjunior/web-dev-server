FROM debian:stable-slim

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
