from fastapi import APIRouter, HTTPException
from app.models.schemas import DistrictAnalyticsResponse, DistrictListItem, ClimateStats, CropTrend
from typing import List
import numpy as np
import logging

logger = logging.getLogger(__name__)
router = APIRouter()

SEASONS = ["Winter", "Summer", "Rainy", "Autumn"]


@router.get("/districts", response_model=List[DistrictListItem], summary="List all districts")
async def list_districts():
    from app.main import app
    return app.state.districts


@router.get("/district/{district_id}", response_model=DistrictAnalyticsResponse, summary="District analytics")
async def district_analytics(district_id: int):
    from app.main import app
    state = app.state

    dc_str = str(district_id)
    if dc_str not in state.historical_data:
        raise HTTPException(status_code=404, detail=f"District {district_id} not found")

    ddata = state.historical_data[dc_str]
    info = ddata["info"]
    crops = ddata["crops"]
    annual = ddata["annual"]
    years = sorted([int(y) for y in annual.keys()])

    # Climate stats per season (averaged across all years)
    climate_stats: List[ClimateStats] = []
    season_labels = {"Winter": "Winter (Jan-Feb)", "Summer": "Summer (Mar-May)",
                     "Rainy": "Monsoon (Jun-Sep)", "Autumn": "Autumn (Oct-Dec)"}
    for season in SEASONS:
        vals = {"max_temp": [], "min_temp": [], "precip": [], "et": [], "windspeed": []}
        for y in years:
            sc = annual[str(y)]["climate"].get(season, {})
            for k in vals:
                if k in sc:
                    vals[k].append(sc[k])
        climate_stats.append(ClimateStats(
            season=season_labels[season],
            avg_max_temp=round(float(np.mean(vals["max_temp"])) if vals["max_temp"] else 0, 1),
            avg_min_temp=round(float(np.mean(vals["min_temp"])) if vals["min_temp"] else 0, 1),
            avg_precip=round(float(np.mean(vals["precip"])) if vals["precip"] else 0, 1),
            avg_et=round(float(np.mean(vals["et"])) if vals["et"] else 0, 1),
            avg_windspeed=round(float(np.mean(vals["windspeed"])) if vals["windspeed"] else 0, 2),
        ))

    # Crop trends
    crop_trends: List[CropTrend] = []
    for crop in crops:
        c_years, c_yields, c_areas, c_shares = [], [], [], []
        for y in years:
            crop_data = annual[str(y)]["crops"].get(crop, {})
            if crop_data:
                c_years.append(y)
                c_yields.append(round(float(crop_data.get("yield", 0)), 1))
                c_areas.append(round(float(crop_data.get("area", 0)), 2))
                c_shares.append(round(float(crop_data.get("area_share", 0)) * 100, 2))
        if c_years:
            crop_trends.append(CropTrend(
                crop=crop, years=c_years, yields=c_yields,
                areas=c_areas, area_shares=c_shares,
            ))

    # Agricultural trend
    ag_years, ag_gca, ag_gia, ag_fert = [], [], [], []
    for y in years:
        ag = annual[str(y)]["agriculture"]
        ag_years.append(y)
        ag_gca.append(round(ag.get("GCA", 0), 1))
        ag_gia.append(round(ag.get("GIA", 0), 1))
        ag_fert.append(round(ag.get("total_fertiliser", 0) / 1000, 1))  # convert to thousand tons

    return DistrictAnalyticsResponse(
        district_id=district_id,
        district_name=info["dist_name"],
        state_name=info["state_name"],
        lat=info["lat"],
        lon=info["lon"],
        climate_zone=info.get("zone", "unknown"),
        available_years=years,
        crops=crops,
        climate_stats=climate_stats,
        crop_trends=crop_trends,
        ag_trend={
            "years": ag_years,
            "gca_1000ha": ag_gca,
            "gia_1000ha": ag_gia,
            "fertiliser_kton": ag_fert,
        },
    )
