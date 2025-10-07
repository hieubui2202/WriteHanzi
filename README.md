# WriteHanzi

Ứng dụng luyện viết chữ Hán phong cách Duolingo, tập trung vào hành động viết.

## Thiết lập

1. Cài đặt Flutter SDK (>=3.7.0) và đảm bảo chạy được `flutter doctor`.
2. Sao chép file cấu hình Firebase (`firebase_options.dart`) đã có sẵn theo dự án của bạn.
3. Chạy `flutter pub get` để cài dependencies.
4. Kết nối Firebase (Auth, Firestore, Storage) theo schema đã mô tả.

## Chạy ứng dụng

```bash
flutter run
```

Ứng dụng hỗ trợ Android, iOS và Web (Chrome). Firestore Persistence đã bật để dùng offline.

## Kiến trúc

- `lib/core`: theme, binding, localization, tiện ích dùng chung.
- `lib/domain`: entity và abstract repository.
- `lib/data`: datasource Firestore + cache cục bộ + repository implementation.
- `lib/presentation`: controller GetX và các màn hình (home, practice 6 bước, review, profile, settings).

## Dữ liệu mẫu

Thư mục `assets/data` chứa JSON mẫu cho units và characters (chữ 水) để demo khi Firestore không truy cập được. Mở rộng bằng cách thêm các file tương tự.

## Tolerance đánh giá nét

Logic so sánh nét nằm trong `lib/core/utils/stroke_matcher.dart` với `tolerance = 0.25`. Điều chỉnh con số này để nới/tight kiểm tra độ khớp khi người dùng vẽ.

## Firebase schema

```
/characters/{hanzi}
/units/{unitId}
/users/{uid}
```

Ứng dụng đọc `/characters` và `/units`, ghi `/users/{uid}` khi hoàn thành bài.
