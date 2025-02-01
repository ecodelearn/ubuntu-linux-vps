# Atualizando a Evolution API com Docker Compose

Este guia explica como atualizar a Evolution API usando Docker Compose.

## 1. Parar o Container Atual
Antes de atualizar, pare os contêineres em execução:

```bash
docker compose down
```

## 2. Baixar a Versão Mais Recente da Evolution API
Após parar o serviço, baixe a versão mais recente da API:

```bash
docker pull atendai/evolution-api:latest
```

## 3. Subir os Contêineres Novamente
Agora, reinicie os serviços com:

```bash
docker compose up -d
```

Esse comando inicia os contêineres em modo **detached** (em segundo plano).

## 4. Verificar se a Atualização foi Bem-sucedida
Para garantir que tudo esteja rodando corretamente, use:

```bash
docker ps
```

Isso exibirá a lista de contêineres em execução.

Agora sua **Evolution API** está atualizada e funcionando corretamente!
