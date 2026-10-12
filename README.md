# AgriCAST 🌾
### AI-Powered Climate-Adaptive Crop Recommendation System

> **AgriCAST is NOT a yield prediction system.**  
> It is an intelligent **pre-season crop recommendation and decision-support platform** that ranks candidate crops before sowing season using a trained Learning-to-Rank (**LambdaMART / LightGBM**) model.

---

## 🌟 Key Architecture & Highlights

- **Machine Learning Core**:
  - **Model**: `LGBMRanker` (LambdaMART with NDCG optimization, 200 estimators, dart boosting)
  - **Features**: 95 engineered domain features:
    - **Climate Features (30)**: Pre-sowing temperatures, precipitation, PET, soil moisture, and cross-season anomalies.
    - **Soil & Physiography (15)**: pH, CEC, organic carbon, water retention capacity, texture, and zone indices.
    - **Historical Crop Performance (30)**: 1-year, 2-year, 3-year lagged yields, area share dynamics, and yield stability metrics.
    - **Agronomic Inputs (10)**: Irrigation percentage, NPK fertilizer application intensity, and mechanization levels.
    - **Economic & Market Signals (10)**: MSP trends, volatility, price parity ratios, and input-to-output margins.
  - **Inference**: Dynamically computes feature vectors for all candidate crops in a selected district and evaluates pre-season ranking with softmax calibrated confidence scores.

- **Backend (FastAPI)**:
  - High-performance asynchronous REST API (`/health`, `/api/districts`, `/api/recommend`, `/api/scenario`, `/api/district/{id}`, `/api/report`).
  - What-If Climate Simulation Engine (adjust rainfall $\pm50\%$, temperature $\pm5^\circ\text{C}$, irrigation, fertilizer).
  - Feature Influence Explainer (interprets top drivers for each crop recommendation).
  - Production PDF Dossier Generator (built with ReportLab).

- **Frontend (Flutter)**:
  - Rich interactive single-page application built with Flutter Material 3.
  - **Screens**:
    - **Hero Landing Page**: Value proposition, 8-step methodology, feature breakdown.
    - **Interactive Recommendation Dashboard**: District selector, year picker, top crop banner, ranking table, radar & bar charts, feature influence breakdown.
    - **Climate Scenario Lab ("What-If")**: Dynamic sliders for rainfall, temperature, irrigation, and fertilizer with real-time recalculation of rank shifts.
    - **District Agro-Climatic Analytics**: Climate timeline, seasonal trends, and crop yield history.
    - **PDF Dossier Exporter**: In-browser report generation and instant PDF download.
    - **About & Methodology**: Research foundation, ranking vs regression comparison, full tech stack.

---

## 🚀 Quick Start

### Prerequisites
- Python 3.10+
- Flutter 3.19+
- Chrome browser (for Flutter web)

### 1-Click Startup
```bash
./start.sh
```
This automatically boots:
1. **Backend FastAPI server**: `http://127.0.0.1:8000` (API docs at `/docs`)
2. **Flutter Web application**: `http://localhost:3000`

---

## 🛠 Manual Execution

### Backend
```bash
# Install dependencies
pip install -r backend/requirements.txt

# Run server
export PYTHONPATH=backend:$PYTHONPATH
uvicorn app.main:app --app-dir backend --host 0.0.0.0 --port 8000 --reload
```

### Flutter Frontend
```bash
cd frontend
flutter pub get
flutter run -d chrome --web-port 3000
```

---

## 🐳 Docker Deployment

Run the entire backend in a container:
```bash
docker-compose up --build
```
The API will be available at `http://localhost:8000`.

---

## 🧪 Testing

### Backend End-to-End Tests
```bash
PYTHONPATH=backend python3 -c "
from fastapi.testclient import TestClient
from app.main import app
with TestClient(app) as client:
    print('Health:', client.get('/health').json())
    print('Recommend:', client.post('/api/recommend', json={'district_id': 901, 'year': 2023}).status_code)
"
```

### Frontend Widget Tests
```bash
cd frontend
flutter test
```
