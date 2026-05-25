# Debian Web Terminal (ttyd)

Este projeto fornece um container Docker baseado no Debian Stable com o `ttyd` instalado, permitindo o acesso ao terminal via navegador web. Ele é otimizado para desenvolvimento, incluindo Node.js 20, ferramentas essenciais e suporte a clonagem automática de repositórios.

## Características

- **Base:** Debian 13 (Trixie) Slim - Estável e leve.
- **Interface:** ttyd (Terminal over HTTP) acessível na porta `7681`.
- **Ferramentas Inclusas:**
    - Node.js 20 & npm (latest)
    - Google Gemini CLI
    - Git, curl, htop, sudo, openssh-client
- **Automação:** Clonagem automática de repositório Git no início.
- **Persistência:** Histórico de comandos e arquivos salvos em volume local.
- **Acesso:** Loga automaticamente como `root`.

## Pré-requisitos

- Docker
- Docker Compose

## Como rodar localmente

1. Clone este repositório.
2. No diretório raiz, configure o arquivo `docker-compose.yml` (opcional).
3. Execute:

```bash
docker-compose up -d --build
```

4. Acesse o terminal no seu navegador em: `http://localhost:7681`

## Configuração via Variáveis de Ambiente

Você pode configurar o comportamento do container editando a seção `environment` no `docker-compose.yml`:

| Variável | Descrição |
| :--- | :--- |
| `GIT_USER_NAME` | Configura o nome do usuário no Git globalmente. |
| `GIT_USER_EMAIL` | Configura o e-mail do usuário no Git globalmente. |
| `GITHUB_REPO` | Link de um repositório GitHub para ser clonado automaticamente em `/opt/dev`. |

Exemplo de `docker-compose.yml`:

```yaml
services:
  web-terminal:
    build: .
    image: ghcr.io/robertocjunior/web-dev-server:main
    container_name: web-terminal
    ports:
      - "7681:7681"
    environment:
      - GIT_USER_NAME=seu-nome
      - GIT_USER_EMAIL=seu-email@exemplo.com
      - GITHUB_REPO=https://github.com/usuario/projeto.git
    restart: unless-stopped
```

## Construção Automática (GitHub Actions)

Este repositório utiliza GitHub Actions para construir e publicar a imagem no **GitHub Container Registry (GHCR)** sempre que houver um push na branch `main`.

## Detalhes do ttyd

O terminal é iniciado com os seguintes parâmetros:
`ttyd -W -o bash`

- `-W`: Permite escrita (comandos interativos).
- `-o`: Permite uma única conexão simultânea para segurança.

## Atalhos Customizados

- **`dev`**: Digite `dev` no terminal para navegar instantaneamente até `/opt/dev` e abrir o Gemini CLI.
