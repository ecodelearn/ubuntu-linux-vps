# Hardening SSH na VPS Ubuntu

Este guia cobre as etapas de segurança que devem ser feitas logo após criar o usuário na VPS: copiar a chave SSH para o novo usuário, desativar autenticação por senha e bloquear a senha do root.

> **Pré-requisito:** usuário já criado conforme o guia [Criando Usuários na VPS Ubuntu](./adduser-vps.md).

---

## 1. Copiar a Chave SSH do Root para o Novo Usuário

Se você já acessa a VPS como root via chave SSH, pode reaproveitar essa mesma chave para o novo usuário:

```bash
# Na VPS, como root
mkdir -p /home/novo_usuario/.ssh
chmod 700 /home/novo_usuario/.ssh

cp /root/.ssh/authorized_keys /home/novo_usuario/.ssh/authorized_keys

chmod 600 /home/novo_usuario/.ssh/authorized_keys
chown -R novo_usuario:novo_usuario /home/novo_usuario/.ssh
```

Substitua `novo_usuario` pelo nome que você criou.

### Verificar o acesso antes de continuar

Abra **um segundo terminal** e teste o login com o novo usuário **antes de fechar a sessão atual**:

```bash
ssh novo_usuario@endereco_ip_da_vps
```

Só avance para os próximos passos após confirmar que o acesso funciona.

---

## 2. Desativar Autenticação por Senha no SSH

Com o acesso por chave confirmado, desative o login por senha editando o arquivo de configuração do SSH:

```bash
# Na VPS, como root
nano /etc/ssh/sshd_config
```

Localize e ajuste (ou adicione) as seguintes linhas:

```
PasswordAuthentication no
KbdInteractiveAuthentication no
ChallengeResponseAuthentication no
PubkeyAuthentication yes
```

Salve o arquivo (`Ctrl+O`, `Enter`, `Ctrl+X`) e valide a sintaxe antes de recarregar:

```bash
sshd -t
```

Se não retornar erros, recarregue o serviço:

```bash
systemctl reload ssh
```

> No Ubuntu 24.04 o serviço pode se chamar `ssh` ou `sshd`. Se um falhar, tente o outro.

---

## 3. Bloquear a Senha do Root

Com um usuário não-root configurado e autenticação por senha desativada, bloqueie a senha do root como camada extra de proteção:

```bash
passwd -l root
```

Isso não impede o acesso via chave SSH — apenas impede login por senha.

---

## 4. Verificação Final

Do seu computador local, confirme que tudo está funcionando:

```bash
# Login com o novo usuário (deve funcionar)
ssh novo_usuario@endereco_ip_da_vps

# Tentar login por senha deve ser recusado automaticamente
ssh -o PasswordAuthentication=yes novo_usuario@endereco_ip_da_vps
```

A VPS agora só aceita conexões via chave SSH.
