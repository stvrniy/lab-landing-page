@echo off
REM deploy.bat - Windows deployment script

echo ==========================================
echo   Landing Page Deployment Script (Windows)
echo ==========================================

set PROJECT_DIR=%~dp0
set DEPLOY_DIR=C:\inetpub\wwwroot\lab-landing-page

REM Create backup
echo [INFO] Creating backup...
mkdir %BACKUP_DIR% 2>nul
if exist "%DEPLOY_DIR%" (
    xcopy /E /I /Y "%DEPLOY_DIR%" "%BACKUP_DIR%_%%date:~-4,4%%date:~-7,2%%date:~-10,2%_%time:~0,2%%time:~3,2%" >nul
    echo [INFO] Backup created
)

REM Deploy (copy files)
echo [INFO] Deploying...
mkdir %DEPLOY_DIR% 2>nul
xcopy /E /I /Y "%PROJECT_DIR%*" "%DEPLOY_DIR%" >nul
echo [INFO] Deployed to %DEPLOY_DIR%

REM Test
echo [INFO] Testing deployment...
curl -I http://localhost >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Deployment failed!
    exit /b 1
) else (
    echo [INFO] Deployment successful!
)

echo.
echo Done!
pause
