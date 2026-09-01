# Build

Os executáveis publicados nas releases são gerados automaticamente pelo
workflow [`.github/workflows/build-release.yml`](.github/workflows/build-release.yml)
a cada tag `v*`. Esta página documenta como reproduzir o mesmo build localmente.

> The installers published in the releases are built automatically by the
> workflow above on every `v*` tag. This page documents how to reproduce the
> same build locally.

## Requisitos / Requirements

- Windows
- Python 3.12
- `pip install pyinstaller customtkinter`

## Comando / Command

Rode de dentro de `en/` ou `pt_br/`, trocando o `--name` conforme a pasta:

```bash
# en/
pyinstaller --onefile --windowed --uac-admin --clean --noconfirm \
  --name "SmartDev-Installer-EN" \
  --add-data "smartdev_installer.bat;." \
  --collect-all customtkinter \
  gui_app.py

# pt_br/
pyinstaller --onefile --windowed --uac-admin --clean --noconfirm \
  --name "SmartDev-Installer-pt-BR" \
  --add-data "smartdev_installer.bat;." \
  --collect-all customtkinter \
  gui_app.py
```

O binário sai em `<pasta>/dist/`. `build/`, `dist/` e `*.spec` são ignorados pelo Git.

## Por que essas flags / Why these flags

- `--onefile` — o `gui_app.py` lê `sys._MEIPASS`, que só existe em modo onefile.
- `--add-data "smartdev_installer.bat;."` — o `.bat` é o backend: a GUI o executa
  via `cmd.exe` e falha com "Backend file not found" se ele não for embutido.
- `--collect-all customtkinter` — o CustomTkinter carrega temas `.json` em tempo
  de execução; sem isso o `.exe` compila mas quebra ao abrir.
- `--uac-admin` — o executável exige administrador e o Windows pede UAC na
  abertura. Sem isso o `.bat` tentaria se elevar sozinho, e o processo elevado
  nasceria sem as variáveis que a GUI define (`ESCOLHAS`, `GUI_MODE`), caindo no
  menu de texto num console que a interface não consegue ler.
- `--windowed` — sem console: a saída do `.bat` já é exibida no log da própria GUI.

## Publicando uma versão / Releasing

```bash
git tag v1.1.0 && git push origin v1.1.0
```

O workflow compila os dois `.exe` e os anexa à release da tag. Os nomes dos
arquivos são fixos porque os READMEs apontam para
`releases/latest/download/SmartDev-Installer-{EN,pt-BR}.exe`.
