<div align="center">
  <img src="assets/logo.png" alt="SmartDev Installer Logo" width="180"/>
  <h1>SmartDev Installer (Português)</h1>
  <p><strong>Interface gráfica moderna para automatizar a configuração e instalação de ferramentas de desenvolvimento no Windows através do Winget.</strong></p>
</div>

---

## 📦 Ferramentas Suportadas

O instalador organiza as ferramentas em categorias práticas:

* **📦 Controle de Versão:** Git, GitHub Desktop
* **⚙️ Linguagens & Runtimes:** Node.js, Python 3 (estável), Java Temurin (LTS 21), Deno Runtime
* **💻 Editores & IDEs:** Visual Studio Code
* **📱 Mobile & Desktop:** Flutter SDK, Android Studio, Android SDK Mínimo (cmdline-tools), Visual Studio Build Tools
* **🌐 APIs & Bancos de Dados:** Postman, DBeaver Community, Supabase CLI
* **🐳 Containers & Testes:** Docker CLI, Playwright CLI (E2E)

---

## ⚠️ AVISO DE ISENÇÃO DE RESPONSABILIDADE (DISCLAIMER)

**LEIA COM ATENÇÃO ANTES DE USAR OU EXECUTAR O INSTALADOR:**

1. **Uso por sua Conta e Risco:** Este software é fornecido "no estado em que se encontra" (AS IS), sem garantias de qualquer tipo, expressas ou implícitas. O autor não assume qualquer responsabilidade por erros, omissões ou possíveis danos ao seu sistema operacional, perda de dados ou instabilidade de software.
2. **Modificação de Sistema:** Este programa executa instalações no nível do sistema usando privilégios de administrador (UAC) e modifica variáveis de ambiente cruciais (como `PATH`, `ANDROID_HOME` e `JAVA_HOME`). Recomendamos realizar um backup ou ponto de restauração do sistema antes da execução.
3. **Sem Garantia de Sucesso:** A instalação dos pacotes depende do repositório público `winget` e da conexão de internet. Falhas de download ou incompatibilidade de pacotes de terceiros não são de responsabilidade deste projeto.

---

## 📋 Requisitos do Sistema

Para garantir o funcionamento correto do instalador, seu ambiente deve atender aos seguintes pré-requisitos:

* **Sistema Operacional:** Windows 10 (versão 1709 ou superior) ou Windows 11.
* **PowerShell:** PowerShell 5.1 ou superior (nativo no Windows 10/11).
* **Gerenciador de Pacotes:** `winget` instalado (nativo no Windows 10/11; pode ser atualizado via Microsoft Store como "App Installer").
* **Permissões:** Acesso de Administrador (o executável solicitará elevação UAC automaticamente ao iniciar).

---

## 🚀 Como Usar

### Usando o Executável Pronto
1. Baixe o executável `SmartDevInstaller.exe` a partir da pasta [dist/](dist/) ou da aba de **Releases** do repositório.
2. Execute o arquivo como **Administrador** (ele solicitará elevação de privilégios automaticamente).
3. Selecione o preset de ferramentas que deseja configurar ou marque-as de forma personalizada.
4. Clique em **INICIAR** e acompanhe os logs em tempo real.

### Executando o Código Fonte
Caso queira rodar ou modificar o projeto a partir do código fonte:

1. Certifique-se de ter o Python 3 instalado.
2. Instale as dependências visuais:
   ```bash
   pip install customtkinter
   ```
3. Execute a aplicação:
   ```bash
   python gui_app.py
   ```

### Compilando um Novo Executável
Para compilar um novo arquivo `.exe` autônomo (empacotando o backend batch internamente):
1. Abra o PowerShell na pasta `pt_br/` do projeto.
2. Execute o script de compilação:
   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File build_exe.ps1
   ```
3. O executável final compilado estará disponível em `dist/SmartDevInstaller.exe`.

---

## 📄 Licença

Este projeto é licenciado sob os termos da licença **MIT**. Veja o arquivo [LICENSE](../LICENSE) na raiz do projeto para mais detalhes.

---

## ✉️ Contato

Para dúvidas, sugestões ou suporte, entre em contato através do e-mail:
📧 **webforservices@gmail.com**

---

## ☕ Apoie o Projeto (Doação)

Se este projeto te poupou tempo no setup do seu ambiente de desenvolvimento, considere apoiar o projeto fazendo uma doação!

<div align="center">

### 🌐 PayPal
[![Donate with PayPal](https://img.shields.io/badge/Donate-PayPal-blue.svg?style=for-the-badge&logo=paypal)](https://www.paypal.com/donate/?hosted_button_id=T3472SUH7RP52)

👉 **[Clique aqui para doar via PayPal](https://www.paypal.com/donate/?hosted_button_id=T3472SUH7RP52)**

<br/>

<img src="assets/paypal_qr.png" alt="PayPal QR Code" width="180"/>

---

### 🇧🇷 Pix (Copia e Cola)

```text
00020126580014BR.GOV.BCB.PIX0136abdcd399-03eb-4203-8f9c-97dc96a5146d5204000053039865802BR5925Mauricio Antonio Oliveira6009SAO PAULO62140510MzCTa2ToEb63040C07
```

<br/>

<img src="assets/pix_qr.png" alt="Pix QR Code" width="180"/>

</div>
