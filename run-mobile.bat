@echo off
REM Setup and Run Mobile App - Flutter

echo ==========================================
echo IoT LED Control Mobile App - Setup and Run
echo ==========================================
echo.

cd mobile-app

echo Step 1: Getting Flutter dependencies...
call flutter pub get
if %ERRORLEVEL% NEQ 0 (
    echo flutter pub get failed! Please check Flutter installation.
    pause
    exit /b 1
)

echo.
echo Step 2: Checking connected devices...
call flutter devices

echo.
echo Step 3: Starting Flutter app...
echo Make sure an emulator is running or device is connected!
echo.

call flutter run

pause
