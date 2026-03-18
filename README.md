# 🔢🧍 MNIST Stream CV App + Pose Detection

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white"/>
  <img src="https://img.shields.io/badge/FastAPI-009688?style=for-the-badge&logo=fastapi&logoColor=white"/>
  <img src="https://img.shields.io/badge/PyTorch-EE4C2C?style=for-the-badge&logo=pytorch&logoColor=white"/>
  <img src="https://img.shields.io/badge/OpenCV-5C3EE8?style=for-the-badge&logo=opencv&logoColor=white"/>
  <img src="https://img.shields.io/badge/MLKit-4285F4?style=for-the-badge&logo=google&logoColor=white"/>
</p>

<p align="center">
  실시간 카메라 기반 손글씨 숫자 인식 + 인체 자세 인식 Computer Vision 앱<br/>
  Flutter × FastAPI × MNIST CNN × ML Kit Pose Detection
</p>

---

## 📌 Overview

Flutter 모바일 앱에서 카메라 입력을 기반으로 두 가지 Computer Vision 기능을 제공합니다.

### 🔢 Digit Recognition (서버 기반)
- 카메라 프레임을 FastAPI 서버로 전송
- MNIST CNN 모델이 손글씨 숫자를 예측
- 결과를 실시간으로 앱에 표시

### 🧍 Pose Detection (온디바이스)
- 카메라 프레임을 실시간으로 처리
- Google ML Kit를 활용해 인체 관절 좌표(Landmarks) 추출
- Skeleton 형태로 시각화

---

## 🧠 System Architecture

### 🔢 Digit Recognition Pipeline

```
📱 Camera (Flutter)
      ↓  Frame Capture
      ↓  PNG Encoding
      ↓  HTTP POST
🖥️  FastAPI Backend
      ↓  OpenCV Preprocessing
      ↓  CNN Inference
      ↓  JSON Response
📱 Flutter UI Display
```

### 🧍 Pose Detection Pipeline

```
📱 Camera (Flutter)
      ↓  Frame Capture
      ↓  ML Kit On-Device Processing
      ↓  Pose Landmarks Extraction
      ↓  CustomPainter (Skeleton)
📱 Flutter UI Overlay
```

---

## 🎬 Demo

### Home Screen
앱 실행 시 두 기능을 선택할 수 있는 메인 화면이 표시됩니다.

```
+──────────────────────+
│   🔢 Digit           │
│      Recognition     │
+──────────────────────+
│   🧍 Pose            │
│      Detection       │
+──────────────────────+
```

### Digit Recognition Screen
```
+──────────────────────+
│   📷 Camera Stream   │
│                      │
+──────────────────────+
│   Predicted Digit    │
│          8           │
+──────────────────────+
```

### Pose Detection Screen
```
+──────────────────────+
│   📷 Camera Stream   │
│   + Skeleton         │
│     Overlay          │
+──────────────────────+
```

---

## 📁 Project Structure

```
digit_stream_cv_app/
│
├── 📂 backend/
│   ├── main.py                  # FastAPI 앱 진입점
│   ├── 📂 models/
│   │   ├── mnist_cnn.pth        # 학습된 모델 가중치
│   │   └── train_cnn.py         # CNN 모델 정의 및 학습
│   ├── 📂 utils/
│   │   └── preprocess.py        # OpenCV 전처리 파이프라인
│   └── 📂 debug_images/         # 전처리 디버그 이미지 저장
│
├── 📂 flutter/
│   └── 📂 app/
│       ├── main.dart
│       ├── 📂 screens/
│       │   ├── home_screen.dart         # 메인 홈 화면
│       │   ├── live_digit_screen.dart   # 숫자 인식 화면
│       │   └── pose_screen.dart         # 자세 인식 화면
│       └── 📂 services/
│           ├── api_service.dart         # HTTP 통신 서비스
│           └── server_config.dart       # 서버 주소 설정
│
└── README.md
```

---

## 🖥️ Backend

**FastAPI** 기반 백엔드 서버입니다.

### API Endpoint

#### `POST /predict`

카메라 프레임을 전송하여 숫자를 예측합니다.

**Request**
```
Content-Type: multipart/form-data
file: frame.png
```

**Response**
```json
{
  "prediction": 5
}
```

---

### 🔧 Image Preprocessing Pipeline

실제 카메라 이미지를 MNIST 형식에 맞게 변환합니다.

| Step | Process |
|:----:|---------|
| 1 | Image Decode |
| 2 | Grayscale Conversion |
| 3 | Gaussian Blur |
| 4 | Adaptive Threshold |
| 5 | Morphological Noise Removal |
| 6 | Connected Components Analysis |
| 7 | Digit Bounding Box Detection |
| 8 | Digit Crop |
| 9 | Square Padding |
| 10 | Resize to 28×28 |
| 11 | MNIST Normalization |

> 💡 디버그 이미지는 `backend/debug_images/` 에 자동으로 저장됩니다.

---

### 🧠 Model Architecture

간단하고 효율적인 CNN 구조를 사용합니다.

```
Input (1 × 28 × 28)
    │
    ▼
Conv2D (32 filters) → ReLU → MaxPool
    │
    ▼
Conv2D (64 filters) → ReLU → MaxPool
    │
    ▼
Flatten
    │
    ▼
Linear (128) → Dropout
    │
    ▼
Linear (10)  ← Output (digits 0–9)
```

- **Dataset**: MNIST
- **Framework**: PyTorch

---

## 📱 Flutter App

### Screens

| 화면 | 설명 |
|------|------|
| `home_screen.dart` | 두 기능 선택 메인 화면 |
| `live_digit_screen.dart` | 실시간 숫자 인식 (서버 기반) |
| `pose_screen.dart` | 실시간 자세 인식 (온디바이스) |

### Services

| 파일 | 역할 |
|------|------|
| `api_service.dart` | 서버로 프레임 전송 및 예측 결과 수신 |
| `server_config.dart` | 백엔드 서버 주소 설정 관리 |

### Features

**🔢 Digit Recognition**
- 실시간 카메라 스트림 표시
- 이미지 프레임 PNG 변환 및 서버 전송
- 예측 결과 실시간 표시

**🧍 Pose Detection**
- 실시간 카메라 스트림 처리
- ML Kit 기반 관절 좌표(Landmarks) 추출
- CustomPainter로 Skeleton 오버레이 시각화

---

## ⚙️ Installation

### 1. Backend Setup

```bash
cd backend

# 가상환경 생성 및 활성화
python -m venv venv
source venv/bin/activate        # Windows: venv\Scripts\activate

# 의존성 설치
pip install fastapi uvicorn torch torchvision opencv-python numpy

# 서버 실행
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

### 2. Flutter Setup

```bash
cd flutter/app

flutter pub get
flutter run
```

> 📌 Digit Recognition 기능 사용 시, Flutter 앱 실행 전 백엔드 서버가 먼저 구동되어 있어야 합니다.  
> 📌 Pose Detection은 온디바이스 처리로 서버 없이 동작합니다.

---

## 🛠️ Tech Stack

| 영역 | 기술 |
|------|------|
| Mobile | Flutter, camera, http |
| Backend | FastAPI, Uvicorn |
| ML | PyTorch, torchvision |
| Vision | OpenCV, NumPy |
| On-Device AI | Google ML Kit Pose Detection |

---

## 🚧 Key Challenges

### 📸 Camera Frame Format
iOS 카메라 프레임은 `BGRA8888` 포맷으로 전달되므로, Flutter 측에서 PNG로 변환하는 처리가 필요했습니다.

### 🖼️ Image Preprocessing
실제 카메라 이미지는 MNIST 학습 데이터와 환경이 다르기 때문에 배경 제거, 숫자 영역 탐지, 28×28 정규화 과정이 중요했습니다.

### ⚡ Real-time Inference
매 프레임마다 서버 요청을 보내면 과부하가 발생하므로, 일정 간격으로 프레임을 샘플링하여 전송하도록 설계했습니다.

### 🧍 On-Device vs Server-Based Processing
숫자 인식(서버 기반)과 자세 인식(온디바이스)은 처리 방식이 다릅니다.  
ML Kit를 활용한 온디바이스 처리는 서버 없이 낮은 지연으로 실시간 추론이 가능합니다.

---

## 🔭 Future Improvements

- [ ] MediaPipe 기반 숫자 ROI Detection
- [ ] 모델 정확도 개선
- [ ] On-device Inference (TFLite) — 숫자 인식도 온디바이스로 전환
- [ ] 다중 숫자 동시 인식
- [ ] Pose Detection 기반 동작 인식 (Action Recognition)

---

## 👤 Author

**Bae Jaehoon**  
Computer Vision Project