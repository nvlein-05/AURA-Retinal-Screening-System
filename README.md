# AURA - Hệ Thống Sàng Lọc Sức Khỏe Mạch Máu Võng Mạc

**(Comprehensive AI Understanding Retinal Analysis)**

## 📖 Giới thiệu

**AURA** là hệ thống hỗ trợ quyết định lâm sàng (Clinical Decision Support - CDS) sử dụng trí tuệ nhân tạo để phân tích hình ảnh võng mạc. Hệ thống giúp phát hiện sớm các nguy cơ sức khỏe toàn thân như cao huyết áp, tiểu đường và đột quỵ thông qua việc phân tích hình thái mạch máu võng mạc.

Mục tiêu của AURA là cung cấp công cụ sàng lọc nhanh chóng, chính xác, không xâm lấn và có thể triển khai rộng rãi từ các phòng khám cộng đồng đến bệnh viện lớn.

## 🚀 Tính năng Chính (Functional Requirements)

### 1. Dành cho Người dùng (Patients)

- **[FR-1]** Đăng ký/Đăng nhập (Email, Google, MXH).
- **[FR-2]** Tải lên ảnh võng mạc (Fundus/OCT) để phân tích.
- **[FR-3]** Xem kết quả chẩn đoán AI và mức độ rủi ro.
- **[FR-4]** Xem ảnh trực quan hóa với các vùng mạch máu bất thường được đánh dấu.
- **[FR-5] - [FR-8]** Nhận khuyến nghị sức khỏe, quản lý hồ sơ, lịch sử khám bệnh.
- **[FR-11]** Mua gói dịch vụ phân tích.

### 2. Dành cho Bác sĩ (Doctors)

- **[FR-13] - [FR-14]** Quản lý hồ sơ bệnh nhân và xem kết quả phân tích từ AI.
- **[FR-15] - [FR-16]** Xác thực kết quả AI, thêm ghi chú y tế và chẩn đoán.
- **[FR-20]** Trao đổi với bệnh nhân qua chat.
- **[FR-19]** Cung cấp phản hồi để cải thiện độ chính xác của AI.

### 3. Dành cho Phòng khám (Clinics)

- **[FR-22] - [FR-23]** Quản lý tài khoản bác sĩ và bệnh nhân thuộc tổ chức.
- **[FR-24]** Tải lên hàng loạt ảnh võng mạc (Bulk upload).
- **[FR-25] - [FR-27]** Theo dõi báo cáo tổng hợp, thống kê số lượng ảnh và mức độ rủi ro.

### 4. Quản trị viên (Admin)

- **[FR-31] - [FR-32]** Quản lý người dùng, bác sĩ, phòng khám và phân quyền.
- **[FR-33]** Cấu hình tham số AI và chính sách huấn luyện lại.
- **[FR-35] - [FR-36]** Dashboard thống kê toàn hệ thống (doanh thu, hiệu suất AI).

## 🛠 Công Nghệ Sử Dụng

### Client-side

- **Web Client:** React + TypeScript
- **Mobile (Optional):** Flutter

### Server-side

- **Backend:** .NET Core
- **AI Core:** Python (TensorFlow/PyTorch)
- **Infrastructure:** Docker, VPS
- **Database:** PostgreSQL, MongoDB
- **Storage/Auth:** Supabase, Cloudinary

## ⚙️ Yêu cầu Hệ thống (Non-functional Requirements)

- **Hiệu năng:** Phân tích AI < 20s/ảnh. Dashboard load < 3s.
- **Bảo mật:** Tuân thủ chuẩn bảo vệ dữ liệu y tế (tương tự HIPAA), mã hóa AES-256.
- **Khả năng mở rộng:** Microservices architecture, hỗ trợ scale ngang.
- **Độ sẵn sàng:** Uptime ≥ 99%.

## 📦 Cấu trúc Dự án (Dự kiến)

```bash
AURA-Retinal-Screening-System/
├── ai-core/                # Python Service cho xử lý ảnh AI
├── backend/                # .NET Web API
├── frontend/               # React + TypeScript App
├── docs/                   # Tài liệu phân tích thiết kế
└── docker-compose.yml      # Cấu hình deploy
```

## 🔧 Hướng dẫn Cài đặt & Chạy (Local Development)

### 1. Clone dự án

```bash
git clone https://github.com/username/AURA-Retinal-Screening-System.git
cd AURA-Retinal-Screening-System
```

### 2. Cài đặt AI Service

```bash
cd ai-core
pip install -r requirements.txt
python main.py
```

### 3. Cài đặt Backend

Cần cài đặt .NET SDK.

```bash
cd backend
dotnet restore
dotnet run
```

### 4. Cài đặt Frontend

```bash
cd frontend
npm install
npm start
```

## 📅 Kế hoạch Phát triển (Tasks)

- [ ] **Task 1:** Thiết kế UI/UX cho Web Application.
- [ ] **Task 2:** Phát triển hệ thống API (Backend).
- [ ] **Task 3:** Phát triển Web Application (Frontend).
- [ ] **Task 4:** Xây dựng, Triển khai và Kiểm thử (Build, Deploy, Test).
- [ ] **Task 5:** Hoàn thiện tài liệu (Phân tích thiết kế, HDSD, Test Plan).

## 📝 Tài liệu

Dự án yêu cầu áp dụng quy trình phát triển phần mềm và UML 2.0. Tài liệu bao gồm:

- User Requirements & SRS
- Architecture & Detail Design
- System Implementation & Testing
- User & Installation Guide

## 👥 Tác giả

Nhóm thực hiện đồ án **SP26SE025**.

---

_Dự án này là một phần của chương trình đào tạo Kỹ thuật phần mềm._
