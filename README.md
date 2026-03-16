# project_prm393_nhom6

Ứng dụng quản lý tài chính cá nhân viết bằng **Flutter**, hỗ trợ nhiều nền tảng: **Android / Web / Windows**.

## Yêu cầu

- **Flutter SDK** đã được cài đặt và cấu hình PATH
- Đã cài đầy đủ **Android SDK** (nếu build Android) hoặc **Chrome** (nếu chạy Web)
- Trên Windows, Flutter plugins cần quyền tạo **symlink**

## 1) Cài dependencies

Trên Windows, bật **Developer Mode** để Flutter có thể tạo symlink:

- Mở **Settings → Privacy & security → For developers → Developer Mode → On**  
  (hoặc chạy lệnh: `start ms-settings:developers` trong Run / PowerShell)
- Sau đó, tại thư mục project, chạy:

```bash
flutter pub get
```

## 2) Chạy ứng dụng

### Chạy trên Windows

```bash
flutter run -d windows
```

### Chạy trên Android (giả lập / thiết bị thật)

```bash
flutter run -d android
```

### Chạy trên Web

```bash
flutter run -d chrome
```

Mặc định app chạy ở chế độ **Demo (local)**: dữ liệu được lưu cục bộ bằng **Hive**.

## 3) (Tuỳ chọn) Cấu hình Firebase (đồng bộ dữ liệu)

Ứng dụng hỗ trợ đồng bộ dữ liệu qua **Firebase**. Để bật Firebase:

1. Tạo **Firebase project** trên console Firebase
2. Cấu hình các nền tảng cần dùng (Android / Web / Windows nếu có)
3. Thay toàn bộ `REPLACE_ME` trong file `lib/firebase_options.dart` bằng thông số thật  
   (hoặc dùng **FlutterFire CLI** để generate lại file này)

Khi chưa cấu hình Firebase, ứng dụng vẫn hoạt động bình thường ở chế độ demo local.

## Tính năng MVP hiện có

- **Auth**: đăng nhập kiểu Demo (khách) hoặc **Firebase (email/password)**
- **Ví (Accounts)**: thêm / sửa / xoá
- **Danh mục (Categories)**: thêm / sửa / xoá (thu / chi)
- **Giao dịch (Transactions)**: thêm / sửa / xoá, chọn ví + danh mục + ngày + ghi chú
- **Dashboard**: tổng thu / chi / chênh lệch + biểu đồ chi theo danh mục

## Tài liệu tham khảo Flutter

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)
- [Online Flutter documentation](https://docs.flutter.dev/) – tổng quan, tutorials, samples, hướng dẫn mobile & web, API reference.
