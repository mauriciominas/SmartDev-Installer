# Script de Sincronização e Push com o Git

Write-Host "==============================================" -ForegroundColor Blue
Write-Host "      SINCRONIZACAO AUTOMATICA DO GIT         " -ForegroundColor Blue
Write-Host "==============================================" -ForegroundColor Blue

# 1. Verificar se o Git está inicializado
if (-not (Test-Path .git)) {
    Write-Host "Inicializando repositorio Git local..." -ForegroundColor Yellow
    git init
    git branch -M main
}

# 2. Verificar se o remote existe
$remote = git remote
if (-not $remote) {
    Write-Host "Nenhum repositorio remoto configurado!" -ForegroundColor Red
    $url = Read-Host "Digite a URL do seu repositorio no GitHub (ex: https://github.com/usuario/repo.git)"
    if ($url) {
        git remote add origin $url
        Write-Host "Remoto 'origin' adicionado com sucesso." -ForegroundColor Green
    } else {
        Write-Error "Cancelado. Nao e possivel dar push sem um repositorio remoto."
        exit 1
    }
}

# 3. Adicionar arquivos e fazer commit
Write-Host "`n[1/2] Adicionando arquivos e realizando commit..." -ForegroundColor Yellow
git add .
$message = Read-Host "Digite a mensagem do commit (Pressione Enter para usar 'update: auto sync')"
if (-not $message) {
    $message = "update: auto sync"
}
git commit -m $message

# 4. Enviar para o GitHub
Write-Host "`n[2/2] Enviando arquivos para o GitHub (push)..." -ForegroundColor Yellow
git push -u origin main

if ($LASTEXITCODE -eq 0) {
    Write-Host "`nSincronizacao concluida com sucesso!" -ForegroundColor Green
} else {
    Write-Error "Falha ao enviar para o GitHub. Verifique suas credenciais de acesso."
}
