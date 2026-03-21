@echo off
setlocal

:: ---------------------------------------------------------------------------
:: deploy.bat  — bump patch version, commit + push addon, build repo, commit + push
:: Usage:  deploy.bat "your commit message"
:: ---------------------------------------------------------------------------

if "%~1"=="" (
    echo Usage: deploy.bat "commit message"
    exit /b 1
)
set "MSG=%~1"

set "ADDON_DIR=C:\Users\surfy\AppData\Roaming\Kodi\addons\plugin.video.rugbystreams"
set "SNIPER_DIR=C:\Users\surfy\Desktop\sniper-repo"
set "ADDON_XML=%ADDON_DIR%\addon.xml"
set "PYTHON=C:\Users\surfy\AppData\Local\Programs\Python\Python313\python.exe"

:: ---------------------------------------------------------------------------
:: 1. Bump patch version in addon.xml
:: ---------------------------------------------------------------------------
echo [deploy] Bumping patch version in addon.xml...
for /f "delims=" %%v in ('""%PYTHON%" "%ADDON_DIR%\bump_version.py" "%ADDON_XML%""') do set "VER=%%v"
if "%VER%"=="" (
    echo [deploy] ERROR: version bump failed
    exit /b 1
)
echo [deploy] New version: %VER%

:: ---------------------------------------------------------------------------
:: 2. Commit and push the addon repo
:: ---------------------------------------------------------------------------
echo [deploy] Committing addon repo...
cd /d "%ADDON_DIR%"
git add -A
git commit -m "%MSG% (v%VER%)"
if errorlevel 1 (
    echo [deploy] ERROR: git commit failed for addon repo
    exit /b 1
)
git push
if errorlevel 1 (
    echo [deploy] ERROR: git push failed for addon repo
    exit /b 1
)

:: ---------------------------------------------------------------------------
:: 3. Run build.py in sniper-repo
:: ---------------------------------------------------------------------------
echo [deploy] Running build.py in sniper-repo...
cd /d "%SNIPER_DIR%"
"%PYTHON%" build.py
if errorlevel 1 (
    echo [deploy] ERROR: build.py failed
    exit /b 1
)

:: ---------------------------------------------------------------------------
:: 4. Commit and push the sniper-repo
:: ---------------------------------------------------------------------------
echo [deploy] Committing sniper-repo...
git add -A
git commit -m "%MSG% (v%VER%)"
if errorlevel 1 (
    echo [deploy] ERROR: git commit failed for sniper-repo
    exit /b 1
)
git push
if errorlevel 1 (
    echo [deploy] ERROR: git push failed for sniper-repo
    exit /b 1
)

echo [deploy] Done. Addon v%VER% deployed.
endlocal
