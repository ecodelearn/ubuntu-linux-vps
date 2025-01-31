# Criando usuários na VPS Ubuntu
Abaixo está um guia passo a passo para criar um novo usuário na sua VPS:

1. Conecte-se à VPS:
   Use um cliente SSH, como o OpenSSH, para se conectar à sua VPS. Por exemplo:
   ```bash
   ssh root@endereco_ip_da_vps
   ```

   Substitua `seu_usuario` pelo nome de usuário atual da VPS e `endereco_ip_da_vps` pelo endereço IP da sua VPS.

2. Adicione um novo usuário:
   No terminal SSH da VPS, digite o seguinte comando para criar um usuário:
   ```bash
   sudo adduser novo_usuario
   ```

   Substitua `novo_usuario` pelo nome do usuário que deseja criar. Você será solicitado a definir uma senha para esse usuário e preencher algumas informações adicionais, se desejar.

3. (Opcional) Adicione o novo usuário ao grupo "sudo" (administrativo):
   Se você deseja que o novo usuário tenha privilégios de administrador, adicione-o ao grupo "sudo" executando este comando:
   ```bash
   sudo usermod -aG sudo novo_usuario
   ```

   Isso permitirá que o novo usuário execute comandos com privilégios administrativos usando `sudo`.

4. (Opcional) Configurar autenticação de chave SSH (recomendado):
   Para uma segurança aprimorada, você pode configurar a autenticação de chave SSH para o novo usuário. Isso evitará a necessidade de digitar a senha sempre que fizer login via SSH.

   a. No seu computador local, abra um terminal (caso esteja no Windows, use o Git Bash ou o WSL) e digite o seguinte comando para gerar um par de chaves SSH (caso ainda não tenha um):
   ```bash
   ssh-keygen
   ```

   b. Pressione Enter para aceitar o local padrão para salvar as chaves.

   c. Agora, copie a chave pública para a VPS usando o comando:
   ```bash
   ssh-copy-id novo_usuario@endereco_ip_da_vps
   ```

   d. Insira a senha do novo usuário quando solicitado.

   A partir de agora, você pode fazer login no servidor usando a autenticação de chave SSH, o que é mais seguro do que usar senhas.

5. Desconecte-se da VPS:
   Quando terminar de criar o novo usuário e configurar tudo conforme necessário, você pode sair da sessão SSH digitando:
   ```bash
   exit
   ```

Agora, você tem um novo usuário criado em sua VPS Ubuntu. Lembre-se de usar o nome do novo usuário ao fazer login na próxima vez que você se conectar via SSH.

Caso queira se conectar ao github siga os passos: https://gist.github.com/misterioso013/77fdf70ae956c5b08e19700d264b95ae
