# SmartDev Installer (Português)

Interface gráfica moderna (estilo Rufus) para automatizar a configuração e instalação de ferramentas de desenvolvimento no Windows através do Winget.

---

## ⚠️ AVISO DE ISENÇÃO DE RESPONSABILIDADE (DISCLAIMER)

**LEIA COM ATENÇÃO ANTES DE USAR OU EXECUTAR O INSTALADOR:**

1. **Uso por sua Conta e Risco:** Este software é fornecido "no estado em que se encontra" (AS IS), sem garantias de qualquer tipo, expressas ou implícitas. O autor não assume qualquer responsabilidade por erros, omissões ou possíveis danos ao seu sistema operacional, perda de dados ou instabilidade de software.
2. **Modificação de Sistema:** Este programa executa instalações no nível do sistema usando privilégios de administrador (UAC) e modifica variáveis de ambiente cruciais (como `PATH`, `ANDROID_HOME` e `JAVA_HOME`). Recomendamos realizar um backup ou ponto de restauração do sistema antes da execução.
3. **Sem Garantia de Sucesso:** A instalação dos pacotes depende do repositório público `winget` e da conexão de internet. Falhas de download ou incompatibilidade de pacotes de terceiros não são de responsabilidade deste projeto.

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
3. O executável final compilado estará disponível em `dist/SmartDevInstaller.exe` dentro desta pasta.

---

## 📄 Licença

Este projeto é licenciado sob os termos da licença **MIT**. Veja o arquivo [LICENSE](../LICENSE) na raiz do projeto para mais detalhes.

---

## ✉️ Contato

Para dúvidas, sugestões ou suporte, entre em contato através do e-mail:
📧 **webforservices@gmail.com**

---

## ☕ Apoie o Projeto (Doação)

Se este projeto te poupou tempo, considere apoiar o desenvolvimento fazendo uma doação via **Pix**!

### Pix (Copia e Cola)
Copie o código abaixo e cole no aplicativo do seu banco:
```text
00020126580014BR.GOV.BCB.PIX0136abdcd399-03eb-4203-8f9c-97dc96a5146d5204000053039865802BR5925Mauricio Antonio Oliveira6009SAO PAULO62140510MzCTa2ToEb63040C07
```
