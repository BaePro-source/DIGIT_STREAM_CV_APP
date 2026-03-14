MNIST Stream CV App

실시간 카메라 스트림을 이용하여 숫자를 인식하는 Computer Vision 애플리케이션입니다.
Flutter 모바일 앱에서 카메라 프레임을 서버로 전송하고, FastAPI 서버에서 MNIST CNN 모델을 이용하여 숫자를 예측한 뒤 결과를 앱으로 반환합니다.

Project Overview

이 프로젝트는 다음과 같은 파이프라인으로 동작합니다.

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