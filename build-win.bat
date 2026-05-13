@echo off
setlocal
cd /d %~dp0

echo ============================================
echo  StockRadar Windows Build Script
echo ============================================

REM 1. Python 依赖
echo [1/6] Installing Python dependencies...
pip install -r backend\requirements.txt
pip install pyinstaller
if errorlevel 1 ( echo FAILED & exit /b 1 )

REM 2. Playwright Chromium
echo [2/6] Installing Playwright browser...
playwright install chromium
if errorlevel 1 ( echo FAILED & exit /b 1 )

REM 3. 前端构建（输出到 backend\static）
echo [3/6] Building frontend...
cd frontend
call npm install
call npm run build
cd ..
if errorlevel 1 ( echo FAILED & exit /b 1 )

REM 4. PyInstaller 打包后端
echo [4/6] Bundling Python backend with PyInstaller...
cd backend
pyinstaller backend.spec --noconfirm --clean
cd ..
if errorlevel 1 ( echo FAILED & exit /b 1 )

REM 5. 复制 Playwright Chromium 到打包目录
echo [5/6] Copying Playwright browsers...
set BROWSERS_SRC=%LOCALAPPDATA%\ms-playwright
set BROWSERS_DST=backend\dist\stockradar-backend\browsers
if exist "%BROWSERS_SRC%" (
    xcopy /E /I /Y /Q "%BROWSERS_SRC%" "%BROWSERS_DST%"
    echo Copied Playwright browsers.
) else (
    echo WARNING: Playwright browsers not found at %BROWSERS_SRC%
)

REM 6. Electron 打包成 NSIS 安装包
echo [6/6] Packaging Electron app...
cd frontend
call npm run dist:win
cd ..
if errorlevel 1 ( echo FAILED & exit /b 1 )

echo.
echo ============================================
echo  Build complete!
echo  Installer: frontend\dist-electron\StockRadar Setup 0.1.0.exe
echo ============================================
