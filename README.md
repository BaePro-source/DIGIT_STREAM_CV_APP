# 🔢 MNIST Stream CV App

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white"/>
  <img src="https://img.shields.io/badge/FastAPI-009688?style=for-the-badge&logo=fastapi&logoColor=white"/>
  <img src="https://img.shields.io/badge/PyTorch-EE4C2C?style=for-the-badge&logo=pytorch&logoColor=white"/>
  <img src="https://img.shields.io/badge/OpenCV-5C3EE8?style=for-the-badge&logo=opencv&logoColor=white"/>
</p>

<p align="center">
  실시간 카메라 스트림으로 손글씨 숫자를 인식하는 Computer Vision 앱<br/>
  Flutter × FastAPI × MNIST CNN
</p>

---

## 📌 Overview

Flutter 모바일 앱에서 카메라 프레임을 캡처하여 FastAPI 서버로 전송하고,  
MNIST CNN 모델이 숫자를 예측한 뒤 결과를 실시간으로 앱에 표시합니다.

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

---

## 🎬 Demo

앱 화면은 두 영역으로 구성됩니다.

```
+──────────────────────+
│   📷 Camera Stream   │
│                      │
+──────────────────────+
│   Predicted Digit    │
│          8           │
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
│   └── 📂 app/                  # Flutter 모바일 앱
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

### Features

- 📷 실시간 카메라 스트림
- 🖼️ 이미지 프레임 추출 및 PNG 변환
- 🌐 FastAPI 서버로 HTTP 전송
- 🔢 예측 결과 실시간 표시

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

> 📌 Flutter 앱 실행 전, 백엔드 서버가 먼저 구동되어 있어야 합니다.

---

## 🛠️ Tech Stack

| 영역 | 기술 |
|------|------|
| Mobile | Flutter, camera, http |
| Backend | FastAPI, Uvicorn |
| ML | PyTorch, torchvision |
| Vision | OpenCV, NumPy |

---

## 🚧 Key Challenges

### 📸 Camera Frame Format
iOS 카메라 프레임은 `BGRA8888` 포맷으로 전달되므로, Flutter 측에서 PNG로 변환하는 처리가 필요했습니다.

### 🖼️ Image Preprocessing
실제 카메라 이미지는 MNIST 학습 데이터와 환경이 다르기 때문에 배경 제거, 숫자 영역 탐지, 28×28 정규화 과정이 중요했습니다.

### ⚡ Real-time Inference
매 프레임마다 서버 요청을 보내면 과부하가 발생하므로, 일정 간격으로 프레임을 샘플링하여 전송하도록 설계했습니다.

---

## 🔭 Future Improvements

- [ ] MediaPipe 기반 숫자 ROI Detection
- [ ] 모델 정확도 개선
- [ ] On-device Inference (TFLite)
- [ ] 다중 숫자 동시 인식

---

## 👤 Author

**Bae Jaehoon**  
Computer Vision Project
