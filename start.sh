#!/usr/bin/env bash
set -e

# AgriCAST - Quick Start Script
# Runs backend FastAPI service and Flutter web app

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "🌾 Starting AgriCAST: AI-Powered Crop Recommendation Platform"
echo "Project root: $ROOT_DIR"

# 1. Start Backend in background
echo ""
echo "🌱 Starting Backend (FastAPI on port 8000)..."
export PYTHONPATH="$ROOT_DIR/backend:$PYTHONPATH"
cd "$ROOT_DIR"
python3 -m uvicorn app.main:app --app-dir "$ROOT_DIR/backend" --host 0.0.0.0 --port 8000 --reload &
BACKEND_PID=$!
echo "Backend running at http://127.0.0.1:8000 (PID: $BACKEND_PID)"
echo "API Docs at http://127.0.0.1:8000/docs"

# Wait for backend health check
echo "Waiting for backend to be ready..."
sleep 3
curl -s http://127.0.0.1:8000/health || true
echo ""

# 2. Start Flutter Web Frontend
echo "💻 Launching Flutter Web Frontend..."
cd "$ROOT_DIR/frontend"
flutter run -d chrome --web-port 3000

# Cleanup on exit
kill $BACKEND_PID || true
