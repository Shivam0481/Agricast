from fastapi import APIRouter, HTTPException, Depends
from app.models.schemas import RecommendRequest, RecommendationResponse
from app.core.model_loader import ModelLoader
import logging

logger = logging.getLogger(__name__)
router = APIRouter()


def get_app_state():
    from app.main import app
    return app.state


@router.post("/recommend", response_model=RecommendationResponse, summary="Generate crop recommendation")
async def recommend(req: RecommendRequest):
    from app.main import app
    state = app.state

    dc_str = str(req.district_id)
    if dc_str not in state.historical_data:
        raise HTTPException(status_code=404, detail=f"District {req.district_id} not found")

    dist_info = state.historical_data[dc_str]["info"]
    target_year = req.year if req.year is not None else 2026

    if target_year < 2004:
        raise HTTPException(status_code=422, detail="Year must be >= 2004 (need lag history)")

    crops = state.historical_data[dc_str]["crops"]

    try:
        rankings, explanation, influences = state.recommender.recommend(
            dist_code=req.district_id,
            year=target_year,
            district_name=dist_info["dist_name"],
            crops=crops,
        )
        climate_summary = state.feature_engine.get_climate_summary(req.district_id, target_year)
    except Exception as e:
        logger.exception(f"Recommendation failed: {e}")
        raise HTTPException(status_code=500, detail="Recommendation engine error")

    return RecommendationResponse(
        district_id=req.district_id,
        district_name=dist_info["dist_name"],
        state_name=dist_info["state_name"],
        year=target_year,
        top_crop=rankings[0].crop,
        top_confidence=rankings[0].confidence,
        rankings=rankings,
        explanation=explanation,
        feature_influences=influences,
        climate_summary=climate_summary,
        model_loaded=ModelLoader.is_loaded(),
    )
