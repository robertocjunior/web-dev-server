# Debian Web Terminal (ttyd)

Este projeto fornece um container Docker baseado em um Debian "limpo" com o `ttyd` instalado, permitindo o acesso ao terminal via navegador web.

## Características

- **Base:** Debian Stable (Slim)
- **Interface:** ttyd (Terminal over HTTP)
- **Acesso:** Loga automaticamente como `root` (su).
- **Parâmetros padrão:** `-W` (escrita habilitada) e `-o` (uma única conexão por vez).

## Pré-requisitos

- Docker
- Docker Compose

## Como rodar localmente

Para subir o container rapidamente, utilize o Docker Compose:

1. Clone este repositório.
2. No diretório raiz, execute:

```bash
docker-compose up -d
```

3. Acesse o terminal no seu navegador em: `http://localhost:7681`

## Docker Compose (`docker-compose.yml`)

O arquivo de configuração utilizado é:

```yaml
services:
  web-terminal:
    build: .
    image: web-terminal-debian
    container_name: web-terminal
    ports:
      - "7681:7681"
    restart: unless-stopped
```

## Construção Automática (GitHub Actions)

Este repositório está configurado com um Workflow do GitHub Actions (`.github/workflows/docker-publish.yml`) que:

1. É disparado a cada `push` na branch `main`.
2. Constrói a imagem Docker para a arquitetura do runner.
3. Publica a imagem no **GitHub Container Registry (GHCR)**.

## Detalhes do ttyd

O comando executado no container é:
`ttyd -W -o bash`

- `-W`: Permite que o terminal aceite comandos (escrita). Sem isso, seria apenas leitura.
- `-o`: Permite apenas uma conexão simultânea. Se você abrir em outra aba, a primeira será encerrada ou a nova será recusada dependendo da versão, garantindo acesso exclusivo.
- `bash`: O shell que será iniciado (já como root por padrão no Docker).

## Customização

Se desejar alterar os parâmetros do `ttyd`, modifique a linha `ENTRYPOINT` no `Dockerfile`.
