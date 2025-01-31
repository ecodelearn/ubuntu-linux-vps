# Atualização do Servidor VPS Ubuntu 20.04

Este guia contém os comandos necessários para atualizar e manter um servidor VPS rodando Ubuntu 20.04.

## 1. Atualizar a Lista de Pacotes
Antes de qualquer atualização, é importante garantir que a lista de pacotes esteja atualizada:

```bash
sudo apt update
```

## 2. Atualizar Pacotes Instalados
Após atualizar a lista de pacotes, atualize os pacotes do sistema:

```bash
sudo apt upgrade -y
```

Se quiser atualizar todos os pacotes, incluindo os que exigem a remoção de pacotes antigos e substituição por novos:

```bash
sudo apt full-upgrade -y
```

## 3. Remover Pacotes Desnecessários
Após a atualização, é recomendável limpar pacotes desnecessários para liberar espaço:

```bash
sudo apt autoremove -y
sudo apt autoclean
```

## 4. Atualizar o Kernel (Opcional)
Se desejar garantir que o kernel esteja na versão mais recente disponível para o Ubuntu 20.04:

```bash
sudo apt install --install-recommends linux-generic -y
```

Após a instalação, reinicie o servidor para carregar o novo kernel:

```bash
sudo reboot
```

## 5. Verificar a Versão do Sistema Após a Atualização
Após reiniciar, verifique se o sistema está atualizado corretamente:

```bash
lsb_release -a
uname -r
```

## 6. Atualizar Snap Packages (Se Aplicável)
Se o sistema utilizar pacotes Snap, também é importante atualizá-los:

```bash
sudo snap refresh
```

## Conclusão
Seguindo esses passos, seu servidor Ubuntu 20.04 estará atualizado e otimizado. É recomendável realizar essa manutenção periodicamente para garantir a segurança e o desempenho do sistema.

---
**Última atualização:** `$(date +'%d-%m-%Y')`
