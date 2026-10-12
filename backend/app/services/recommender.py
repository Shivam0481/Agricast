"""
Recommender Service — loads feature vectors into LambdaMART and produces ranked crop list.
"""
import numpy as np
import logging
from typing import List, Dict, Optional, Tuple

from app.core.model_loader import ModelLoader
from app.services.feature_engine import FeatureEngine
from app.models.schemas import CropRank, FeatureInfluence

logger = logging.getLogger(__name__)


EXPLANATION_TEMPLATES = {
    "high_yield_hist": (
        "{crop} is the top recommendation for {district} in {year}. "
        "It has consistently delivered strong yields in this district, "
        "with a historical average of {hist_mean:.0f} kg/ha and a previous-year yield of {lag1:.0f} kg/ha. "
        "Its stable cultivation history makes it a dependable choice under current climate conditions."
    ),
    "climate_favourable": (
        "{crop} is recommended for {district} in {year}. "
        "Current seasonal climate patterns — particularly rainfall and temperature anomalies — "
        "are well-suited to its growth requirements. "
        "It maintains a {area_share:.1f}% area share in the district, "
        "indicating farmer confidence in its suitability."
    ),
    "area_dominant": (
        "{crop} leads the recommendation for {district} in {year}. "
        "It occupies {area_share:.1f}% of the gross cropped area, reflecting its strategic importance. "
        "Combined with an above-average yield of {lag1:.0f} kg/ha in the previous year, "
        "it remains the most suitable crop for the upcoming season."
    ),
    "default": (
        "{crop} is recommended as the most suitable crop for {district} in {year}. "
        "The LambdaMART model identified it based on historical yield performance, "
        "area cultivation share, and seasonal climate indicators. "
        "Key factors include prior-year yield, rolling yield trends, and climate anomalies."
    ),
}


def _softmax(x: np.ndarray) -> np.ndarray:
    e = np.exp(x - x.max())
    return e / e.sum()


def _build_explanation(
    top_crop: str,
    district_name: str,
    year: int,
    crop_rank: CropRank,
) -> str:
    area_share_pct = (crop_rank.area_share or 0.0) * 100
    lag1 = crop_rank.yield_lag1 or 0.0
    hist_mean = crop_rank.yield_hist_mean or 0.0

    if lag1 > 0 and hist_mean > 0:
        if lag1 >= hist_mean * 0.95:
            tpl = "high_yield_hist"
        elif area_share_pct >= 20:
            tpl = "area_dominant"
        else:
            tpl = "climate_favourable"
    else:
        tpl = "default"

    return EXPLANATION_TEMPLATES[tpl].format(
        crop=top_crop,
        district=district_name,
        year=year,
        hist_mean=hist_mean,
        lag1=lag1,
        area_share=area_share_pct,
    )


def _feature_influences(scores: np.ndarray, feature_matrix) -> List[FeatureInfluence]:
    """Generate high-level feature influence summary for the top-ranked crop."""
    influences = []

    # Compare top-ranked crop's anomaly features to determine climate influence
    top_row = feature_matrix.iloc[0]

    # Monsoon precipitation anomaly
    rain_anom = top_row.get("Rainy_JUN-SEP_PERCIPITATION_(Millimeters)_anomaly", 0)
    rain_dir = "positive" if rain_anom > 20 else ("negative" if rain_anom < -20 else "neutral")
    influences.append(FeatureInfluence(
        feature_group="Monsoon Rainfall",
        display_name="Monsoon Season Precipitation",
        direction=rain_dir,
        magnitude="high" if abs(rain_anom) > 80 else ("medium" if abs(rain_anom) > 30 else "low"),
    ))

    # Temperature anomaly
    temp_anom = top_row.get("Rainy_JUN-SEP_MAXIMUM_TEMPERATURE_(Centigrate)_anomaly", 0)
    temp_dir = "positive" if temp_anom < 0 else ("negative" if temp_anom > 1.5 else "neutral")
    influences.append(FeatureInfluence(
        feature_group="Temperature",
        display_name="Growing Season Temperature",
        direction=temp_dir,
        magnitude="high" if abs(temp_anom) > 2 else ("medium" if abs(temp_anom) > 1 else "low"),
    ))

    # Yield history
    lag1 = top_row.get("Yield_lag1", 0)
    hist_mean = top_row.get("Yield_hist_mean", 1)
    yield_ratio = lag1 / max(hist_mean, 1)
    influences.append(FeatureInfluence(
        feature_group="Historical Yield",
        display_name="Previous Year Yield vs Historical Average",
        direction="positive" if yield_ratio >= 0.95 else "negative",
        magnitude="high" if abs(yield_ratio - 1) > 0.15 else ("medium" if abs(yield_ratio - 1) > 0.05 else "low"),
    ))

    # Area share
    area_share = top_row.get("AreaShare", 0)
    influences.append(FeatureInfluence(
        feature_group="Cultivation Share",
        display_name="District Area Share",
        direction="positive" if area_share > 0.15 else "neutral",
        magnitude="high" if area_share > 0.30 else ("medium" if area_share > 0.10 else "low"),
    ))

    # Irrigation ratio
    irr = top_row.get("IrrRatio", 0.5)
    influences.append(FeatureInfluence(
        feature_group="Irrigation",
        display_name="Irrigation Coverage Ratio",
        direction="positive" if irr > 0.55 else "neutral",
        magnitude="high" if irr > 0.70 else ("medium" if irr > 0.45 else "low"),
    ))

    return influences


class Recommender:
    def __init__(self, feature_engine: FeatureEngine):
        self.fe = feature_engine

    def recommend(
        self,
        dist_code: int,
        year: int,
        district_name: str,
        crops: List[str],
    ) -> Tuple[List[CropRank], str, List[FeatureInfluence]]:
        model = ModelLoader.get_model()

        feature_matrix, crop_list = self.fe.build_feature_matrix(dist_code, year, crops)

        if model is None:
            # Fallback: rank by historical yield
            logger.warning("Model not loaded — using fallback ranking")
            scores = np.array([
                feature_matrix.iloc[i]["Yield_hist_mean"] +
                feature_matrix.iloc[i]["Yield_lag1"] * 0.5
                for i in range(len(crop_list))
            ])
        else:
            scores = model.predict(feature_matrix)

        confidences = _softmax(scores) * 100.0

        ranked = sorted(
            zip(crop_list, scores, confidences, range(len(crop_list))),
            key=lambda x: -x[1],
        )

        rankings: List[CropRank] = []
        for rank_idx, (crop, score, conf, orig_idx) in enumerate(ranked, 1):
            row = feature_matrix.iloc[orig_idx]
            rankings.append(CropRank(
                rank=rank_idx,
                crop=crop,
                score=round(float(score), 4),
                confidence=round(float(conf), 2),
                yield_lag1=round(float(row["Yield_lag1"]), 2),
                yield_hist_mean=round(float(row["Yield_hist_mean"]), 2),
                area_share=round(float(row["AreaShare"]), 4),
            ))

        top = rankings[0]
        explanation = _build_explanation(top.crop, district_name, year, top)

        # Feature influence for the top crop
        top_orig_idx = crop_list.index(top.crop)
        influences = _feature_influences(scores, feature_matrix)

        return rankings, explanation, influences
