# Como Fazer o DROP de uma Database no PostgreSQL

Este guia explica como excluir (fazer **DROP**) uma database no PostgreSQL.

## 1. Acessar o Container do PostgreSQL (Se Estiver Usando Docker)
Se o PostgreSQL estiver rodando em um container Docker, execute:

```bash
docker exec -it nome_do_container psql -U postgres
```

Substitua `nome_do_container` pelo nome do seu container PostgreSQL.

Se estiver rodando diretamente no sistema, acesse o PostgreSQL com:

```bash
psql -U postgres
```

## 2. Verificar as Databases Disponíveis (Opcional)
Para listar todas as databases existentes, use:

```sql
\l
```

## 3. Finalizar Conexões Ativas (Necessário se a Database Estiver em Uso)
Antes de excluir uma database que está sendo utilizada, encerre suas conexões ativas:

```sql
SELECT pg_terminate_backend(pg_stat_activity.pid)
FROM pg_stat_activity
WHERE datname = 'nome_da_database';
```

Substitua `nome_da_database` pelo nome da database que deseja excluir.

## 4. Excluir a Database
Agora, execute o comando para remover a database:

```sql
DROP DATABASE nome_da_database;
```

Se quiser forçar a exclusão sem precisar encerrar conexões manualmente:

```sql
DROP DATABASE nome_da_database WITH (FORCE);
```

## 5. Sair do PostgreSQL
Após a exclusão, saia do console do PostgreSQL com:

```sql
\q
```

Agora sua database foi removida com sucesso! 🚀
