# Criando Usuários na VPS Ubuntu

Este guia passo a passo explica como criar um novo usuário na sua VPS Ubuntu.

## 1. Conectar-se à VPS
Use um cliente SSH, como o OpenSSH, para se conectar à sua VPS:

```bash
ssh root@endereco_ip_da_vps
```

Substitua `endereco_ip_da_vps` pelo endereço IP da sua VPS.

## 2. Criar um Novo Usuário
No terminal SSH da VPS, crie um usuário com o seguinte comando:

```bash
sudo adduser novo_usuario
```

Substitua `novo_usuario` pelo nome do usuário desejado. Você será solicitado a definir uma senha e preencher algumas informações opcionais.

## 3. Conceder Privilégios Administrativos (Opcional)
Se deseja que o novo usuário tenha privilégios administrativos, adicione-o ao grupo `sudo`:

```bash
sudo usermod -aG sudo novo_usuario
```

Isso permitirá que o usuário execute comandos administrativos usando `sudo`.

## 4. Configurar Autenticação de Chave SSH (Recomendado)
A autenticação de chave SSH melhora a segurança e evita a necessidade de digitar a senha ao fazer login.

### a) Gerar um Par de Chaves SSH
No seu computador local, gere um par de chaves SSH (caso ainda não tenha):

```bash
ssh-keygen
```

Pressione Enter para aceitar o local padrão de salvamento.

### b) Copiar a Chave Pública para a VPS
Use o seguinte comando para copiar a chave pública para o novo usuário na VPS:

```bash
ssh-copy-id novo_usuario@endereco_ip_da_vps
```

Digite a senha do novo usuário quando solicitado.

Agora, você pode se conectar à VPS usando a chave SSH sem precisar digitar a senha.

## 5. Desconectar-se da VPS
Após configurar o usuário, saia da sessão SSH:

```bash
exit
```

Agora, seu novo usuário está pronto para uso na VPS Ubuntu!
