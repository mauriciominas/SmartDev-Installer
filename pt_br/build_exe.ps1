# Script de Compilação - SmartDevInstaller

Write-Host "==============================================" -ForegroundColor Blue
Write-Host "  INICIANDO COMPILACAO DO SMARTDEV INSTALLER   " -ForegroundColor Blue
Write-Host "==============================================" -ForegroundColor Blue

# 1. Verificar e instalar dependencias
Write-Host "`n[1/3] Verificando dependencias Python..." -ForegroundColor Yellow
python -m pip install --upgrade pip

Write-Host "Verificando customtkinter..."
python -c "import customtkinter" 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "Instalando customtkinter..." -ForegroundColor Green
    python -m pip install customtkinter
} else {
    Write-Host "customtkinter ja esta instalado." -ForegroundColor Green
}

Write-Host "Verificando pyinstaller..."
Get-Command pyinstaller -ErrorAction SilentlyContinue
if ($LASTEXITCODE -ne 0) {
    Write-Host "Instalando pyinstaller..." -ForegroundColor Green
    python -m pip install pyinstaller
} else {
    Write-Host "pyinstaller ja esta instalado." -ForegroundColor Green
}

# 2. Compilar com PyInstaller
Write-Host "`n[2/3] Compilando executavel com PyInstaller..." -ForegroundColor Yellow

# Obter caminho absoluto do script bat
$batFile = "smartdev_installer.bat"
if (-not (Test-Path $batFile)) {
    Write-Error "Arquivo backend $batFile nao encontrado! Abortando."
    exit 1
}

# Comando de compilação
# --add-data "smartdev_installer.bat;." empacota o bat junto ao executavel
python -m PyInstaller --noconsole --onefile --uac-admin --name "SmartDevInstaller" --add-data "smartdev_installer.bat;." gui_app.py

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n[3/3] Compilacao concluida com sucesso!" -ForegroundColor Green
    Write-Host "O executavel foi gerado em: dist\SmartDevInstaller.exe" -ForegroundColor Green
} else {
    Write-Error "Falha na compilacao com PyInstaller."
    exit 1
}
