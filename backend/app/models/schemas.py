from pydantic import BaseModel, Field
from typing import List, Optional, Dict, Any


# ── Request Models ─────────────────────────────────────────────

class RecommendRequest(BaseModel):
    district_id: int = Field(..., description="District code")
    year: Optional[int] = Field(2026, ge=2004, le=2035, description="Target year for recommendation (defaults to present 2026)")


class ScenarioRequest(BaseModel):
    district_id: int
    year: Optional[int] = Field(2026, ge=2004, le=2035, description="Target year (defaults to present 2026)")
    rainfall_change: float = Field(0.0, ge=-50.0, le=50.0, description="% change in rainfall")
    temperature_change: float = Field(0.0, ge=-5.0, le=5.0, description="°C change in temperature")
    irrigation_change: float = Field(0.0, ge=-50.0, le=50.0, description="% change in irrigation")
    fertilizer_change: float = Field(0.0, ge=-50.0, le=50.0, description="% change in fertilizer")


class ReportRequest(BaseModel):
    district_id: int
    year: Optional[int] = Field(2026, ge=2004, le=2035, description="Target year")
    include_scenario: bool = False
    scenario_params: Optional[ScenarioRequest] = None


# ── Response Models ─────────────────────────────────────────────

class CropRank(BaseModel):
    rank: int
    crop: str
    score: float
    confidence: float  # 0-100 percentage
    yield_lag1: Optional[float] = None
    yield_hist_mean: Optional[float] = None
    area_share: Optional[float] = None


class FeatureInfluence(BaseModel):
    feature_group: str
    display_name: str
    direction: str   # "positive" | "negative" | "neutral"
    magnitude: str   # "high" | "medium" | "low"


class RecommendationResponse(BaseModel):
    model_config = {"protected_namespaces": ()}

    district_id: int
    district_name: str
    state_name: str
    year: int
    top_crop: str
    top_confidence: float
    rankings: List[CropRank]
    explanation: str
    feature_influences: List[FeatureInfluence]
    climate_summary: Dict[str, Any]
    model_loaded: bool


class ScenarioRankItem(BaseModel):
    rank: int
    crop: str
    confidence: float
    change: float   # delta from baseline


class ScenarioResponse(BaseModel):
    district_id: int
    district_name: str
    year: int
    baseline_top: str
    scenario_top: str
    recommendation_changed: bool
    baseline_rankings: List[ScenarioRankItem]
    scenario_rankings: List[ScenarioRankItem]
    explanation: str
    scenario_params: Dict[str, float]


class ClimateStats(BaseModel):
    season: str
    avg_max_temp: float
    avg_min_temp: float
    avg_precip: float
    avg_et: float
    avg_windspeed: float


class CropTrend(BaseModel):
    crop: str
    years: List[int]
    yields: List[float]
    areas: List[float]
    area_shares: List[float]


class DistrictAnalyticsResponse(BaseModel):
    district_id: int
    district_name: str
    state_name: str
    lat: float
    lon: float
    climate_zone: str
    available_years: List[int]
    crops: List[str]
    climate_stats: List[ClimateStats]
    crop_trends: List[CropTrend]
    ag_trend: Dict[str, List]


class DistrictListItem(BaseModel):
    dist_code: int
    dist_name: str
    state_name: str
    state_code: int
    zone: str
    lat: float
    lon: float


class HealthResponse(BaseModel):
    model_config = {"protected_namespaces": ()}

    status: str
    model_loaded: bool
    districts_loaded: int
    version: str
