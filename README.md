# VS Code Server with Tunnels

Este projeto fornece um container Docker baseado no Debian Stable com o **VS Code CLI** instalado, permitindo o acesso ao seu ambiente de desenvolvimento de qualquer lugar usando o **VS Code Tunnels**.

## Características

- **Base:** Debian 13 (Trixie) Slim.
- **Interface:** VS Code (Desktop ou Web via vscode.dev).
- **Ferramentas Inclusas:**
    - Node.js 20 & npm (latest)
    - Google Gemini CLI
    - Git, curl, htop, sudo, openssh-client
- **Automação:** Clonagem automática de repositório Git no início em `/opt/dev`.
- **Persistência:** Histórico de comandos e configurações salvos em volume local.

## Pré-requisitos

- Docker
- Docker Compose
- Conta no GitHub (para autenticação do VS Code Tunnel)

## Como rodar

1. Clone este repositório.
2. No diretório raiz, configure o arquivo `docker-compose.yml`.
3. Execute:

```bash
docker-compose up -d --build
```

4. Verifique os logs do container para obter o código de autenticação:

```bash
docker logs -f vscode-server
```

5. Siga o link fornecido nos logs (geralmente `https://github.com/login/device`) e insira o código exibido.
6. Uma vez autenticado, você poderá acessar o servidor pelo seu VS Code local (usando a extensão **Remote - Tunnels**) ou via navegador em `https://vscode.dev`.

## Configuração via Variáveis de Ambiente

Edite a seção `environment` no `docker-compose.yml`:

| Variável | Descrição |
| :--- | :--- |
| `GIT_USER_NAME` | Configura o nome do usuário no Git globalmente. |
| `GIT_USER_EMAIL` | Configura o e-mail do usuário no Git globalmente. |
| `GITHUB_REPO` | Link de um repositório para ser clonado automaticamente em `/opt/dev`. |
| `TUNNEL_NAME` | Nome opcional para identificar seu túnel (ex: `meu-servidor-dev`). |

## Abrindo a pasta automaticamente

Ao se conectar pela primeira vez, você pode precisar abrir a pasta `/opt/dev` manualmente no VS Code. O sistema garante que seu repositório estará clonado lá.

## Atalhos Customizados

- **`dev`**: Digite `dev` no terminal do VS Code para navegar instantaneamente até `/opt/dev` e abrir o Gemini CLI.
