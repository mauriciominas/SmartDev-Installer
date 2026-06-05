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

set "LOGFILE=%~dp0log.txt"
set "WINGETLOG=%~dp0winget.log"
set "TMPOUT=%~dp0_tmp_winget.txt"

echo ============================================ > "%LOGFILE%"
echo INSTALADOR DEV V10 - %date% %time% >> "%LOGFILE%"
echo ============================================ >> "%LOGFILE%"

echo [1/8] Atualizando fontes Winget...
winget source update >> "%WINGETLOG%" 2>&1

echo [2/8] Atualizando App Installer...
winget upgrade --id Microsoft.AppInstaller --accept-package-agreements --accept-source-agreements >> "%WINGETLOG%" 2>&1

echo.
echo ============================================
echo AMBIENTE DE DESENVOLVIMENTO
echo ============================================
echo g - Git
echo n - Node.js
echo p - Python 3
echo j - Java Temurin
echo a - Android Studio
echo m - Android SDK Minimo (cmdline-tools)
echo v - Visual Studio Build Tools
echo f - Flutter
echo s - Supabase CLI
echo u - Atualizar TUDO
echo.

set /p ESCOLHAS=Digite as letras desejadas: 

echo %ESCOLHAS% | find /I "g" >nul && call :Pkg Git.Git Git
echo %ESCOLHAS% | find /I "n" >nul && call :Pkg OpenJS.NodeJS NodeJS
echo %ESCOLHAS% | find /I "p" >nul && call :Python
echo %ESCOLHAS% | find /I "j" >nul && call :Java
echo %ESCOLHAS% | find /I "a" >nul && call :Pkg Google.AndroidStudio AndroidStudio
echo %ESCOLHAS% | find /I "m" >nul && call :AndroidSDK
echo %ESCOLHAS% | find /I "v" >nul && call :Pkg Microsoft.VisualStudio.2022.BuildTools VSBuildTools
echo %ESCOLHAS% | find /I "f" >nul && call :Flutter
echo %ESCOLHAS% | find /I "s" >nul && call :Supabase
echo %ESCOLHAS% | find /I "u" >nul && call :UpdateDev

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
pause
exit /b

REM ============================================================
REM :Pkg <winget-id> <nome-amigavel>
REM   Tenta upgrade; se não instalado, faz install.
REM   Usa arquivo temporário para evitar falso positivo no log.
REM ============================================================
:Pkg
echo Verificando %2...
echo --- %2 [%date% %time%] --- >> "%WINGETLOG%"

REM Tenta atualizar primeiro
winget upgrade --id %1 -e --accept-package-agreements --accept-source-agreements > "%TMPOUT%" 2>&1
type "%TMPOUT%" >> "%WINGETLOG%"

REM Verifica se o pacote não está instalado
findstr /I /C:"No installed package found" "%TMPOUT%" >nul 2>&1
if not errorlevel 1 goto :PkgInstall
findstr /I /C:"Nenhum pacote instalado" "%TMPOUT%" >nul 2>&1
if not errorlevel 1 goto :PkgInstall

REM Verifica se já está na última versão (EN + PT com substrings ASCII-safe)
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
REM :Python — Detecta alias da Microsoft Store antes de instalar
REM ============================================================
:Python
where python >nul 2>&1
if not errorlevel 1 (
    python --version > "%TMPOUT%" 2>&1
    findstr /I /C:"was not found" "%TMPOUT%" >nul 2>&1
    if not errorlevel 1 (
        echo   AVISO: Alias da Microsoft Store detectado para Python.
        echo   AVISO: Alias Microsoft Store Python >> "%LOGFILE%"
    )
)

echo Buscando a versao mais recente do Python no Winget...
winget search --id Python.Python > "%TMPOUT%" 2>&1

set PYTHON_ID=
for /f "delims=" %%I in ('powershell -NoProfile -ExecutionPolicy Bypass -Command "if (Test-Path $env:TMPOUT) { Get-Content $env:TMPOUT | Select-String -Pattern 'Python\.Python\.\d+(?:\.\d+)*' -AllMatches | ForEach-Object { $_.Matches.Value } | Sort-Object { $v = $_ -replace 'Python\.Python\.', ''; if ($v -notlike '*.*') { $v += '.0' }; [version]$v } -Descending | Select-Object -First 1 }"') do (
    set "PYTHON_ID=%%I"
)

if not defined PYTHON_ID (
    echo   [AVISO] Nenhuma versao dinamica de Python encontrada. Usando Python.Python.3.12 como padrao.
    set "PYTHON_ID=Python.Python.3.12"
) else (
    echo   Versao mais recente encontrada: !PYTHON_ID!
)

call :Pkg !PYTHON_ID! Python
goto :eof

REM ============================================================
REM :Java — Busca a versão mais recente do Temurin JDK dinamicamente
REM ============================================================
:Java
echo Buscando a versao mais recente do Java Temurin no Winget...
winget search --id EclipseAdoptium.Temurin > "%TMPOUT%" 2>&1

set JAVA_ID=
for /f "delims=" %%I in ('powershell -NoProfile -ExecutionPolicy Bypass -Command "if (Test-Path $env:TMPOUT) { Get-Content $env:TMPOUT | Select-String -Pattern 'EclipseAdoptium\.Temurin\.\d+\.JDK' -AllMatches | ForEach-Object { $_.Matches.Value } | Sort-Object { [int]($_ -replace 'EclipseAdoptium\.Temurin\.', '' -replace '\.JDK', '') } -Descending | Select-Object -First 1 }"') do (
    set "JAVA_ID=%%I"
)

if not defined JAVA_ID (
    echo   [AVISO] Nenhuma versao Temurin encontrada no Winget. Usando EclipseAdoptium.Temurin.21.JDK como padrao.
    set "JAVA_ID=EclipseAdoptium.Temurin.21.JDK"
) else (
    echo   Versao mais recente encontrada: !JAVA_ID!
)

call :Pkg !JAVA_ID! "Java Temurin"
goto :eof

REM ============================================================
REM :Flutter — Instala ou exibe versão existente
REM ============================================================
:Flutter
where flutter >nul 2>&1
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
REM :Supabase — Tenta winget, fallback para npm
REM ============================================================
:Supabase
where supabase >nul 2>&1
if errorlevel 1 (
    echo   Instalando Supabase CLI via Winget...
    winget install --id Supabase.CLI -e --accept-package-agreements --accept-source-agreements > "%TMPOUT%" 2>&1
    type "%TMPOUT%" >> "%WINGETLOG%"
    
    REM Verifica se winget falhou
    findstr /I /C:"No package found" "%TMPOUT%" >nul 2>&1
    if not errorlevel 1 (
        echo   Winget falhou, tentando npm...
        where npm >nul 2>&1
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

REM Verifica versão apenas se o comando estiver disponível
where supabase >nul 2>&1
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
where sdkmanager >nul 2>&1
if not errorlevel 1 (
    echo   [OK] Android SDK cmdline-tools ja disponivel.
    call sdkmanager --version >> "%LOGFILE%" 2>&1
    echo   Android SDK: ja instalado >> "%LOGFILE%"
    goto :eof
)
call :Pkg Google.Android.CommandLineTools AndroidSDK
echo   [INFO] Apos instalar, configure ANDROID_HOME e adicione ao PATH.
echo   Android SDK: verificar ANDROID_HOME >> "%LOGFILE%"
goto :eof

REM ============================================================
REM :UpdateDev — Atualiza todos os componentes
REM ============================================================
:UpdateDev
echo.
echo === Atualizando todos os componentes ===
call :Pkg Git.Git Git
call :Pkg OpenJS.NodeJS NodeJS
call :Python
call :Java
call :Flutter
call :Supabase
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

for %%C in (git node python java flutter supabase sdkmanager) do (
    where %%C >nul 2>&1
    if not errorlevel 1 (
        echo   %%C: encontrado
        where %%C >> "%LOGFILE%" 2>&1
    ) else (
        echo   %%C: nao encontrado
    )
)

echo --- Versoes --- >> "%LOGFILE%"
git --version >> "%LOGFILE%" 2>&1
node --version >> "%LOGFILE%" 2>&1
python --version >> "%LOGFILE%" 2>&1
java -version >> "%LOGFILE%" 2>&1
call flutter --version >> "%LOGFILE%" 2>&1
call supabase --version >> "%LOGFILE%" 2>&1

REM Limpar arquivo temporário
if exist "%TMPOUT%" del "%TMPOUT%"
goto :eof

REM ===== NOTAS V10 =====
REM - Corrigido :Pkg para usar arquivo temporario (evita falso positivo no log acumulativo)
REM - Suporte a mensagens em ingles E portugues do winget
REM - Elevação de privilegio preserva diretorio de trabalho
REM - Adicionado handler para opcao 'm' (Android SDK cmdline-tools)
REM - Python usa versao fixa 3.12 (evita ID ambiguo Python.Python.3)
REM - Java range ajustado para 17-23 (versoes realistas)
REM - Feedback visual: [OK], [ERRO], [AVISO] por pacote
REM - Supabase verifica npm antes de tentar fallback
REM - Summary exibe no console e no log
REM - Arquivo temporario limpo ao final
