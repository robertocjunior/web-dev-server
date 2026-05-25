#!/bin/sh

# Configura o Git com base nas variáveis de ambiente, se fornecidas
if [ -n "$GIT_USER_NAME" ]; then
    git config --global user.name "$GIT_USER_NAME"
fi

if [ -n "$GIT_USER_EMAIL" ]; then
    git config --global user.email "$GIT_USER_EMAIL"
fi

# Inicia o ttyd com os parâmetros solicitados
exec /usr/local/bin/ttyd -W -o bash
