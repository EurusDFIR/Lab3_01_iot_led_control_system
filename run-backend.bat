@echo off
REM Setup and Run Backend - Spring Boot

echo ==========================================
echo IoT LED Control Backend - Setup and Run
echo ==========================================
echo.

cd backend

echo Step 1: Cleaning and building project...
call mvn clean install -DskipTests
if %ERRORLEVEL% NEQ 0 (
    echo Build failed! Please check Maven installation.
    pause
    exit /b 1
)

echo.
echo Step 2: Starting Spring Boot application...
echo Backend will run on http://localhost:8080
echo.

call mvn spring-boot:run

pause
