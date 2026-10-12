from fastapi import APIRouter, HTTPException
from app.models.schemas import ScenarioRequest, ScenarioResponse
import logging

logger = logging.getLogger(__name__)
router = APIRouter()


@router.post("/scenario", response_model=ScenarioResponse, summary="Run scenario analysis")
async def scenario(req: ScenarioRequest):
    from app.main import app
    state = app.state

    dc_str = str(req.district_id)
    if dc_str not in state.historical_data:
        raise HTTPException(status_code=404, detail=f"District {req.district_id} not found")

    dist_info = state.historical_data[dc_str]["info"]
    crops = state.historical_data[dc_str]["crops"]

    target_year = req.year if req.year is not None else 2026
    if target_year < 2004:
        raise HTTPException(status_code=422, detail="Year must be >= 2004 (insufficient history)")

    try:
        result = state.scenario_engine.run_scenario(
            dist_code=req.district_id,
            year=target_year,
            district_name=dist_info["dist_name"],
            crops=crops,
            rainfall_change=req.rainfall_change,
            temperature_change=req.temperature_change,
            irrigation_change=req.irrigation_change,
            fertilizer_change=req.fertilizer_change,
        )
    except Exception as e:
        logger.exception(f"Scenario failed: {e}")
        raise HTTPException(status_code=500, detail="Scenario engine error")

    return ScenarioResponse(**result)
