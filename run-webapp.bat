@echo off
REM Setup and Run Web App - ReactJS

echo ==========================================
echo IoT LED Control Web App - Setup and Run
echo ==========================================
echo.

cd web-app

echo Step 1: Installing dependencies...
if not exist node_modules (
    call npm install
    if %ERRORLEVEL% NEQ 0 (
        echo npm install failed! Please check Node.js installation.
        pause
        exit /b 1
    )
)

echo.
echo Step 2: Starting React development server...
echo Web app will run on http://localhost:3000
echo.

call npm start

pause
