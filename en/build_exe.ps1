# Compilation Script - SmartDevInstaller

Write-Host "==============================================" -ForegroundColor Blue
Write-Host "  STARTING SMARTDEV INSTALLER BUILD           " -ForegroundColor Blue
Write-Host "==============================================" -ForegroundColor Blue

# 1. Check and install Python dependencies
Write-Host "`n[1/3] Checking Python dependencies..." -ForegroundColor Yellow

Write-Host "Checking customtkinter..."
python -c "import customtkinter" 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "Installing customtkinter..." -ForegroundColor Green
    python -m pip install customtkinter
} else {
    Write-Host "customtkinter is already installed." -ForegroundColor Green
}

Write-Host "Checking pyinstaller..."
python -c "import PyInstaller" 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "Installing pyinstaller..." -ForegroundColor Green
    python -m pip install pyinstaller
} else {
    Write-Host "pyinstaller is already installed." -ForegroundColor Green
}

# 2. Compile with PyInstaller
Write-Host "`n[2/3] Compiling executable with PyInstaller..." -ForegroundColor Yellow

$batFile = "smartdev_installer.bat"
if (-not (Test-Path $batFile)) {
    Write-Error "Backend file $batFile not found! Aborting."
    exit 1
}

# Compilation command
python -m PyInstaller --noconsole --onefile --uac-admin --name "SmartDevInstaller" --add-data "smartdev_installer.bat;." gui_app.py

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n[3/3] Build completed successfully!" -ForegroundColor Green
    Write-Host "The executable was generated in: dist\SmartDevInstaller.exe" -ForegroundColor Green
} else {
    Write-Error "Build failed with PyInstaller."
    exit 1
}
