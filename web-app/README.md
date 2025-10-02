# IoT LED Control - Web Application (ReactJS)

## Yêu cầu

- Node.js 16+ và npm
- Backend API đang chạy trên `http://localhost:8080`

## Cài đặt

```bash
cd web-app
npm install
```

## Chạy ứng dụng

```bash
npm start
```

Ứng dụng sẽ chạy tại: `http://localhost:3000`

## Build cho production

```bash
npm run build
```

## Chức năng

### 1. Xem danh sách thiết bị

- Hiển thị tất cả thiết bị đã đăng ký
- Thông tin: Tên, Device ID, Trạng thái (ONLINE/OFFLINE/ON/OFF)
- Tự động refresh mỗi 5 giây

### 2. Đăng ký thiết bị mới

- Form đăng ký với các thông tin:
  - Device ID (bắt buộc)
  - Tên thiết bị (bắt buộc)
  - Loại thiết bị
  - Mô tả
  - MQTT Topics (control và status)

### 3. Điều khiển LED

- Nút BẬT LED (màu xanh lá)
- Nút TẮT LED (màu đỏ)
- Hiển thị trạng thái thiết bị real-time
- Loading state khi đang gửi lệnh

### 4. Lịch sử điều khiển

- Xem 5 lệnh gần nhất
- Thông tin: Lệnh, Nguồn (WEB/MOBILE), Trạng thái, Thời gian

## Cấu trúc thư mục

```
web-app/
├── public/
│   └── index.html
├── src/
│   ├── components/
│   │   ├── DeviceList.js          # Danh sách thiết bị
│   │   ├── DeviceList.css
│   │   ├── DeviceControl.js       # Điều khiển thiết bị
│   │   ├── DeviceControl.css
│   │   ├── DeviceRegistration.js  # Form đăng ký
│   │   └── DeviceRegistration.css
│   ├── services/
│   │   └── api.js                 # API service
│   ├── App.js                     # Main component
│   ├── App.css
│   ├── index.js
│   └── index.css
├── package.json
└── README.md
```

## API Endpoints được sử dụng

- `GET /api/devices` - Lấy danh sách thiết bị
- `POST /api/devices` - Đăng ký thiết bị mới
- `POST /api/devices/{id}/control` - Điều khiển thiết bị
- `GET /api/devices/{id}/history` - Lịch sử điều khiển

## Troubleshooting

### Lỗi CORS

Đảm bảo backend đã cấu hình CORS cho origin `http://localhost:3000`

### Không kết nối được API

- Kiểm tra backend đang chạy: `http://localhost:8080/api/devices/health`
- Xem Console trong browser để check lỗi

### Port 3000 đã được sử dụng

Thay đổi port trong file `.env`:

```
PORT=3001
```
