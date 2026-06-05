@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul
title Dev Environment Installer V10

REM --- Privilege Elevation ---
fltmc >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting administrator privileges...
    set "BATCH_PATH=%~f0"
    set "BATCH_DIR=%~dp0"
    powershell -NoProfile -ExecutionPolicy Bypass -Command "(New-Object -ComObject Shell.Application).ShellExecute($env:BATCH_PATH, '', $env:BATCH_DIR, 'runas', 1)"
    exit /b
)

REM --- Ensure correct working directory after elevation ---
cd /d "%~dp0"

if "%LOG_DIR%"=="" set "LOG_DIR=%~dp0"
set "LOGFILE=%LOG_DIR%log.txt"
set "WINGETLOG=%LOG_DIR%winget.log"
set "TMPOUT=%LOG_DIR%_tmp_winget.txt"

echo ============================================ > "%LOGFILE%"
echo DEV INSTALLER - %date% %time% >> "%LOGFILE%"
echo ============================================ >> "%LOGFILE%"

echo [1/8] Updating Winget sources...
winget source update >> "%WINGETLOG%" 2>&1

echo [2/8] Updating App Installer...
winget upgrade --id Microsoft.AppInstaller --accept-package-agreements --accept-source-agreements >> "%WINGETLOG%" 2>&1

echo.
echo ============================================
echo DEVELOPER ENVIRONMENT INSTALLER
echo ============================================
echo g - Git
echo n - Node.js
echo p - Python 3
echo j - Java Temurin
echo a - Android Studio
echo m - Android SDK Minimum (cmdline-tools)
echo v - Visual Studio Build Tools
echo f - Flutter
echo s - Supabase CLI
echo u - Update ALL
echo.

if "%ESCOLHAS%"=="" set /p ESCOLHAS=Type the desired letters: 

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

call :ConfigurePaths
call :Summary

REM --- Clean and format output logs ---
powershell -NoProfile -ExecutionPolicy Bypass -Command "$w=$env:WINGETLOG;$l=$env:LOGFILE;if(Test-Path $w){$cleaned=Get-Content -Encoding utf8 $w|Where-Object{$_.Trim() -notmatch '^\s*[-/\\|]\s*$' -and $_.Trim() -notmatch '[-^'']+\s+\d+\.?\d*\s*(?:KB|MB|GB|B)\s*/' -and $_.Trim() -notmatch '^\s*[\-^'']+\s*$' -and $_ -notmatch '\d+%\s*$'};$final=@();$last=$false;foreach($line in $cleaned){if($line.Trim() -eq ''){if(-not $last){$final+='';$last=$true}}else{$final+=$line;$last=$false}};$final|Out-File $w -Encoding utf8 -Force};if(Test-Path $l){$cleaned=Get-Content -Encoding utf8 $l|Where-Object{$_ -notmatch 'The system cannot find the batch label'};$final=@();$last=$false;foreach($line in $cleaned){if($line.Trim() -eq ''){if(-not $last){$final+='';$last=$true}}else{$final+=$line;$last=$false}};$final|Out-File $l -Encoding utf8 -Force}"

echo.
echo ============================================================
echo   PROCESS COMPLETED SUCCESSFULLY!
echo ============================================================
echo   The log files were cleaned, optimized and saved in:
echo   - Execution Log:  "%LOGFILE%"
echo   - Winget Log:     "%WINGETLOG%"
echo ============================================================
echo.
if not "%GUI_MODE%"=="1" pause
exit /b

REM ============================================================
REM :WhereCheck <comando>
REM   Checks if command exists on system.
REM ============================================================
:WhereCheck
where %1 >nul 2>&1
exit /b %errorlevel%

REM ============================================================
REM :WhereLog <comando>
REM   Logs executable path.
REM ============================================================
:WhereLog
where %1 >> "%LOGFILE%" 2>&1
goto :eof

REM ============================================================
REM :Pkg <winget-id> <nome-amigavel>
REM   Attempts upgrade; installs if not installed.
REM ============================================================
:Pkg
echo Checking %2...
echo --- %2 [%date% %time%] --- >> "%WINGETLOG%"

REM Try upgrade first
winget upgrade --id %1 -e --accept-package-agreements --accept-source-agreements > "%TMPOUT%" 2>&1
type "%TMPOUT%" >> "%WINGETLOG%"

REM Check if package is not installed
findstr /I /C:"No installed package found" "%TMPOUT%" >nul 2>&1
if not errorlevel 1 goto :PkgInstall
findstr /I /C:"Nenhum pacote instalado" "%TMPOUT%" >nul 2>&1
if not errorlevel 1 goto :PkgInstall

REM Check if already on latest version
findstr /I /C:"No applicable update found" "%TMPOUT%" >nul 2>&1
if not errorlevel 1 (
    echo   [OK] %2 is already up to date.
    echo   %2: already up to date >> "%LOGFILE%"
    goto :eof
)
findstr /I /C:"foi encontrada" "%TMPOUT%" >nul 2>&1
if not errorlevel 1 (
    echo   [OK] %2 is already up to date.
    echo   %2: already up to date >> "%LOGFILE%"
    goto :eof
)
findstr /I /C:"mais recente" "%TMPOUT%" >nul 2>&1
if not errorlevel 1 (
    echo   [OK] %2 is already up to date.
    echo   %2: already up to date >> "%LOGFILE%"
    goto :eof
)

REM If reached here, upgrade was successful
echo   [OK] %2 updated successfully.
echo   %2: updated >> "%LOGFILE%"
goto :eof

:PkgInstall
echo   Installing %2...
winget install --id %1 -e --accept-package-agreements --accept-source-agreements >> "%WINGETLOG%" 2>&1
if errorlevel 1 (
    echo   [ERROR] Failed to install %2. Check winget.log.
    echo   %2: ERROR during installation >> "%LOGFILE%"
) else (
    echo   [OK] %2 installed successfully.
    echo   %2: installed >> "%LOGFILE%"
)
goto :eof

REM ============================================================
REM :Python
REM ============================================================
:Python
call :WhereCheck python
if not errorlevel 1 (
    python --version > "%TMPOUT%" 2>&1
    findstr /I /C:"was not found" "%TMPOUT%" >nul 2>&1
    if not errorlevel 1 (
        echo   WARNING: Microsoft Store alias detected for Python.
        echo   WARNING: Microsoft Store Python Alias >> "%LOGFILE%"
    )
)

echo Searching for the latest version of Python in Winget...
winget search --id Python.Python > "%TMPOUT%" 2>&1

set PYTHON_ID=
for /f "delims=" %%I in ('powershell -NoProfile -ExecutionPolicy Bypass -Command "if (Test-Path $env:TMPOUT) { Get-Content $env:TMPOUT | Select-String -Pattern 'Python\.Python\.\d+(?:\.\d+)*' -AllMatches | ForEach-Object { $_.Matches.Value } | Sort-Object { $v = $_ -replace 'Python\.Python\.', ''; if ($v -notlike '*.*') { $v += '.0' }; [version]$v } -Descending | Select-Object -First 1 }"') do (
    set "PYTHON_ID=%%I"
)

if not defined PYTHON_ID (
    echo   [WARNING] No dynamic version of Python found. Using Python.Python.3.12 as default.
    set "PYTHON_ID=Python.Python.3.12"
) else (
    echo   Latest version found: !PYTHON_ID!
)

call :Pkg !PYTHON_ID! Python
goto :eof

REM ============================================================
REM :Java
REM ============================================================
:Java
echo Searching for the latest version of Java Temurin in Winget...
winget search --id EclipseAdoptium.Temurin > "%TMPOUT%" 2>&1

set JAVA_ID=
for /f "delims=" %%I in ('powershell -NoProfile -ExecutionPolicy Bypass -Command "if (Test-Path $env:TMPOUT) { Get-Content $env:TMPOUT | Select-String -Pattern 'EclipseAdoptium\.Temurin\.\d+\.JDK' -AllMatches | ForEach-Object { $_.Matches.Value } | Sort-Object { [int]($_ -replace 'EclipseAdoptium\.Temurin\.', '' -replace '\.JDK', '') } -Descending | Select-Object -First 1 }"') do (
    set "JAVA_ID=%%I"
)

if not defined JAVA_ID (
    echo   [WARNING] No Temurin version found on Winget. Using EclipseAdoptium.Temurin.21.JDK as default.
    set "JAVA_ID=EclipseAdoptium.Temurin.21.JDK"
) else (
    echo   Latest version found: !JAVA_ID!
)

call :Pkg !JAVA_ID! "Java Temurin"
goto :eof

REM ============================================================
REM :Flutter
REM ============================================================
:Flutter
call :WhereCheck flutter
if errorlevel 1 (
    call :Pkg Flutter.Flutter Flutter
) else (
    echo   Flutter already installed:
    call flutter --version 2>&1 | findstr /I "Flutter" && echo.
    call flutter --version >> "%LOGFILE%" 2>&1
    call flutter doctor -v >> "%LOGFILE%" 2>&1
)
goto :eof

REM ============================================================
REM :Supabase
REM ============================================================
:Supabase
call :WhereCheck supabase
if errorlevel 1 (
    echo   Installing Supabase CLI via Winget...
    winget install --id Supabase.CLI -e --accept-package-agreements --accept-source-agreements > "%TMPOUT%" 2>&1
    type "%TMPOUT%" >> "%WINGETLOG%"
    
    REM Check if winget failed
    findstr /I /C:"No package found" "%TMPOUT%" >nul 2>&1
    if not errorlevel 1 (
        echo   Winget failed, trying npm...
        call :WhereCheck npm
        if errorlevel 1 (
            echo   [ERROR] npm not found. Install Node.js first.
            echo   Supabase: ERROR - npm not found >> "%LOGFILE%"
            goto :eof
        )
        call npm install -g supabase >> "%WINGETLOG%" 2>&1
    )
) else (
    echo   Supabase CLI already installed.
)

REM Verify version only if command is available
call :WhereCheck supabase
if not errorlevel 1 (
    call supabase --version >> "%LOGFILE%" 2>&1
    echo   Supabase: OK >> "%LOGFILE%"
) else (
    echo   [WARNING] Supabase not found in PATH after installation.
    echo   [WARNING] Close and reopen the terminal to use.
    echo   Supabase: installed, requires new terminal >> "%LOGFILE%"
)
goto :eof

REM ============================================================
REM :AndroidSDK
REM ============================================================
:AndroidSDK
echo Checking Android SDK (cmdline-tools)...
call :WhereCheck sdkmanager
if not errorlevel 1 (
    echo   [OK] Android SDK cmdline-tools already available.
    call sdkmanager --version >> "%LOGFILE%" 2>&1
    echo   Android SDK: already installed >> "%LOGFILE%"
    goto :eof
)
call :Pkg Google.Android.CommandLineTools AndroidSDK
echo   [INFO] ANDROID_HOME and PATH variables will be configured automatically.
echo   Android SDK: verify ANDROID_HOME >> "%LOGFILE%"
goto :eof

REM ============================================================
REM :UpdateDev
REM ============================================================
:UpdateDev
echo.
echo === Updating all components ===
call :Pkg Git.Git Git
call :Pkg OpenJS.NodeJS NodeJS
call :Python
call :Java
call :Flutter
call :Supabase
goto :eof

REM ============================================================
REM :ConfigurePaths
REM ============================================================
:ConfigurePaths
echo Configuring environment variables and system PATH...

powershell -NoProfile -ExecutionPolicy Bypass -Command "$sdkPaths = @(Join-Path $env:LOCALAPPDATA 'Android\Sdk', 'C:\Android\android-sdk', Join-Path $env:ProgramFiles 'Android\Android SDK', Join-Path $env:LOCALAPPDATA 'Programs\Android\Android SDK'); $sdkDir = $sdkPaths | Where-Object { Test-Path $_ } | Select-Object -First 1; if ($sdkDir) { [Environment]::SetEnvironmentVariable('ANDROID_HOME', $sdkDir, 'User'); $env:ANDROID_HOME = $sdkDir; $pathsToAdd = @((Join-Path $sdkDir 'cmdline-tools\latest\bin'), (Join-Path $sdkDir 'cmdline-tools\bin'), (Join-Path $sdkDir 'platform-tools'), (Join-Path $sdkDir 'emulator')); foreach ($p in $pathsToAdd) { if (Test-Path $p) { $userPath = [Environment]::GetEnvironmentVariable('PATH', 'User'); if ($userPath -split ';' -notcontains $p) { [Environment]::SetEnvironmentVariable('PATH', $userPath + ';' + $p, 'User'); Write-Host ('  Added to PATH: ' + $p) } } } }; $flutterPaths = @(Join-Path $env:LOCALAPPDATA 'Programs\flutter\bin', 'C:\flutter\bin', 'C:\src\flutter\bin', Join-Path $env:USERPROFILE 'flutter\bin'); $flutterBin = $flutterPaths | Where-Object { Test-Path $_ } | Select-Object -First 1; if ($flutterBin) { $userPath = [Environment]::GetEnvironmentVariable('PATH', 'User'); if ($userPath -split ';' -notcontains $flutterBin) { [Environment]::SetEnvironmentVariable('PATH', $userPath + ';' + $flutterBin, 'User'); Write-Host ('  Added to PATH: ' + $flutterBin) } }; $javaPaths = @(Join-Path $env:ProgramFiles 'Eclipse Adoptium', Join-Path $env:ProgramFiles 'Eclipse Foundation'); $javaDir = $null; foreach ($jp in $javaPaths) { if (Test-Path $jp) { $jdkDir = Get-ChildItem $jp -Filter 'jdk-*' | Select-Object -First 1; if ($jdkDir) { $javaDir = $jdkDir.FullName; break } } }; if ($javaDir) { [Environment]::SetEnvironmentVariable('JAVA_HOME', $javaDir, 'User'); $env:JAVA_HOME = $javaDir; $javaBin = Join-Path $javaDir 'bin'; $userPath = [Environment]::GetEnvironmentVariable('PATH', 'User'); if ($userPath -split ';' -notcontains $javaBin) { [Environment]::SetEnvironmentVariable('PATH', $userPath + ';' + $javaBin, 'User'); Write-Host ('  Added to PATH: ' + $javaBin) } }"
goto :eof

REM ============================================================
REM :Summary
REM ============================================================
:Summary
echo.
echo ============================================
echo ENVIRONMENT SUMMARY
echo ============================================
echo ===== SUMMARY ===== >> "%LOGFILE%"

for %%C in (git node python java flutter supabase sdkmanager) do (
    call :WhereCheck %%C
    if not errorlevel 1 (
        echo   %%C: found
        call :WhereLog %%C
    ) else (
        echo   %%C: not found
    )
)

echo --- Versions --- >> "%LOGFILE%"

git --version >> "%LOGFILE%" 2>&1
node --version >> "%LOGFILE%" 2>&1
python --version >> "%LOGFILE%" 2>&1
java -version >> "%LOGFILE%" 2>&1
call flutter --version >> "%LOGFILE%" 2>&1
call supabase --version >> "%LOGFILE%" 2>&1

:SummaryEnd
REM Clear temp file
if exist "%TMPOUT%" del "%TMPOUT%"
goto :eof
