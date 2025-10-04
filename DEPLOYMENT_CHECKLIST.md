# 📦 Deployment Checklist

File này đảm bảo dự án của bạn sẵn sàng để push lên Git và người khác clone về chạy ngay.

## ✅ Pre-Push Checklist (Trước khi push lên Git)

### 1. Kiểm tra các file đã được fix

- [x] `mobile_app_new/android/app/build.gradle.kts` - Có plugins block và core library desugaring
- [x] `mobile_app_new/pubspec.yaml` - Có tất cả dependencies
- [x] `.gitignore` - Ignore Flutter build files và node_modules
- [x] `database/docker-compose.yml` - Config PostgreSQL + EMQX

### 2. Xóa sensitive data

```bash
# Xóa local.properties nếu có
rm mobile_app_new/android/local.properties

# Xóa build folders (Git sẽ ignore)
flutter clean
rm -rf mobile_app_new/build
rm -rf mobile_app_new/android/.gradle
```

### 3. Test build từ scratch

```bash
# Test Flutter build
cd mobile_app_new
flutter clean
flutter pub get
flutter build apk --debug

# Test Web build
cd ../web-app
rm -rf node_modules
npm install
npm run build

# Test Backend build
cd ../backend
mvn clean install
```

### 4. Cập nhật documentation

- [x] README.md - Hướng dẫn tổng quan
- [x] QUICK_START.md - Hướng dẫn nhanh 5 phút
- [x] FIXED_ISSUES.md - Danh sách lỗi đã fix
- [x] CONFIG_TEMPLATE.md - Template cấu hình IP

### 5. Commit với message rõ ràng

```bash
git add .
git commit -m "✅ Fix: Flutter Gradle config + Core library desugaring

- Add plugins block to build.gradle.kts
- Enable core library desugaring for flutter_local_notifications
- Update .gitignore for Flutter build files
- Add comprehensive documentation (QUICK_START, FIXED_ISSUES, CONFIG_TEMPLATE)
"
```

---

## 📥 Post-Clone Checklist (Sau khi người khác clone)

### Người dùng mới sẽ làm gì:

#### Bước 1: Clone repo

```bash
git clone <repository-url>
cd 3_01
```

#### Bước 2: Đọc documentation

- Đọc `README.md` để hiểu tổng quan
- Đọc `QUICK_START.md` để bắt đầu
- Đọc `CONFIG_TEMPLATE.md` để biết cách cấu hình IP

#### Bước 3: Install dependencies

**Backend:**

```bash
cd backend
mvn clean install
```

**Web App:**

```bash
cd web-app
npm install
```

**Mobile App:**

```bash
cd mobile_app_new
flutter pub get
```

#### Bước 4: Configure IP (CHỈ 3 FILES)

1. `esp32-firmware/esp32_led_control/esp32_led_control.ino`
2. `web-app/src/services/api.js`
3. `mobile_app_new/lib/services/api_service.dart`

#### Bước 5: Start services

```bash
# Terminal 1: Docker
cd database && docker-compose up -d

# Terminal 2: Backend
cd backend && mvn spring-boot:run

# Terminal 3: Web App
cd web-app && npm start

# Terminal 4: Mobile App
cd mobile_app_new && flutter run
```

---

## 🎯 Đảm bảo các file KHÔNG bị push lên Git

Các file sau sẽ bị ignore (đã config trong `.gitignore`):

### Flutter

- `mobile_app_new/.dart_tool/`
- `mobile_app_new/build/`
- `mobile_app_new/.gradle/`
- `mobile_app_new/android/.gradle/`
- `mobile_app_new/android/local.properties`

### Node.js

- `web-app/node_modules/`
- `web-app/build/`

### Java

- `backend/target/`
- `backend/.mvn/`

### Database

- `database/*.sql.backup`

---

## 🚀 Các file PHẢI push lên Git

### Flutter Mobile App

✅ `mobile_app_new/android/app/build.gradle.kts` - **QUAN TRỌNG!**
✅ `mobile_app_new/pubspec.yaml`
✅ `mobile_app_new/lib/` - Source code
✅ `mobile_app_new/android/gradle/wrapper/`
✅ `mobile_app_new/android/settings.gradle.kts`
✅ `mobile_app_new/android/build.gradle.kts`

### Documentation

✅ `README.md`
✅ `QUICK_START.md`
✅ `FIXED_ISSUES.md`
✅ `CONFIG_TEMPLATE.md`
✅ `.gitignore`

### Docker

✅ `database/docker-compose.yml`
✅ `database/init.sql`

---

## 🔍 Verify trước khi push

### Check 1: Build.gradle.kts có plugins block?

```bash
head -n 10 mobile_app_new/android/app/build.gradle.kts
```

Phải thấy:

```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}
```

### Check 2: Core library desugaring enabled?

```bash
grep -n "isCoreLibraryDesugaringEnabled" mobile_app_new/android/app/build.gradle.kts
```

Phải thấy: `isCoreLibraryDesugaringEnabled = true`

### Check 3: Dependencies có desugaring?

```bash
grep -n "coreLibraryDesugaring" mobile_app_new/android/app/build.gradle.kts
```

Phải thấy: `coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")`

### Check 4: .gitignore có ignore Flutter build files?

```bash
grep "mobile_app_new" .gitignore
```

Phải thấy nhiều dòng ignore Flutter files

---

## ✅ Kết luận

**Dự án sẵn sàng push lên Git khi:**

- [x] Tất cả Gradle config đã fix
- [x] .gitignore đã update đầy đủ
- [x] Documentation đầy đủ và rõ ràng
- [x] Test build thành công trên máy local
- [x] Không có sensitive data (passwords, keys)

**Người dùng mới sẽ chạy được ngay khi:**

- [x] Clone repo
- [x] Install dependencies (mvn, npm, flutter)
- [x] Cấu hình IP (chỉ 3 files)
- [x] Start services theo QUICK_START.md

---

## 🎉 Ready to Deploy!

Dự án của bạn đã được optimize để:

- ✅ Chạy trơn tru trên máy khác
- ✅ Không cần config phức tạp
- ✅ Tất cả lỗi đã được fix sẵn
- ✅ Documentation đầy đủ và dễ hiểu

**Thời gian setup cho người mới:** ~5-10 phút

---

**Last Updated:** October 2025 | **Status:** Production Ready ✅
