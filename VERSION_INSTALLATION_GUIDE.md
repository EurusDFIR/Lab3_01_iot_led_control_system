# 🔧 Version Installation Guide

Hướng dẫn cài đặt chính xác các phiên bản công cụ để đảm bảo tương thích 100%.

## 📋 Tại sao cần phiên bản chính xác?

- **Tránh lỗi tương thích**: Các phiên bản khác nhau có thể gây conflict
- **Đảm bảo reproducibility**: Ai cũng có cùng environment
- **Tối ưu performance**: Phiên bản được test kỹ

---

## 📦 Cài đặt các phiên bản chính xác

### ⚠️ **Quan trọng: Cài Chocolatey trước (Windows Package Manager)**

**Chocolatey** là package manager cho Windows, giúp cài đặt phần mềm dễ dàng như apt trên Linux.

#### Cài Chocolatey (Bắt buộc trước khi cài tools khác)

1. Mở **PowerShell as Administrator** (click phải → Run as Administrator)
2. Chạy command sau:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
```

3. Restart PowerShell và verify:

```bash
choco --version
# Should show version number like "2.x.x"
```

**🎯 Chocolatey sẽ giúp cài Java, Node.js, và Git dễ dàng!**

---

### 🎯 **2 Phương pháp cài đặt:**

#### Phương pháp 1: Chocolatey (Khuyến nghị - Nhanh nhất cho Windows)

- Cài Chocolatey trước (xem trên)
- Một lệnh để cài tất cả tools
- **Ưu điểm**: Tự động, ít bước, luôn đúng version

#### Phương pháp 2: Manual Download (Nếu không muốn dùng Chocolatey)

- Download trực tiếp từ website
- **Ưu điểm**: Không cần cài thêm gì
- **Nhược điểm**: Nhiều bước hơn
- **Ưu điểm**: Tự động, ít bước
- **Nhược điểm**: Không phải ai cũng có

#### Phương pháp 2: Manual Download (Universal - Khuyến nghị)

- Download trực tiếp từ website chính thức
- **Ưu điểm**: Hoạt động trên mọi máy, không phụ thuộc package manager
- **Nhược điểm**: Nhiều bước hơn

**💡 Khuyến nghị:** Dùng Phương pháp 1 (Chocolatey) nếu đã cài Chocolatey!

---

## 1. **Java 17** (Cho Backend)

### Phương pháp 1: Chocolatey (Khuyến nghị - Nhanh nhất)

```bash
choco install openjdk17
```

### Phương pháp 2: Manual Download (Nếu không dùng Chocolatey)

#### Eclipse Temurin (Khuyến nghị)

1. Truy cập: https://adoptium.net/temurin/releases/
2. Chọn:
   - **Version**: 17 (LTS)
   - **JVM**: HotSpot
   - **OS**: Windows
   - **Architecture**: x64
3. Download file `.msi` installer
4. Chạy installer và thêm vào PATH

#### Verify

```bash
java -version
# Should show: openjdk version "17.x.x"
```

```bash
java -version
# Should show: openjdk version "17.x.x"
```

---

## 2. **Node.js 16.14.0** (Cho Web App)

### Phương pháp 1: Chocolatey (Khuyến nghị - Nhanh nhất)

```bash
choco install nodejs --version=16.14.0
```

### Phương pháp 2: Manual Download (Nếu không dùng Chocolatey)

#### Official Node.js

1. Truy cập: https://nodejs.org/download/release/v16.14.0/
2. Download file: `node-v16.14.0-x64.msi` (Windows installer)
3. Chạy .msi file và cài đặt (npm sẽ tự động được cài kèm)

#### Verify

```bash
node -v
# Should show: v16.14.0

npm -v
# Should show: 8.x.x
```

---

## 3. **Flutter 3.35.5** (Cho Mobile App)

### Phương pháp 1: Scoop (Alternative package manager)

```bash
# Cài Scoop trước (nếu chưa có)
Set-ExecutionPolicy RemoteSigned -scope CurrentUser
iwr -useb get.scoop.sh | iex

# Cài Flutter
scoop install flutter
# ⚠️ Note: Có thể không phải version 3.35.5 chính xác
```

### Phương pháp 2: Manual Download (Khuyến nghị - Đảm bảo đúng version)

#### Download Link Chính thức

- **Windows**: https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.35.5-stable.zip

#### Installation Steps

1. Download file `flutter_windows_3.35.5-stable.zip`
2. Extract vào thư mục `C:\flutter` (không có dấu cách)
3. Thêm `C:\flutter\bin` vào Environment Variables > Path
4. Restart Command Prompt/PowerShell
5. Chạy `flutter doctor` để check và cài Android SDK

#### Verify

```bash
flutter --version
# Should show: Flutter 3.35.5 • channel stable

flutter doctor
# Should show all green checkmarks
```

### Verify

```bash
flutter --version
# Should show: Flutter 3.35.5 • channel stable

flutter doctor
# Should show all green checkmarks
```

### Android Setup (Required for Flutter)

```bash
# Install Android SDK
flutter doctor --android-licenses

# Or install Android Studio
# Download from: https://developer.android.com/studio
```

---

## 4. **Docker Desktop 4.0+** (Cho Database & MQTT)

### Phương pháp 1: Docker Desktop (Khuyến nghị - Dễ nhất)

#### Download & Install

1. Truy cập: https://www.docker.com/products/docker-desktop
2. Download phiên bản Windows
3. Cài đặt và khởi động Docker Desktop
4. Đăng ký tài khoản Docker Hub (miễn phí) nếu được yêu cầu

#### Enable WSL2 (Khuyến nghị cho Windows)

```bash
# Nếu dùng WSL2 trên Windows
wsl --set-default-version 2
```

### Phương pháp 2: Docker Engine via WSL2 (Advanced)

Nếu không thể cài Docker Desktop:

1. Cài WSL2: https://docs.microsoft.com/en-us/windows/wsl/install
2. Cài Ubuntu trên WSL2
3. Trong Ubuntu terminal:

```bash
sudo apt update
sudo apt install docker.io docker-compose
sudo systemctl start docker
```

#### Verify

```bash
docker --version
# Should show: Docker version 24.x.x

docker-compose --version
# Should show: Docker Compose version 2.x.x

# Test Docker
docker run hello-world
```

---

## 5. **Arduino IDE 2.x** (Cho ESP32)

### Download & Install

1. Truy cập: https://www.arduino.cc/en/software
2. Download **Arduino IDE 2.x** cho Windows
3. Cài đặt và khởi động Arduino IDE

### ESP32 Board Setup

1. Mở Arduino IDE
2. Go to **File > Preferences**
3. Add to **Additional Boards Manager URLs**:
   ```
   https://dl.espressif.com/dl/package_esp32_index.json
   ```
4. Go to **Tools > Board > Boards Manager**
5. Search "esp32" và install **"ESP32 by Espressif Systems"**

### Verify

- **Tools > Board**: Should show ESP32 boards
- **Tools > Port**: Should detect your ESP32 when connected

---

## 🧪 Test Installation

Sau khi cài đặt xong, chạy các lệnh sau để verify:

```bash
# Java
java -version

# Node.js
node -v && npm -v

# Flutter
flutter doctor

# Docker
docker --version && docker-compose --version

# Test Docker
docker run hello-world
```

## 🚨 Troubleshooting

### Flutter không nhận Android SDK

```bash
# Install Android Studio or Android SDK manually
# Then run:
flutter config --android-sdk /path/to/android/sdk
```

### Docker không start được

- **Windows**: Enable Hyper-V hoặc WSL2 trong Windows Features
- Kiểm tra BIOS để enable virtualization
- Restart Docker Desktop

### Node.js version conflict

```bash
# Use Chocolatey để cài Node.js version khác
choco install nodejs --version=16.14.0

# Hoặc dùng nvm-windows
# Download từ: https://github.com/coreybutler/nvm-windows/releases
nvm install 16.14.0
nvm use 16.14.0
```

---

## 📞 Support

Nếu gặp vấn đề với installation:

1. Check error messages carefully
2. Google exact error message
3. Verify PATH environment variables
4. Restart terminal/command prompt
5. Restart computer if necessary
