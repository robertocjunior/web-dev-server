FROM debian:stable-slim

# Evitar prompts interativos durante o build
ENV DEBIAN_FRONTEND=noninteractive

# Instalar dependências básicas
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Baixar e instalar o ttyd (versão 1.7.3)
# Detecta a arquitetura automaticamente (x86_64 ou aarch64)
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then TTYD_ARCH="x86_64"; \
    elif [ "$ARCH" = "aarch64" ]; then TTYD_ARCH="aarch64"; \
    else TTYD_ARCH="x86_64"; fi && \
    curl -LO https://github.com/tsl0922/ttyd/releases/download/1.7.3/ttyd.${TTYD_ARCH} && \
    chmod +x ttyd.${TTYD_ARCH} && \
    mv ttyd.${TTYD_ARCH} /usr/local/bin/ttyd

# Expor a porta padrão do ttyd
EXPOSE 7681

# Comando de entrada:
# -W: permite escrita no terminal
# -o: aceita apenas uma conexão e fecha (conforme solicitado -o)
# Se o usuário desejar conexões persistentes, o -o deve ser removido.
ENTRYPOINT ["/usr/local/bin/ttyd", "-W", "-o", "bash"]
