# Ngân hàng câu hỏi trắc nghiệm

## Giới thiệu
Chương trình Bash Script giúp quản lý ngân hàng câu hỏi trắc nghiệm, cho phép:
- Thêm câu hỏi mới.
- Xuất đề thi ngẫu nhiên.
- Tìm câu hỏi mới nhất.
- Lưu trữ câu hỏi và đáp án trong file.

## Cài đặt
Chương trình yêu cầu môi trường Linux có sẵn Bash.

### Trên Linux
1. Clone repository:
   ```bash
   git clone https://github.com/HaoPham2703/nganhangcauhoitracnghiem.git
   cd nganhangcauhoitracnghiem
   ```
2. Cấp quyền chạy script:
   ```bash
   chmod +x script.sh
   ```
3. Chạy chương trình:
   ```bash
   ./script.sh
   ```

### Trên Windows
Windows không hỗ trợ Bash natively, nhưng bạn có thể chạy thông qua **Git Bash** hoặc **WSL (Windows Subsystem for Linux)**:

#### Cách 1: Sử dụng Git Bash
1. Tải và cài đặt [Git for Windows](https://git-scm.com/downloads).
2. Mở **Git Bash** và chạy lệnh:
   ```bash
   git clone https://github.com/HaoPham2703/nganhangcauhoitracnghiem.git
   cd nganhangcauhoitracnghiem
   chmod +x script.sh
   ./script.sh
   ```

#### Cách 2: Sử dụng WSL
1. Cài đặt WSL theo hướng dẫn tại [Microsoft](https://learn.microsoft.com/en-us/windows/wsl/install).
2. Mở **WSL Terminal** và chạy các lệnh như trên Linux.

## Hướng dẫn sử dụng
Chạy script và chọn chức năng trong menu:

- **1. Thêm câu hỏi**: Nhập câu hỏi và đáp án, hệ thống sẽ tự động gán STT.
- **2. Xuất đề thi**: Nhập số lượng câu hỏi muốn làm, hệ thống sẽ hiển thị ngẫu nhiên.
- **3. Tìm câu hỏi mới nhất**: Hiển thị STT câu hỏi lớn nhất.
- **4. Thoát**: Kết thúc chương trình.

## Cấu trúc file
- `script.sh` - Mã nguồn Bash Script chính.
- `Cauhoi.txt` - Lưu danh sách câu hỏi.
- `Dapan.txt` - Lưu đáp án theo định dạng: `STT-Đáp án` (vd: `502-b`).

## Góp ý
Máo lấy PR hoặc issue tại [GitHub Repo](https://github.com/HaoPham2703/nganhangcauhoitracnghiem).


