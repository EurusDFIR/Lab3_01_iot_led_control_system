@echo off
REM Setup PostgreSQL Database for IoT LED Control System

echo ==========================================
echo PostgreSQL Database Setup
echo ==========================================
echo.

REM Thay đổi tên container nếu khác
set CONTAINER_NAME=postgres

echo Step 1: Creating new database 'iot_led_control'...
docker exec -it %CONTAINER_NAME% psql -U iotuser -d iotdb -c "CREATE DATABASE iot_led_control;"
echo.

echo Step 2: Initializing tables and data...
docker exec -i %CONTAINER_NAME% psql -U iotuser -d iot_led_control < init.sql
echo.

echo Step 3: Verifying database setup...
docker exec -it %CONTAINER_NAME% psql -U iotuser -d iot_led_control -c "\dt"
echo.

echo ==========================================
echo Database setup completed!
echo ==========================================
echo.
echo Database: iot_led_control
echo User: iotuser
echo Host: localhost
echo Port: 5432
echo.

pause
