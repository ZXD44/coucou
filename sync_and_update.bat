@echo off
setlocal
echo ========================================================
echo   Coucou Auto-Sync and Rebuild Tool
echo ========================================================

cd /d "%~dp0"
set PATH=C:\Users\ZirconX\.cargo\bin;%PATH%

echo [1/4] Fetching latest updates from upstream...
git fetch upstream main
if errorlevel 1 (
    echo [ERROR] Failed to fetch upstream. Check your internet connection.
    pause
    exit /b 1
)

echo [2/4] Merging upstream updates into local branch...
git merge upstream/main -m "chore: sync upstream updates"
if errorlevel 1 (
    echo [ERROR] Merge conflict detected. Please resolve conflicts manually.
    pause
    exit /b 1
)

echo [3/4] Rebuilding hook relay...
cd windows\hook
cargo build --release
if errorlevel 1 (
    echo [ERROR] Failed to build hook relay.
    pause
    exit /b 1
)

echo [4/4] Building and installing new Coucou MSI...
cd ..
call npx tauri build --bundles msi
if errorlevel 1 (
    echo [ERROR] Failed to build MSI package.
    pause
    exit /b 1
)

echo.
echo Closing existing Coucou process...
taskkill /f /im coucou.exe >nul 2>&1

echo Installing updated MSI...
for /f "delims=" %%f in ('dir /b /s target\release\bundle\msi\*.msi') do (
    start /wait msiexec /i "%%f" /qn
    goto :installed
)

:installed
echo Launching updated Coucou...
start "" "C:\Program Files\Coucou\coucou.exe"

echo ========================================================
echo   Update completed successfully!
echo ========================================================
pause
