@echo off
REM Script tìm IP và hướng dẫn cấu hình

echo ==========================================
echo   TIM IP VA CAU HINH HE THONG
echo ==========================================
echo.

echo Dang tim IP cua may tinh...
echo.

REM Lấy IPv4 address
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /c:"IPv4 Address"') do (
    set IP=%%a
    goto :found
)

:found
REM Loại bỏ khoảng trắng
set IP=%IP: =%

if "%IP%"=="" (
    echo KHONG TIM THAY IP!
    echo.
    echo Hay chay lenh sau de xem thong tin mang:
    echo    ipconfig
    echo.
    echo Tim dong "IPv4 Address" trong phan:
    echo    - Wireless LAN adapter Wi-Fi (neu dung WiFi)
    echo    - Ethernet adapter (neu dung day mang)
    echo.
    pause
    exit /b 1
)

echo ==========================================
echo IP CUA MAY BAN LA: %IP%
echo ==========================================
echo.

echo HUONG DAN CAU HINH:
echo.
echo 1. ESP32 FIRMWARE (esp32-firmware/esp32_led_control.ino)
echo    Line 26: const char *mqtt_server = "%IP%";
echo.
echo 2. MOBILE APP (mobile-app/lib/services/api_service.dart)
echo    Line 9: static const String baseUrl = 'http://%IP%:8080/api';
echo.
echo 3. BACKEND (backend/src/main/resources/application.properties)
echo    Line 20: mqtt.broker.url=tcp://localhost:1883
echo    ^(KHONG CAN DOI neu EMQX chay cung may^)
echo.
echo ==========================================
echo.

echo Ban co muon mo file IP_CONFIGURATION_GUIDE.md de xem huong dan chi tiet? (Y/N)
set /p choice=Nhap lua chon: 

if /i "%choice%"=="Y" (
    start notepad "IP_CONFIGURATION_GUIDE.md"
)

echo.
echo ==========================================
echo CHECKLIST:
echo ==========================================
echo.
echo [ ] Da cap nhat WiFi SSID va Password trong ESP32
echo [ ] Da cap nhat MQTT Server IP = %IP% trong ESP32
echo [ ] Da cap nhat API URL = http://%IP%:8080/api trong Mobile
echo [ ] PostgreSQL container dang chay (docker ps)
echo [ ] EMQX container dang chay (docker ps)
echo [ ] Tat ca thiet bi cung mang WiFi
echo.

pause
