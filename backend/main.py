import torch
import torch.nn as nn

from fastapi import FastAPI, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware

from utils.preprocess import preprocess_image


class MNISTCNN(nn.Module):
    def __init__(self):
        super().__init__()
        self.features = nn.Sequential(
            nn.Conv2d(1, 32, kernel_size=3, padding=1),
            nn.ReLU(),
            nn.MaxPool2d(2),

            nn.Conv2d(32, 64, kernel_size=3, padding=1),
            nn.ReLU(),
            nn.MaxPool2d(2)
        )

        self.classifier = nn.Sequential(
            nn.Flatten(),
            nn.Linear(64 * 7 * 7, 128),
            nn.ReLU(),
            nn.Dropout(0.3),
            nn.Linear(128, 10)
        )

    def forward(self, x):
        x = self.features(x)
        x = self.classifier(x)
        return x


app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

model = MNISTCNN().to(device)
model.load_state_dict(torch.load("models/mnist_cnn.pth", map_location=device))
model.eval()


@app.get("/")
def root():
    return {"message": "MNIST Stream CV backend is running"}


@app.post("/predict")
async def predict(file: UploadFile = File(...)):
    try:
        contents = await file.read()

        input_tensor = preprocess_image(contents).to(device)

        with torch.no_grad():
            output = model(input_tensor)
            prediction = torch.argmax(output, dim=1).item()

        return {"prediction": prediction}

    except Exception as e:
        print("predict error:", repr(e))
        return {"prediction": -1, "error": str(e)}