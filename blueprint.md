
# Blueprint: Hanzi Writing Trainer

## 1. Tổng quan

**Mục đích:** Xây dựng một ứng dụng Flutter giúp người dùng học viết ký tự tiếng Hán (Hanzi). Ứng dụng sẽ sử dụng Firebase cho các tính năng backend bao gồm xác thực, cơ sở dữ liệu, lưu trữ và hosting.

**Các tính năng chính:**
- Xác thực người dùng qua Google, Email/Password, và Anonymous.
- Hiển thị các bài học (Units) và các ký tự (Characters) trong mỗi bài.
- Theo dõi tiến độ học tập của người dùng (XP, streak, progress).
- Giao diện người dùng hiện đại, thân thiện và có thể tùy chỉnh theme (Sáng/Tối).
- Màn hình luyện viết tương tác.

## 2. Thiết kế và Kiến trúc

### Cấu trúc thư mục
```
/lib
  /src
    /core
      /routing          # Cấu hình GoRouter
      /theme            # Theme và style
    /features
      /auth
        /screens        # Màn hình đăng nhập, đăng ký
        /services       # Logic xác thực với Firebase Auth
      /home
        /screens        # Màn hình chính, chi tiết bài học
        /widgets        # Widget chuyên cho màn hình home
      /writing
        /screens        # Màn hình luyện viết
        /widgets        # Widget cho canvas, điều khiển
    /models             # Data models (User, Unit, Character)
    /repositories       # Tương tác với Firestore
    /shared_widgets     # Các widget dùng chung
  /main.dart            # Entry point
/blueprint.md           # Tài liệu này
/firestore.rules        # Quy tắc bảo mật Firestore
/storage.rules          # Quy tắc bảo mật Storage
/firebase.json          # Cấu hình Firebase Hosting
```

### Quản lý Trạng thái (State Management)
- **Provider**: Dùng để quản lý trạng thái xác thực (`AuthService`) và theme (`ThemeProvider`) trên toàn ứng dụng.
- **ChangeNotifier**: Các service và provider sẽ dùng `ChangeNotifier` để thông báo cho UI khi có sự thay đổi.

### Điều hướng (Navigation)
- **GoRouter**: Được sử dụng để quản lý điều hướng một cách khai báo, hỗ trợ deep linking và chuyển hướng tự động dựa trên trạng thái đăng nhập.

### Thiết kế (Design)
- **Material 3**: Sử dụng các thành phần và nguyên tắc thiết kế của Material 3.
- **Google Fonts**: Tích hợp font chữ tùy chỉnh để tạo sự nhất quán và thẩm mỹ.
- **Theme Sáng/Tối**: Hỗ trợ cả hai chế độ hiển thị và cho phép người dùng chuyển đổi.

## 3. Kế hoạch triển khai (Hiện tại)

### Giai đoạn 1: Hoàn thành (Nền tảng ứng dụng)
- **[X] Thiết lập môi trường và cấu trúc dự án.**
- **[X] Cấu hình Firebase và kết nối ứng dụng.**
- **[X] Xây dựng lõi ứng dụng (main, theme, router).**
- **[X] Xây dựng luồng xác thực người dùng (Google, Anonymous, Email).**
- **[X] Hiển thị danh sách bài học và chi tiết bài học từ Firestore.**
- **[X] Tạo trang admin đơn giản để nạp dữ liệu ban đầu (seeding).**

### Giai đoạn 2: Tính năng cốt lõi (Đang triển khai)

#### **Bước 1: Cá nhân hóa và Hiển thị thông tin người dùng**
- **Mục tiêu**: Hiển thị thông tin người dùng đã đăng nhập trên màn hình chính để tăng tính cá nhân hóa.
- **Công việc**:
    1.  Tạo widget `UserProfileHeader` trong `lib/src/features/home/widgets/`.
    2.  Widget này sẽ sử dụng `Provider` để lấy thông tin `UserProfile` hiện tại.
    3.  Hiển thị `CircleAvatar` với ảnh đại diện của người dùng (lấy từ `photoURL`). Nếu không có, hiển thị icon mặc định.
    4.  Hiển thị tên (`displayName`) và có thể cả email của người dùng.
    5.  Thêm widget này vào `HomeScreen`.

#### **Bước 2: Xây dựng hệ thống theo dõi tiến độ học tập**
- **Mục tiêu**: Ghi nhận và hiển thị sự tiến bộ của người dùng.
- **Công việc**:
    1.  **Cập nhật Model**: Mở rộng `UserProfile` model để bao gồm `xp` (kinh nghiệm), `streak` (chuỗi ngày học), và `progress` (một map lưu tiến độ cho từng ký tự, ví dụ: `{'characterId': 'completed'}`).
    2.  **Logic cập nhật**: Sau khi người dùng hoàn thành một bài luyện viết (sẽ được xây dựng ở màn hình `WritingScreen`), cập nhật các trường này trong Firestore.
    3.  **Hiển thị tiến độ**:
        -   Hiển thị tổng XP và streak trong `UserProfileHeader`.
        -   Trên `UnitDetailsScreen`, thêm một chỉ báo (ví dụ: `Icon(Icons.check_circle)`) bên cạnh các ký tự đã được hoàn thành.

#### **Bước 3: Hoàn thiện màn hình luyện viết**
- **Mục tiêu**: Tạo một trải nghiệm luyện viết tương tác và hiệu quả.
- **Công việc**:
    1.  **Tạo `WritingScreen`**: Màn hình này sẽ nhận một `HanziCharacter` làm tham số.
    2.  **Sử dụng `flutter_custom_painter`**: Tạo một widget `WritingCanvas` để:
        -   Hiển thị ký tự mẫu (mờ) ở nền.
        -   Cho phép người dùng vẽ lên trên bằng cách chạm và kéo.
        -   Có các nút để xóa và kiểm tra nét vẽ.
    3.  **(Nâng cao) Nhận diện nét vẽ**: So sánh nét vẽ của người dùng với dữ liệu nét vẽ chuẩn của ký tự (cần tìm thư viện hoặc API hỗ trợ).
    4.  **Cập nhật tiến độ**: Khi người dùng viết đúng, gọi `Repository` để cập nhật tiến độ trong `UserProfile`.

#### **Bước 4: Củng cố trải nghiệm đăng nhập**
- **Mục tiêu**: Đảm bảo người dùng nhận được phản hồi rõ ràng khi đăng nhập thất bại, đặc biệt trên các thiết bị thiếu Google Play services.
- **Công việc**:
    1. Tạo lớp `AuthFailure` để chuẩn hóa thông điệp lỗi từ `AuthService`.
    2. Bổ sung xử lý lỗi chi tiết cho đăng nhập Google, email/password và ẩn danh.
    3. Cập nhật `LoginScreen` hiển thị snackbar khi có lỗi và khóa nút khi đang xử lý.
    4. Hiển thị tiến trình tải để người dùng biết ứng dụng đang xử lý yêu cầu.

### Giai đoạn 3: Đánh bóng và Mở rộng (Tương lai)
- **Mục tiêu**: Nâng cao trải nghiệm người dùng và thêm các tính năng bổ sung.
- **Công việc**:
    -   Thêm hoạt ảnh (animations) và hiệu ứng chuyển cảnh.
    -   Cải thiện thiết kế và trợ năng (accessibility).
    -   Xây dựng bảng xếp hạng (leaderboard) người dùng dựa trên XP.
    -   Thêm các cấp độ khó khác nhau cho bài học.
