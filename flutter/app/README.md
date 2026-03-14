# MNIST Stream CV App

실시간 카메라 스트림을 이용하여 숫자를 인식하는 Computer Vision 애플리케이션입니다.  
Flutter 모바일 앱에서 카메라 프레임을 서버로 전송하고, FastAPI 서버에서 MNIST CNN 모델을 이용하여 숫자를 예측한 뒤 결과를 앱으로 반환합니다.

---

# Project Overview

이 프로젝트는 다음과 같은 파이프라인으로 동작합니다.

```
Camera (Flutter)
↓
Frame Capture (Image Stream)
↓
PNG Encoding
↓
HTTP Request
↓
FastAPI Backend
↓
Image Preprocessing (OpenCV)
↓
MNIST CNN Model Inference
↓
Prediction Result
↓
Flutter UI Display
```

---

# Demo

앱은 화면을 두 영역으로 나누어 구성됩니다.

- 상단: 카메라 실시간 영상  
- 하단: 모델이 예측한 숫자 결과  

Example

```
Camera Frame
↓
Detected Digit: 8
```

---

# Project Structure

```
digit_stream_cv_app
│
├── backend
│   ├── main.py
│   ├── models
│   │   ├── mnist_cnn.pth
│   │   └── train_cnn.py
│   │
│   ├── utils
│   │   └── preprocess.py
│   │
│   ├── debug_images
│   └── venv
│
├── flutter
│   └── app
│
└── README.md
```

---

# Backend

Backend는 **FastAPI**로 구현되어 있으며 다음 역할을 수행합니다.

### 주요 기능

- 이미지 수신 (`/predict`)
- OpenCV 기반 전처리
- MNIST CNN 모델 추론
- 결과 반환

---

# API Endpoint

### POST `/predict`

카메라 프레임을 전송하여 숫자를 예측합니다.

Request

```
multipart/form-data
file: frame.png
```

Response

```
{
  "prediction": 5
}
```

---

# Image Preprocessing Pipeline

MNIST 모델은 단순한 28x28 흑백 숫자를 학습했기 때문에, 카메라 이미지에서 다음 전처리를 수행합니다.

Processing Steps

1. Image Decode  
2. Grayscale Conversion  
3. Gaussian Blur  
4. Adaptive Threshold  
5. Morphological Noise Removal  
6. Connected Components Analysis  
7. Digit Bounding Box Detection  
8. Digit Crop  
9. Square Padding  
10. Resize to 28x28  
11. MNIST Normalization  

Debug images는 다음 위치에 저장됩니다.

```
backend/debug_images/
```

---

# Model

모델은 간단한 CNN 구조를 사용합니다.

```
Input (1x28x28)
↓
Conv2D (32 filters)
↓
ReLU
↓
MaxPool
↓
Conv2D (64 filters)
↓
ReLU
↓
MaxPool
↓
Flatten
↓
Linear (128)
↓
Dropout
↓
Linear (10)
```

Dataset

```
MNIST
```

---

# Flutter App

Flutter 앱은 다음 기능을 수행합니다.

### Features

- 실시간 카메라 스트림
- 이미지 프레임 추출
- PNG 변환
- FastAPI 서버로 전송
- 예측 결과 표시

UI Layout

```
+----------------------+
|   Camera Stream      |
|                      |
+----------------------+
|   Predicted Digit    |
|          5           |
+----------------------+
```

---

# Installation

## Backend Setup

```
cd backend

python -m venv venv
source venv/bin/activate

pip install fastapi
pip install uvicorn
pip install torch
pip install torchvision
pip install opencv-python
pip install numpy
```

서버 실행

```
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

---

## Flutter Setup

```
cd flutter/app
flutter pub get
flutter run
```

---

# Technologies

## Backend

- FastAPI  
- PyTorch  
- OpenCV  
- NumPy  

## Frontend

- Flutter  
- camera package  
- http package  

---

# Key Challenges

실시간 카메라 스트림을 MNIST 모델과 연결하기 위해 다음 문제를 해결했습니다.

### Camera Frame Format

iOS 카메라 프레임은 `BGRA8888` 포맷이므로 이를 PNG로 변환하는 과정이 필요했습니다.

### Image Preprocessing

실제 카메라 이미지는 MNIST 데이터와 다르기 때문에 다음 문제를 해결해야 했습니다.

- 배경 제거
- 숫자 영역 탐지
- 28x28 정규화

### Real-time Inference

프레임마다 서버 요청을 보내면 과부하가 발생하기 때문에 일부 프레임만 서버로 전송하도록 설계했습니다.

---

# Future Improvements

- MediaPipe 기반 숫자 ROI detection  
- Model accuracy improvement  
- On-device inference (TFLite)  
- Multi-digit recognition  

---

# Author

Bae Jaehoon  
Computer Vision Project