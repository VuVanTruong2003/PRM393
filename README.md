# project_prm393_nhom6

Personal Finance (Flutter) – Android/Web/Windows.

## Getting Started

### 1) Cài dependencies

Trên Windows, Flutter plugins cần quyền tạo **symlink**.

- Bật **Developer Mode**: Settings → Privacy & security → For developers → Developer Mode → On  
  (hoặc chạy lệnh `start ms-settings:developers`)
- Sau đó chạy:

```bash
flutter pub get
```

### 2) Chạy app (demo local)

```bash
flutter run -d windows
```

Mặc định app chạy **Demo (local)**: dữ liệu lưu cục bộ bằng Hive.

### 3) (Tuỳ chọn) Bật Firebase (sync)

MVP hiện có nút chuyển qua Firebase, nhưng bạn cần cấu hình trước:

- Tạo Firebase project
- Thay toàn bộ `REPLACE_ME` trong `lib/firebase_options.dart` bằng thông số thật (hoặc dùng FlutterFire CLI để generate)

Khi chưa cấu hình, app vẫn chạy demo local bình thường.

## Tính năng MVP hiện có

- Auth: Demo (khách) hoặc Firebase (email/password)
- Ví (Accounts): thêm/sửa/xoá
- Danh mục (Categories): thêm/sửa/xoá (thu/chi)
- Giao dịch (Transactions): thêm/sửa/xoá, chọn ví + danh mục + ngày + ghi chú
- Dashboard: tổng thu/chi/chênh lệch + biểu đồ chi theo danh mục

## Tài liệu Flutter

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
