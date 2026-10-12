"""
Scenario Engine — applies hypothetical climate/ag changes and re-runs the model.
"""
import numpy as np
import logging
from typing import List, Tuple, Dict

from app.services.feature_engine import FeatureEngine, SEASONS, SEASON_LABELS
from app.services.recommender import Recommender, _softmax
from app.models.schemas import ScenarioRankItem

logger = logging.getLogger(__name__)


def _describe_change(
    baseline_top: str, scenario_top: str,
    rainfall_chg: float, temp_chg: float,
    irr_chg: float, fert_chg: float,
) -> str:
    parts = []
    if abs(rainfall_chg) >= 5:
        d = "reduction" if rainfall_chg < 0 else "increase"
        parts.append(f"a rainfall {d} of {abs(rainfall_chg):.0f}%")
    if abs(temp_chg) >= 0.5:
        d = "rise" if temp_chg > 0 else "drop"
        parts.append(f"a temperature {d} of {abs(temp_chg):.1f}°C")
    if abs(irr_chg) >= 5:
        d = "reduction" if irr_chg < 0 else "expansion"
        parts.append(f"an irrigation {d} of {abs(irr_chg):.0f}%")
    if abs(fert_chg) >= 5:
        d = "decrease" if fert_chg < 0 else "increase"
        parts.append(f"a fertiliser {d} of {abs(fert_chg):.0f}%")

    scenario_str = ", ".join(parts) if parts else "minor environmental adjustments"
    changed = baseline_top != scenario_top

    if changed:
        if rainfall_chg < -15:
            return (
                f"Under {scenario_str}, drought-tolerant crops gain advantage. "
                f"{scenario_top} overtakes {baseline_top} as the model favours crops "
                f"with lower water requirements and stronger performance under rainfall stress."
            )
        elif rainfall_chg > 15:
            return (
                f"Increased moisture from {scenario_str} benefits water-intensive crops. "
                f"{scenario_top} displaces {baseline_top} as conditions favour higher water-use crops."
            )
        elif temp_chg > 1.5:
            return (
                f"The warming scenario ({scenario_str}) shifts recommendations toward heat-tolerant varieties. "
                f"{scenario_top} is better adapted to elevated temperatures than {baseline_top}."
            )
        else:
            return (
                f"The combined scenario ({scenario_str}) causes sufficient shifts in climate-agricultural "
                f"suitability that {scenario_top} is now ranked above {baseline_top}."
            )
    else:
        return (
            f"Despite {scenario_str}, {baseline_top} retains its top position. "
            f"Its strong historical yield and area share provide robustness "
            f"against the simulated scenario changes."
        )


class ScenarioEngine:
    def __init__(self, feature_engine: FeatureEngine, recommender: Recommender):
        self.fe = feature_engine
        self.recommender = recommender

    def run_scenario(
        self,
        dist_code: int,
        year: int,
        district_name: str,
        crops: List[str],
        rainfall_change: float = 0.0,    # percent
        temperature_change: float = 0.0,  # degrees C
        irrigation_change: float = 0.0,   # percent
        fertilizer_change: float = 0.0,   # percent
    ) -> dict:
        from app.core.model_loader import ModelLoader

        # Baseline
        base_rankings, base_explanation, base_influences = self.recommender.recommend(
            dist_code, year, district_name, crops
        )
        baseline_top = base_rankings[0].crop

        # Build scenario overrides
        annual = self.fe._get_annual(dist_code, year)
        if not annual:
            raise ValueError(f"No data for district {dist_code}, year {year}")

        # Climate override: apply rainfall and temperature changes
        climate_override = {}
        for season in SEASONS:
            sc = annual["climate"][season]
            new_precip = max(0, sc["precip"] * (1 + rainfall_change / 100.0))
            new_et = max(1, sc["et"] * (1 + rainfall_change / 200.0))  # ET partially tracks rainfall
            climate_override[season] = {
                "precip": new_precip,
                "et": new_et,
                "max_temp": sc["max_temp"] + temperature_change,
                "min_temp": sc["min_temp"] + temperature_change,
                "windspeed": sc["windspeed"],
            }

        # Agricultural override
        ag = annual["agriculture"]
        ag_override = {
            "GIA": max(0, ag["GIA"] * (1 + irrigation_change / 100.0)),
            "nitrogen": max(0, ag["nitrogen"] * (1 + fertilizer_change / 100.0)),
            "phosphate": max(0, ag["phosphate"] * (1 + fertilizer_change / 100.0)),
            "potash": max(0, ag["potash"] * (1 + fertilizer_change / 100.0)),
            "total_fertiliser": max(0, ag["total_fertiliser"] * (1 + fertilizer_change / 100.0)),
        }

        # Build scenario feature matrix
        scen_matrix, crop_list = self.fe.build_feature_matrix(
            dist_code, year, crops,
            climate_override=climate_override,
            ag_override=ag_override,
        )

        model = ModelLoader.get_model()
        if model is None:
            scen_scores = np.array([
                scen_matrix.iloc[i]["Yield_hist_mean"] +
                scen_matrix.iloc[i]["Yield_lag1"] * 0.5
                for i in range(len(crop_list))
            ])
        else:
            scen_scores = model.predict(scen_matrix)

        scen_confidences = _softmax(scen_scores) * 100.0

        scen_ranked = sorted(
            zip(crop_list, scen_scores, scen_confidences),
            key=lambda x: -x[1],
        )
        scenario_top = scen_ranked[0][0]

        # Build output ranking items
        base_conf_map = {r.crop: r.confidence for r in base_rankings}

        scenario_rankings: List[ScenarioRankItem] = []
        for rank_idx, (crop, score, conf) in enumerate(scen_ranked, 1):
            base_c = base_conf_map.get(crop, 0.0)
            scenario_rankings.append(ScenarioRankItem(
                rank=rank_idx,
                crop=crop,
                confidence=round(float(conf), 2),
                change=round(float(conf) - base_c, 2),
            ))

        baseline_rankings_out: List[ScenarioRankItem] = [
            ScenarioRankItem(
                rank=r.rank, crop=r.crop,
                confidence=r.confidence, change=0.0
            )
            for r in base_rankings
        ]

        explanation = _describe_change(
            baseline_top, scenario_top,
            rainfall_change, temperature_change,
            irrigation_change, fertilizer_change,
        )

        return {
            "district_id": dist_code,
            "district_name": district_name,
            "year": year,
            "baseline_top": baseline_top,
            "scenario_top": scenario_top,
            "recommendation_changed": baseline_top != scenario_top,
            "baseline_rankings": baseline_rankings_out,
            "scenario_rankings": scenario_rankings,
            "explanation": explanation,
            "scenario_params": {
                "rainfall_change": rainfall_change,
                "temperature_change": temperature_change,
                "irrigation_change": irrigation_change,
                "fertilizer_change": fertilizer_change,
            },
        }
