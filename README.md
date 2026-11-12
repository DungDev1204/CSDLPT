# Cơ sở dữ liệu phân tán — Nhóm 8

Dự án quản lý hàng không thông minh, gồm cơ sở dữ liệu SQL Server, dữ liệu mẫu và báo cáo môn Cơ sở dữ liệu phân tán.

## Nội dung

- [`CSDLPT/output/`](CSDLPT/output/): báo cáo Word/PDF, phân công công việc và SQL chạy hoàn chỉnh.
- [`CSDLPT/tmp/`](CSDLPT/tmp/): mã nguồn Python/PowerShell dựng báo cáo, sinh SQL và các script kiểm tra.
- [`CSDLPT/tmp/source/`](CSDLPT/tmp/source/): sơ đồ và tài liệu nguồn dùng cho báo cáo.

## Chạy cơ sở dữ liệu

1. Kết nối SQL Server 2022 bằng SQL Server Management Studio (SSMS), với tài khoản có quyền tạo database và các đối tượng.
2. Mở [`Truy_van_xay_dung_CSDLPT_Nhom_8.sql`](CSDLPT/output/Truy_van_xay_dung_CSDLPT_Nhom_8.sql).
3. Nhấn **Ctrl+A**, rồi **F5** để chạy toàn bộ trên cùng một connection. Không cần bật SQLCMD Mode.

Bản SQL mô phỏng tám database trên cùng một SQL Server instance và dùng dữ liệu giả lập phục vụ bài nộp. Chi tiết thiết kế và nghiệp vụ nằm trong [báo cáo PDF](CSDLPT/output/Bao_cao_CSDLPT_Nhom_8.pdf).

Runtime Python, cache và ảnh render tạm được bỏ qua qua `.gitignore`.
