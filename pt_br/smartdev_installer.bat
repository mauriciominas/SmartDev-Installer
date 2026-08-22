@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul
title Instalador Dev Completo V10

REM --- Elevacao de privilegio ---
fltmc >nul 2>&1
if %errorlevel% neq 0 (
    echo Solicitando privilegios de administrador...
    set "BATCH_PATH=%~f0"
    set "BATCH_DIR=%~dp0"
    powershell -NoProfile -ExecutionPolicy Bypass -Command "(New-Object -ComObject Shell.Application).ShellExecute($env:BATCH_PATH, '', $env:BATCH_DIR, 'runas', 1)"
    exit /b
)

REM --- Garantir diretorio correto apos elevacao ---
cd /d "%~dp0"

if "%LOG_DIR%"=="" set "LOG_DIR=%~dp0"
set "LOGFILE=%LOG_DIR%log.txt"
set "WINGETLOG=%LOG_DIR%winget.log"
set "TMPOUT=%LOG_DIR%_tmp_winget.txt"

echo ============================================ > "%LOGFILE%"
echo INSTALADOR DEV V10 - %date% %time% >> "%LOGFILE%"
echo ============================================ >> "%LOGFILE%"

if "%TOTAL_STEPS%"=="" set "TOTAL_STEPS=18"
set /a CURRENT_STEP=0

call :NextStep "Atualizando fontes Winget..."
winget source update >> "%WINGETLOG%" 2>&1

call :NextStep "Atualizando App Installer..."
winget upgrade --id Microsoft.AppInstaller --accept-package-agreements --accept-source-agreements >> "%WINGETLOG%" 2>&1

echo.
echo ============================================
echo AMBIENTE DE DESENVOLVIMENTO
echo ============================================
echo [Controle de Versao]
echo   g - Git
echo   h - GitHub Desktop
echo [Linguagens e Runtimes]
echo   n - Node.js
echo   p - Python 3
echo   j - Java Temurin (LTS 21)
echo   e - Deno Runtime
echo [Editores e IDEs]
echo   c - Visual Studio Code
echo [Mobile e Desktop]
echo   f - Flutter SDK
echo   a - Android Studio
echo   m - Android SDK Minimo (cmdline-tools)
echo   v - Visual Studio Build Tools
echo [APIs e Bancos de Dados]
echo   t - Postman
echo   b - DBeaver Community
echo   s - Supabase CLI
echo [Containers e Testes]
echo   d - Docker CLI
echo   w - Playwright CLI (E2E)
echo [Geral]
echo   u - Atualizar TUDO
echo.

if "%ESCOLHAS%"=="" set /p ESCOLHAS=Digite as letras desejadas: 

echo !ESCOLHAS! | find /I "g" >nul && (call :NextStep "Processando Git..." & call :Pkg Git.Git Git)
echo !ESCOLHAS! | find /I "h" >nul && (call :NextStep "Processando GitHub Desktop..." & call :Pkg GitHub.GitHubDesktop GitHubDesktop)
echo !ESCOLHAS! | find /I "n" >nul && (call :NextStep "Processando Node.js..." & call :Pkg OpenJS.NodeJS NodeJS)
echo !ESCOLHAS! | find /I "p" >nul && (call :NextStep "Processando Python..." & call :Python)
echo !ESCOLHAS! | find /I "j" >nul && (call :NextStep "Processando Java Temurin..." & call :Java)
echo !ESCOLHAS! | find /I "e" >nul && (call :NextStep "Processando Deno..." & call :Pkg DenoLand.Deno Deno)
echo !ESCOLHAS! | find /I "c" >nul && (call :NextStep "Processando Visual Studio Code..." & call :Pkg Microsoft.VisualStudioCode VSCode)
echo !ESCOLHAS! | find /I "f" >nul && (call :NextStep "Processando Flutter..." & call :Flutter)
echo !ESCOLHAS! | find /I "a" >nul && (call :NextStep "Processando Android Studio..." & call :Pkg Google.AndroidStudio AndroidStudio)
echo !ESCOLHAS! | find /I "m" >nul && (call :NextStep "Processando Android SDK..." & call :AndroidSDK)
echo !ESCOLHAS! | find /I "v" >nul && (call :NextStep "Processando Visual Studio Build Tools..." & call :Pkg Microsoft.VisualStudio.2022.BuildTools VSBuildTools)
echo !ESCOLHAS! | find /I "t" >nul && (call :NextStep "Processando Postman..." & call :Pkg Postman.Postman Postman)
echo !ESCOLHAS! | find /I "b" >nul && (call :NextStep "Processando DBeaver Community..." & call :Pkg DBeaver.DBeaver.Community DBeaver)
echo !ESCOLHAS! | find /I "s" >nul && (call :NextStep "Processando Supabase CLI..." & call :Supabase)
echo !ESCOLHAS! | find /I "d" >nul && (call :NextStep "Processando Docker CLI..." & call :Pkg Docker.DockerCLI DockerCLI)
echo !ESCOLHAS! | find /I "w" >nul && (call :NextStep "Processando Playwright CLI..." & call :Playwright)
echo !ESCOLHAS! | find /I "u" >nul && (call :NextStep "Atualizando todos os componentes..." & call :UpdateDev)

call :NextStep "Configurando variaveis de ambiente e caminhos no PATH..."
call :ConfigurePaths

call :NextStep "Gerando resumo do ambiente..."
call :Summary

REM --- Limpeza e formatacao dos logs de saida ---
powershell -NoProfile -ExecutionPolicy Bypass -Command "$w=$env:WINGETLOG;$l=$env:LOGFILE;if(Test-Path $w){$cleaned=Get-Content -Encoding utf8 $w|Where-Object{$_.Trim() -notmatch '^\s*[-/\\|]\s*$' -and $_.Trim() -notmatch '[-^'']+\s+\d+\.?\d*\s*(?:KB|MB|GB|B)\s*/' -and $_.Trim() -notmatch '^\s*[\-^'']+\s*$' -and $_ -notmatch '\d+%\s*$'};$final=@();$last=$false;foreach($line in $cleaned){if($line.Trim() -eq ''){if(-not $last){$final+='';$last=$true}}else{$final+=$line;$last=$false}};$final|Out-File $w -Encoding utf8 -Force};if(Test-Path $l){$cleaned=Get-Content -Encoding utf8 $l|Where-Object{$_ -notmatch 'O sistema n(a|o|ao|o) pode localizar o r(o|a)tulo'};$final=@();$last=$false;foreach($line in $cleaned){if($line.Trim() -eq ''){if(-not $last){$final+='';$last=$true}}else{$final+=$line;$last=$false}};$final|Out-File $l -Encoding utf8 -Force}"

echo.
echo ============================================================
echo   PROCESSO CONCLUIDO COM SUCESSO!
echo ============================================================
echo   Os arquivos de log foram limpos, otimizados e salvos em:
echo   - Log de Execucao:  "%LOGFILE%"
echo   - Log do Winget:    "%WINGETLOG%"
echo ============================================================
echo.
if not "%GUI_MODE%"=="1" pause
exit /b

REM ============================================================
REM :NextStep <mensagem>
REM ============================================================
:NextStep
set /a CURRENT_STEP+=1
echo [%CURRENT_STEP%/%TOTAL_STEPS%] %~1
goto :eof

REM ============================================================
REM :WhereCheck <comando>
REM ============================================================
:WhereCheck
where %1 >nul 2>&1
exit /b %errorlevel%

REM ============================================================
REM :WhereLog <comando>
REM ============================================================
:WhereLog
where %1 >> "%LOGFILE%" 2>&1
goto :eof

REM ============================================================
REM :Pkg <winget-id> <nome-amigavel>
REM ============================================================
:Pkg
echo Verificando %2...
echo --- %2 [%date% %time%] --- >> "%WINGETLOG%"

REM Tenta atualizar primeiro
winget upgrade --id %1 -e --accept-package-agreements --accept-source-agreements > "%TMPOUT%" 2>&1
type "%TMPOUT%" >> "%WINGETLOG%"

REM Verifica se o pacote nao esta instalado
findstr /I /C:"No installed package found" "%TMPOUT%" >nul 2>&1
if not errorlevel 1 goto :PkgInstall
findstr /I /C:"Nenhum pacote instalado" "%TMPOUT%" >nul 2>&1
if not errorlevel 1 goto :PkgInstall

REM Verifica se ja esta na versao mais recente (EN + PT)
findstr /I /C:"No applicable update found" "%TMPOUT%" >nul 2>&1
if not errorlevel 1 (
    echo   [OK] %2 ja esta atualizado.
    echo   %2: ja atualizado >> "%LOGFILE%"
    goto :eof
)
findstr /I /C:"foi encontrada" "%TMPOUT%" >nul 2>&1
if not errorlevel 1 (
    echo   [OK] %2 ja esta atualizado.
    echo   %2: ja atualizado >> "%LOGFILE%"
    goto :eof
)
findstr /I /C:"mais recente" "%TMPOUT%" >nul 2>&1
if not errorlevel 1 (
    echo   [OK] %2 ja esta atualizado.
    echo   %2: ja atualizado >> "%LOGFILE%"
    goto :eof
)

REM Se chegou aqui, o upgrade foi executado com sucesso
echo   [OK] %2 atualizado com sucesso.
echo   %2: atualizado >> "%LOGFILE%"
goto :eof

:PkgInstall
echo   Instalando %2...
winget install --id %1 -e --accept-package-agreements --accept-source-agreements >> "%WINGETLOG%" 2>&1
if errorlevel 1 (
    echo   [ERRO] Falha ao instalar %2. Verifique winget.log.
    echo   %2: ERRO na instalacao >> "%LOGFILE%"
) else (
    echo   [OK] %2 instalado com sucesso.
    echo   %2: instalado >> "%LOGFILE%"
)
goto :eof

REM ============================================================
REM :Python — Detecta alias da Microsoft Store e busca versao estavel
REM ============================================================
:Python
call :WhereCheck python
if not errorlevel 1 (
    python --version > "%TMPOUT%" 2>&1
    findstr /I /C:"was not found" "%TMPOUT%" >nul 2>&1
    if not errorlevel 1 (
        echo   AVISO: Alias da Microsoft Store detectado para Python.
        echo   AVISO: Alias Microsoft Store Python >> "%LOGFILE%"
    )
)

echo Buscando a versao mais recente estavel do Python no Winget...
winget search --id Python.Python > "%TMPOUT%" 2>&1

set PYTHON_ID=
for /f "delims=" %%I in ('powershell -NoProfile -ExecutionPolicy Bypass -Command "if (Test-Path $env:TMPOUT) { Get-Content $env:TMPOUT | Select-String -Pattern 'Python\.Python\.\d+(?:\.\d+)*' -AllMatches | ForEach-Object { $_.Matches.Value } | Sort-Object { $v = $_ -replace 'Python\.Python\.', ''; if ($v -notlike '*.*') { $v += '.0' }; [version]$v } -Descending | Select-Object -First 1 }"') do (
    set "PYTHON_ID=%%I"
)

if not defined PYTHON_ID (
    echo   [AVISO] Nenhuma versao dinamica de Python encontrada. Usando Python.Python.3.12 como padrao.
    set "PYTHON_ID=Python.Python.3.12"
) else (
    echo   Versao encontrada: !PYTHON_ID!
)

call :Pkg !PYTHON_ID! Python
goto :eof

REM ============================================================
REM :Java — Busca a versao LTS (JDK 21) do Temurin
REM ============================================================
:Java
echo Buscando a versao LTS do Java Temurin no Winget...
winget search --id EclipseAdoptium.Temurin > "%TMPOUT%" 2>&1

set JAVA_ID=
for /f "delims=" %%I in ('powershell -NoProfile -ExecutionPolicy Bypass -Command "if (Test-Path $env:TMPOUT) { Get-Content $env:TMPOUT | Select-String -Pattern 'EclipseAdoptium\.Temurin\.(21|17)\.JDK' -AllMatches | ForEach-Object { $_.Matches.Value } | Sort-Object { [int]($_ -replace 'EclipseAdoptium\.Temurin\.', '' -replace '\.JDK', '') } -Descending | Select-Object -First 1 }"') do (
    set "JAVA_ID=%%I"
)

if not defined JAVA_ID (
    echo   [AVISO] Nenhuma versao LTS Temurin encontrada no Winget. Usando EclipseAdoptium.Temurin.21.JDK como padrao.
    set "JAVA_ID=EclipseAdoptium.Temurin.21.JDK"
) else (
    echo   Versao LTS encontrada: !JAVA_ID!
)

call :Pkg !JAVA_ID! "Java Temurin"
goto :eof

REM ============================================================
REM :Flutter — Instala ou exibe versao existente
REM ============================================================
:Flutter
call :WhereCheck flutter
if errorlevel 1 (
    call :Pkg Flutter.Flutter Flutter
) else (
    echo   Flutter ja instalado:
    call flutter --version 2>&1 | findstr /I "Flutter" && echo.
    call flutter --version >> "%LOGFILE%" 2>&1
    call flutter doctor -v >> "%LOGFILE%" 2>&1
)
goto :eof

REM ============================================================
REM :Playwright — Instala Playwright CLI via npm
REM ============================================================
:Playwright
echo Verificando Playwright CLI...
call :WhereCheck npm
if errorlevel 1 (
    echo   [AVISO] Node.js/npm nao encontrado. Instalando Node.js primeiro...
    call :Pkg OpenJS.NodeJS NodeJS
)

echo   Instalando @playwright/test globalmente via npm...
call npm install -g @playwright/test >> "%WINGETLOG%" 2>&1
if errorlevel 1 (
    echo   [ERRO] Falha ao instalar @playwright/test via npm.
    echo   Playwright: ERRO na instalacao >> "%LOGFILE%"
) else (
    echo   [OK] Playwright CLI instalado com sucesso via npm.
    echo   Playwright: instalado >> "%LOGFILE%"
)
goto :eof

REM ============================================================
REM :Supabase — Tenta winget, fallback para npm
REM ============================================================
:Supabase
call :WhereCheck supabase
if errorlevel 1 (
    echo   Instalando Supabase CLI via Winget...
    winget install --id Supabase.CLI -e --accept-package-agreements --accept-source-agreements > "%TMPOUT%" 2>&1
    type "%TMPOUT%" >> "%WINGETLOG%"
    
    findstr /I /C:"No package found" "%TMPOUT%" >nul 2>&1
    if not errorlevel 1 (
        echo   Winget falhou, tentando npm...
        call :WhereCheck npm
        if errorlevel 1 (
            echo   [ERRO] npm nao encontrado. Instale Node.js primeiro.
            echo   Supabase: ERRO - npm nao encontrado >> "%LOGFILE%"
            goto :eof
        )
        call npm install -g supabase >> "%WINGETLOG%" 2>&1
    )
) else (
    echo   Supabase CLI ja instalado.
)

call :WhereCheck supabase
if not errorlevel 1 (
    call supabase --version >> "%LOGFILE%" 2>&1
    echo   Supabase: OK >> "%LOGFILE%"
) else (
    echo   [AVISO] Supabase nao encontrado no PATH apos instalacao.
    echo   [AVISO] Feche e reabra o terminal para usar.
    echo   Supabase: instalado, requer novo terminal >> "%LOGFILE%"
)
goto :eof

REM ============================================================
REM :AndroidSDK — Instala Android Command Line Tools
REM ============================================================
:AndroidSDK
echo Verificando Android SDK (cmdline-tools)...
call :WhereCheck sdkmanager
if not errorlevel 1 (
    echo   [OK] Android SDK cmdline-tools ja disponivel.
    call sdkmanager --version >> "%LOGFILE%" 2>&1
    echo   Android SDK: ja instalado >> "%LOGFILE%"
    goto :eof
)
call :Pkg Google.Android.CommandLineTools AndroidSDK
echo   [INFO] ANDROID_HOME e caminhos no PATH serao configurados automaticamente.
echo   Android SDK: verificar ANDROID_HOME >> "%LOGFILE%"
goto :eof

REM ============================================================
REM :UpdateDev — Atualiza todos os componentes
REM ============================================================
:UpdateDev
echo.
echo === Atualizando todos os componentes ===
call :Pkg Git.Git Git
call :Pkg GitHub.GitHubDesktop GitHubDesktop
call :Pkg OpenJS.NodeJS NodeJS
call :Python
call :Java
call :Pkg DenoLand.Deno Deno
call :Pkg Microsoft.VisualStudioCode VSCode
call :Flutter
call :Pkg Google.AndroidStudio AndroidStudio
call :Pkg Microsoft.VisualStudio.2022.BuildTools VSBuildTools
call :Pkg Postman.Postman Postman
call :Pkg DBeaver.DBeaver.Community DBeaver
call :Pkg Docker.DockerCLI DockerCLI
call :Supabase
call :Playwright
goto :eof

REM ============================================================
REM :ConfigurePaths — Configura PATH e variaveis de ambiente de forma segura
REM ============================================================
:ConfigurePaths
echo Configurando variaveis de ambiente e caminhos no PATH...

powershell -NoProfile -ExecutionPolicy Bypass -Command "$sdkPaths = @(Join-Path $env:LOCALAPPDATA 'Android\Sdk', 'C:\Android\android-sdk', Join-Path $env:ProgramFiles 'Android\Android SDK', Join-Path $env:LOCALAPPDATA 'Programs\Android\Android SDK'); $sdkDir = $sdkPaths | Where-Object { Test-Path $_ } | Select-Object -First 1; if ($sdkDir) { [Environment]::SetEnvironmentVariable('ANDROID_HOME', $sdkDir, 'User'); $env:ANDROID_HOME = $sdkDir; $pathsToAdd = @((Join-Path $sdkDir 'cmdline-tools\latest\bin'), (Join-Path $sdkDir 'cmdline-tools\bin'), (Join-Path $sdkDir 'platform-tools'), (Join-Path $sdkDir 'emulator')); foreach ($p in $pathsToAdd) { if (Test-Path $p) { $userPath = [Environment]::GetEnvironmentVariable('PATH', 'User'); $current = if ($userPath) { $userPath -split ';' | Where-Object { $_.Trim() -ne '' } } else { @() }; if ($current -notcontains $p) { $newPath = ($current + $p) -join ';'; [Environment]::SetEnvironmentVariable('PATH', $newPath, 'User'); Write-Host ('  Adicionado ao PATH: ' + $p) } } } }; $flutterPaths = @(Join-Path $env:LOCALAPPDATA 'Programs\flutter\bin', 'C:\flutter\bin', 'C:\src\flutter\bin', Join-Path $env:USERPROFILE 'flutter\bin'); $flutterBin = $flutterPaths | Where-Object { Test-Path $_ } | Select-Object -First 1; if ($flutterBin) { $userPath = [Environment]::GetEnvironmentVariable('PATH', 'User'); $current = if ($userPath) { $userPath -split ';' | Where-Object { $_.Trim() -ne '' } } else { @() }; if ($current -notcontains $flutterBin) { $newPath = ($current + $flutterBin) -join ';'; [Environment]::SetEnvironmentVariable('PATH', $newPath, 'User'); Write-Host ('  Adicionado ao PATH: ' + $flutterBin) } }; $javaPaths = @(Join-Path $env:ProgramFiles 'Eclipse Adoptium', Join-Path $env:ProgramFiles 'Eclipse Foundation'); $javaDir = $null; foreach ($jp in $javaPaths) { if (Test-Path $jp) { $jdkDir = Get-ChildItem $jp -Filter 'jdk-*' | Select-Object -First 1; if ($jdkDir) { $javaDir = $jdkDir.FullName; break } } }; if ($javaDir) { [Environment]::SetEnvironmentVariable('JAVA_HOME', $javaDir, 'User'); $env:JAVA_HOME = $javaDir; $javaBin = Join-Path $javaDir 'bin'; $userPath = [Environment]::GetEnvironmentVariable('PATH', 'User'); $current = if ($userPath) { $userPath -split ';' | Where-Object { $_.Trim() -ne '' } } else { @() }; if ($current -notcontains $javaBin) { $newPath = ($current + $javaBin) -join ';'; [Environment]::SetEnvironmentVariable('PATH', $newPath, 'User'); Write-Host ('  Adicionado ao PATH: ' + $javaBin) } }"
goto :eof

REM ============================================================
REM :Summary — Exibe e registra resumo do ambiente
REM ============================================================
:Summary
echo.
echo ============================================
echo RESUMO DO AMBIENTE
echo ============================================
echo ===== RESUMO ===== >> "%LOGFILE%"

for %%C in (git node python java deno code flutter supabase sdkmanager docker postman dbeaver) do (
    call :WhereCheck %%C
    if not errorlevel 1 (
        echo   %%C: encontrado
        call :WhereLog %%C
    ) else (
        echo   %%C: nao encontrado
    )
)

echo --- Versoes --- >> "%LOGFILE%"

git --version >> "%LOGFILE%" 2>&1
node --version >> "%LOGFILE%" 2>&1
python --version >> "%LOGFILE%" 2>&1
java -version >> "%LOGFILE%" 2>&1
call deno --version >> "%LOGFILE%" 2>&1
call code --version >> "%LOGFILE%" 2>&1
call flutter --version >> "%LOGFILE%" 2>&1
call supabase --version >> "%LOGFILE%" 2>&1
call docker --version >> "%LOGFILE%" 2>&1
call npx playwright --version >> "%LOGFILE%" 2>&1

REM Limpar arquivo temporario
if exist "%TMPOUT%" del "%TMPOUT%"
goto :eof
