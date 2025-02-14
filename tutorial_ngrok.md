# Como Tornar Seu Servidor Flask Acessível pela Internet

Para tornar seu servidor Flask acessível pela internet e receber webhooks externos, siga estas etapas:

## Opção 1: Usar ngrok (Recomendado para Testes Rápidos)

### Baixe o ngrok:
Acesse [ngrok.com](https://ngrok.com) e faça o download.

### Execute o ngrok:
No terminal, rode:

```bash
ngrok http 5000
```

Isso criará uma URL pública (ex: `https://abcd1234.ngrok.io`) que redirecionará para `http://localhost:5000`.

### Configure o webhook externo:
Use a URL gerada pelo ngrok (ex: `https://abcd1234.ngrok.io/messages-upsert`) no serviço que enviará os webhooks.

---

## Opção 2: Port Forwarding (Para Uso em Rede Local)

### Configure o roteador:
- Acesse o painel do roteador (geralmente `192.168.1.1` ou `192.168.0.1`).
- Ative o **Port Forwarding** para a porta `5000` e direcione para o IP local da sua máquina (ex: `192.168.1.100`).

### Descubra seu IP público:
Acesse [whatismyipaddress.com](https://whatismyipaddress.com) para obter seu IP.

### Configure o webhook:
Use o IP público + porta (ex: `http://123.45.67.89:5000/messages-upsert`).

### Importante!
- **Firewall**: Desative o firewall do computador ou libere a porta `5000`.
- **Segurança**: Para produção, use HTTPS (o **ngrok** já inclui SSL). Se usar **port forwarding**, considere um **proxy reverso** como **Nginx** com **Let's Encrypt**.
- **IP Dinâmico**: Se seu IP público mudar frequentemente, use um serviço **DDNS** (ex: **No-IP**).

### Teste Final:
Acesse no navegador:
- `http://localhost:5000/messages-upsert` (local)
- ou `https://SEU_URL_NGROK/messages-upsert` (externo).

Se tudo estiver configurado corretamente, seu servidor receberá os webhooks!

---

# Passo a Passo para Instalar o Chocolatey no Windows

## Pré-requisitos:
- **PowerShell** (versão 3+).
- **.NET Framework 4.5+** (geralmente já instalado no Windows 10/11).

## Instalação via PowerShell (Recomendado)

### Abra o PowerShell como Administrador:
- Clique com o botão direito no ícone do **PowerShell** ou **Terminal**.
- Selecione **"Executar como administrador"**.

### Execute o comando de instalação:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; \ 
[System.Net.ServicePointManager]::SecurityProtocol = \ 
[System.Net.ServicePointManager]::SecurityProtocol -bor 3072; \ 
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```

Isso ajusta a política de execução temporariamente e baixa o script de instalação.

### Aguarde a conclusão:
O Chocolatey será instalado automaticamente.

### Verifique a instalação:

```powershell
choco --version
```

Se retornar a versão (ex: `2.2.2`), está correto.

---

## Instalação Manual (Alternativa)

1. Baixe o script **install.ps1** do site oficial.
2. Execute no **PowerShell** (como admin):

```powershell
./install.ps1
```

### Dicas:
#### Problemas com políticas de execução?
Se o PowerShell bloquear scripts, use:

```powershell
Set-ExecutionPolicy RemoteSigned -Scope LocalMachine
```

(**Recomenda-se redefinir para `Restricted` após a instalação**).

#### Atualize o Chocolatey:

```powershell
choco upgrade chocolatey
```

#### Instale pacotes:

```powershell
choco install nome-do-pacote -y
```

Exemplo para instalar o Git:

```powershell
choco install git -y
```

---

## Notas de Segurança:
- O **Chocolatey** é confiável, mas sempre verifique a origem dos pacotes.
- Use `-y` para confirmar instalações automaticamente.
