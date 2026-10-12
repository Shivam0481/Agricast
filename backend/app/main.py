"""
AgriCAST FastAPI Application
AI-Powered Climate-Adaptive Crop Recommendation System
"""
import json
import os
import logging
from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from app.core.config import settings
from app.core.model_loader import ModelLoader
from app.models.schemas import DistrictListItem, HealthResponse
from app.services.feature_engine import FeatureEngine
from app.services.recommender import Recommender
from app.services.scenario_engine import ScenarioEngine
from app.services.report_generator import generate_report
from app.api import recommend, scenario, district, report

logging.basicConfig(level=logging.INFO, format="%(levelname)s | %(name)s | %(message)s")
logger = logging.getLogger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Startup: load models and data once."""
    logger.info("🚀 AgriCAST API starting up...")

    # Load ML models
    ModelLoader.load(settings.MODEL_DIR, settings.MODEL_FILE, settings.FEATURES_FILE)

    # Load historical data
    hist_path = os.path.join(settings.DATA_DIR, "historical_data.json")
    dist_path = os.path.join(settings.DATA_DIR, "districts.json")

    if not os.path.exists(hist_path):
        logger.error(f"Historical data not found: {hist_path}")
        app.state.historical_data = {}
        app.state.districts = []
    else:
        with open(hist_path) as f:
            app.state.historical_data = json.load(f)
        logger.info(f"✅ Loaded data for {len(app.state.historical_data)} districts")

    if os.path.exists(dist_path):
        with open(dist_path) as f:
            raw_districts = json.load(f)
        app.state.districts = [
            DistrictListItem(
                dist_code=d["dist_code"],
                dist_name=d["dist_name"],
                state_name=d["state_name"],
                state_code=d["state_code"],
                zone=d.get("zone", "unknown"),
                lat=d["lat"],
                lon=d["lon"],
            )
            for d in raw_districts
        ]
    else:
        app.state.districts = []

    # Initialise services
    app.state.feature_engine = FeatureEngine(app.state.historical_data)
    app.state.recommender = Recommender(app.state.feature_engine)
    app.state.scenario_engine = ScenarioEngine(app.state.feature_engine, app.state.recommender)
    app.state.report_generator = type("RG", (), {"generate_report": staticmethod(generate_report)})()
    app.state.reports_dir = settings.REPORTS_DIR
    os.makedirs(settings.REPORTS_DIR, exist_ok=True)

    logger.info("✅ AgriCAST API ready")
    yield
    logger.info("AgriCAST API shutting down")


app = FastAPI(
    title="AgriCAST API",
    description="AI-Powered Climate-Adaptive Crop Recommendation System",
    version=settings.VERSION,
    lifespan=lifespan,
)

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Routers
app.include_router(recommend.router, prefix="/api", tags=["Recommendation"])
app.include_router(scenario.router, prefix="/api", tags=["Scenario"])
app.include_router(district.router, prefix="/api", tags=["District"])
app.include_router(report.router, prefix="/api", tags=["Reports"])


@app.get("/", tags=["Root"])
async def root():
    return {"message": "AgriCAST API", "version": settings.VERSION, "docs": "/docs"}


@app.get("/health", response_model=HealthResponse, tags=["Health"])
async def health():
    return HealthResponse(
        status="ok" if ModelLoader.is_loaded() else "degraded",
        model_loaded=ModelLoader.is_loaded(),
        districts_loaded=len(app.state.historical_data),
        version=settings.VERSION,
    )


@app.exception_handler(Exception)
async def generic_handler(request, exc):
    logger.error(f"Unhandled error: {exc}")
    return JSONResponse(status_code=500, content={"detail": "Internal server error"})
