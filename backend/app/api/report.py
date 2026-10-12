from fastapi import APIRouter, HTTPException, Query
from fastapi.responses import FileResponse
from app.models.schemas import ReportRequest, RecommendRequest, ScenarioRequest
from app.api.recommend import recommend
from app.api.scenario import scenario
import logging
import os

logger = logging.getLogger(__name__)
router = APIRouter()


@router.post("/report", summary="Generate PDF report")
async def generate_report(req: ReportRequest):
    from app.main import app
    state = app.state

    dc_str = str(req.district_id)
    if dc_str not in state.historical_data:
        raise HTTPException(status_code=404, detail=f"District {req.district_id} not found")

    target_year = req.year if req.year is not None else 2026

    # Get recommendation
    rec_req = RecommendRequest(district_id=req.district_id, year=target_year)

    try:
        rec = await recommend(rec_req)
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to generate recommendation: {e}")

    scen_result = None
    if req.include_scenario:
        scen_req = req.scenario_params or ScenarioRequest(district_id=req.district_id, year=target_year)
        try:
            scen_result = await scenario(scen_req)
        except Exception as e:
            logger.warning(f"Scenario generation failed for report: {e}")

    try:
        filepath = state.report_generator.generate_report(
            recommendation=rec,
            scenario=scen_result,
            output_dir=state.reports_dir,
        )
    except Exception as e:
        logger.exception(f"PDF generation failed: {e}")
        raise HTTPException(status_code=500, detail="PDF generation failed")

    if not os.path.exists(filepath):
        raise HTTPException(status_code=500, detail="Report file not created")

    filename = os.path.basename(filepath)
    return FileResponse(
        path=filepath,
        media_type="application/pdf",
        filename=filename,
        headers={
            "Content-Disposition": f'attachment; filename="{filename}"',
            "Access-Control-Expose-Headers": "Content-Disposition",
        },
    )


@router.get("/report/download", summary="Download PDF report directly via GET")
async def download_report_get(
    district_id: int = Query(..., description="District code"),
    year: int = Query(2026, description="Target year"),
    include_scenario: bool = Query(False, description="Include scenario in report"),
    rainfall_change: float = Query(0.0),
    temperature_change: float = Query(0.0),
    irrigation_change: float = Query(0.0),
    fertilizer_change: float = Query(0.0),
):
    scen_params = None
    if include_scenario:
        scen_params = ScenarioRequest(
            district_id=district_id,
            year=year,
            rainfall_change=rainfall_change,
            temperature_change=temperature_change,
            irrigation_change=irrigation_change,
            fertilizer_change=fertilizer_change,
        )
    req = ReportRequest(
        district_id=district_id,
        year=year,
        include_scenario=include_scenario,
        scenario_params=scen_params,
    )
    return await generate_report(req)
