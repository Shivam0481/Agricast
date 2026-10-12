"""
Feature Engineering Engine
Builds the 95-feature vector from district+year+crop historical data.
All engineered features are computed here — hidden from the user.
"""
import numpy as np
import pandas as pd
import logging
from typing import Dict, List, Optional, Tuple

logger = logging.getLogger(__name__)

# Ordered feature names matching the pkl (with underscores as in model.feature_name_)
FEATURE_NAMES = [
    "State_Code",
    "GROSS_CROPPED_AREA_(1000_ha)",
    "NITROGEN_CONSUMPTION_(tons)",
    "PHOSPHATE_CONSUMPTION_(tons)",
    "POTASH_CONSUMPTION_(tons)",
    "TOTAL_FERTILISER_CONSUMPTION_(tons)",
    "GROSS_IRRIGATED_AREA_(1000_ha)",
    "Winter_JAN-FEB_MAXIMUM_TEMPERATURE_(Centigrate)",
    "Summer_MAR-MAY_MAXIMUM_TEMPERATURE_(Centigrate)",
    "Rainy_JUN-SEP_MAXIMUM_TEMPERATURE_(Centigrate)",
    "Autumn_OCT-DEC_MAXIMUM_TEMPERATURE_(Centigrate)",
    "Winter_JAN-FEB_MINIMUM_TEMPERATURE_(Centigrate)",
    "Summer_MAR-MAY_MINIMUM_TEMPERATURE_(Centigrate)",
    "Rainy_JUN-SEP_MINIMUM_TEMPERATURE_(Centigrate)",
    "Autumn_OCT-DEC_MINIMUM_TEMPERATURE_(Centigrate)",
    "Winter_JAN-FEB_PERCIPITATION_(Millimeters)",
    "Summer_MAR-MAY_PERCIPITATION_(Millimeters)",
    "Rainy_JUN-SEP_PERCIPITATION_(Millimeters)",
    "Autumn_OCT-DEC_PERCIPITATION_(Millimeters)",
    "Winter_JAN-FEB_ACTUAL_EVAPOTRANSPIRATION_(Millimeters)",
    "Summer_MAR-MAY_ACTUAL_EVAPOTRANSPIRATION_(Millimeters)",
    "Rainy_JUN-SEP_ACTUAL_EVAPOTRANSPIRATION_(Millimeters)",
    "Autumn_OCT-DEC_ACTUAL_EVAPOTRANSPIRATION_(Millimeters)",
    "Winter_JAN-FEB_WINDSPEED_(Meter_per_second)",
    "Summer_MAR-MAY_WINDSPEED_(Meter_per_second)",
    "Rainy_JUN-SEP_WINDSPEED_(Meter_per_second)",
    "Autumn_OCT-DEC_WINDSPEED_(Meter_per_second)",
    "NPK_per_ha",
    "IrrRatio",
    "NPK_per_ha_lag1",
    "IrrRatio_lag1",
    "GCA_lag1",
    "Winter_JAN-FEB_MAXIMUM_TEMPERATURE_(Centigrate)_normal",
    "Summer_MAR-MAY_MAXIMUM_TEMPERATURE_(Centigrate)_normal",
    "Rainy_JUN-SEP_MAXIMUM_TEMPERATURE_(Centigrate)_normal",
    "Autumn_OCT-DEC_MAXIMUM_TEMPERATURE_(Centigrate)_normal",
    "Winter_JAN-FEB_MINIMUM_TEMPERATURE_(Centigrate)_normal",
    "Summer_MAR-MAY_MINIMUM_TEMPERATURE_(Centigrate)_normal",
    "Rainy_JUN-SEP_MINIMUM_TEMPERATURE_(Centigrate)_normal",
    "Autumn_OCT-DEC_MINIMUM_TEMPERATURE_(Centigrate)_normal",
    "Winter_JAN-FEB_PERCIPITATION_(Millimeters)_normal",
    "Summer_MAR-MAY_PERCIPITATION_(Millimeters)_normal",
    "Rainy_JUN-SEP_PERCIPITATION_(Millimeters)_normal",
    "Autumn_OCT-DEC_PERCIPITATION_(Millimeters)_normal",
    "Winter_JAN-FEB_ACTUAL_EVAPOTRANSPIRATION_(Millimeters)_normal",
    "Summer_MAR-MAY_ACTUAL_EVAPOTRANSPIRATION_(Millimeters)_normal",
    "Rainy_JUN-SEP_ACTUAL_EVAPOTRANSPIRATION_(Millimeters)_normal",
    "Autumn_OCT-DEC_ACTUAL_EVAPOTRANSPIRATION_(Millimeters)_normal",
    "Winter_JAN-FEB_WINDSPEED_(Meter_per_second)_normal",
    "Summer_MAR-MAY_WINDSPEED_(Meter_per_second)_normal",
    "Rainy_JUN-SEP_WINDSPEED_(Meter_per_second)_normal",
    "Autumn_OCT-DEC_WINDSPEED_(Meter_per_second)_normal",
    "Winter_JAN-FEB_MAXIMUM_TEMPERATURE_(Centigrate)_anomaly",
    "Summer_MAR-MAY_MAXIMUM_TEMPERATURE_(Centigrate)_anomaly",
    "Rainy_JUN-SEP_MAXIMUM_TEMPERATURE_(Centigrate)_anomaly",
    "Autumn_OCT-DEC_MAXIMUM_TEMPERATURE_(Centigrate)_anomaly",
    "Winter_JAN-FEB_MINIMUM_TEMPERATURE_(Centigrate)_anomaly",
    "Summer_MAR-MAY_MINIMUM_TEMPERATURE_(Centigrate)_anomaly",
    "Rainy_JUN-SEP_MINIMUM_TEMPERATURE_(Centigrate)_anomaly",
    "Autumn_OCT-DEC_MINIMUM_TEMPERATURE_(Centigrate)_anomaly",
    "Winter_JAN-FEB_PERCIPITATION_(Millimeters)_anomaly",
    "Summer_MAR-MAY_PERCIPITATION_(Millimeters)_anomaly",
    "Rainy_JUN-SEP_PERCIPITATION_(Millimeters)_anomaly",
    "Autumn_OCT-DEC_PERCIPITATION_(Millimeters)_anomaly",
    "Winter_JAN-FEB_ACTUAL_EVAPOTRANSPIRATION_(Millimeters)_anomaly",
    "Summer_MAR-MAY_ACTUAL_EVAPOTRANSPIRATION_(Millimeters)_anomaly",
    "Rainy_JUN-SEP_ACTUAL_EVAPOTRANSPIRATION_(Millimeters)_anomaly",
    "Autumn_OCT-DEC_ACTUAL_EVAPOTRANSPIRATION_(Millimeters)_anomaly",
    "Winter_JAN-FEB_WINDSPEED_(Meter_per_second)_anomaly",
    "Summer_MAR-MAY_WINDSPEED_(Meter_per_second)_anomaly",
    "Rainy_JUN-SEP_WINDSPEED_(Meter_per_second)_anomaly",
    "Autumn_OCT-DEC_WINDSPEED_(Meter_per_second)_anomaly",
    "Winter_JAN-FEB_Aridity",
    "Summer_MAR-MAY_Aridity",
    "Rainy_JUN-SEP_Aridity",
    "Autumn_OCT-DEC_Aridity",
    "Winter_JAN-FEB_RainTemp",
    "Summer_MAR-MAY_RainTemp",
    "Rainy_JUN-SEP_RainTemp",
    "Autumn_OCT-DEC_RainTemp",
    "Winter_JAN-FEB_RainIrr",
    "Summer_MAR-MAY_RainIrr",
    "Rainy_JUN-SEP_RainIrr",
    "Autumn_OCT-DEC_RainIrr",
    "Winter_JAN-FEB_TempAridity",
    "Summer_MAR-MAY_TempAridity",
    "Rainy_JUN-SEP_TempAridity",
    "Autumn_OCT-DEC_TempAridity",
    "Area",
    "AreaShare",
    "Yield_lag1",
    "Yield_roll3",
    "Yield_roll5",
    "Yield_hist_mean",
    "AreaShare_lag1",
]

SEASONS = ["Winter", "Summer", "Rainy", "Autumn"]
SEASON_LABELS = {
    "Winter": "Winter_JAN-FEB",
    "Summer": "Summer_MAR-MAY",
    "Rainy": "Rainy_JUN-SEP",
    "Autumn": "Autumn_OCT-DEC",
}


class FeatureEngine:
    def __init__(self, historical_data: dict):
        self.data = historical_data  # {str(dist_code): {info, crops, annual:{str(year): ...}}}

    def _get_annual(self, dist_code: int, year: int) -> Optional[dict]:
        dc_str = str(dist_code)
        if dc_str not in self.data:
            return None
        annual_dict = self.data[dc_str]["annual"]
        y_str = str(year)
        if y_str in annual_dict:
            return annual_dict[y_str]

        available_years = sorted(int(k) for k in annual_dict.keys())
        if not available_years:
            return None

        latest_year = available_years[-1]
        if year > latest_year:
            # Current / Present season (e.g. 2026) or future projections
            latest_annual = annual_dict[str(latest_year)]
            projected = {
                "climate": {},
                "agriculture": dict(latest_annual["agriculture"]),
                "crops": dict(latest_annual.get("crops", {})),
            }
            # Maintain realistic climate baseline
            for season in SEASONS:
                projected["climate"][season] = dict(latest_annual["climate"].get(season, {}))
            return projected
        elif year < available_years[0]:
            return annual_dict[str(available_years[0])]

        return None

    def _compute_normals(self, dist_code: int, year: int) -> dict:
        """30-year (or available) historical mean per climate variable."""
        dc_str = str(dist_code)
        if dc_str not in self.data:
            return {}
        annual = self.data[dc_str]["annual"]
        available_years = sorted(int(k) for k in annual.keys())
        cutoff_year = min(year, available_years[-1] + 1)
        norm_years = [y for y in range(max(2001, cutoff_year - 30), cutoff_year) if str(y) in annual]
        normals = {}
        for season in SEASONS:
            sl = SEASON_LABELS[season]
            for var in ["max_temp", "min_temp", "precip", "et", "windspeed"]:
                vals = [annual[str(y)]["climate"][season][var] for y in norm_years
                        if season in annual[str(y)]["climate"]]
                normals[f"{sl}_{var}_normal"] = float(np.mean(vals)) if vals else 0.0
        return normals

    def _climate_flat(self, climate: dict) -> dict:
        """Flatten seasonal climate dict into named features."""
        out = {}
        for season in SEASONS:
            sl = SEASON_LABELS[season]
            sc = climate.get(season, {})
            out[f"{sl}_max_temp"] = sc.get("max_temp", 25.0)
            out[f"{sl}_min_temp"] = sc.get("min_temp", 15.0)
            out[f"{sl}_precip"] = sc.get("precip", 100.0)
            out[f"{sl}_et"] = sc.get("et", 80.0)
            out[f"{sl}_windspeed"] = sc.get("windspeed", 2.0)
        return out

    def _crop_history(
        self, dist_code: int, crop: str, year: int
    ) -> dict:
        """
        Compute crop-level historical features for given crop up to year-1.
        Returns yield_lag1, yield_roll3, yield_roll5, yield_hist_mean,
                area_share, area_share_lag1, area (for current year).
        """
        dc_str = str(dist_code)
        if dc_str not in self.data:
            return {}

        annual = self.data[dc_str]["annual"]
        crops_available = self.data[dc_str]["crops"]

        if crop not in crops_available:
            return {
                "Yield_lag1": 0.0, "Yield_roll3": 0.0, "Yield_roll5": 0.0,
                "Yield_hist_mean": 0.0, "AreaShare": 0.0, "AreaShare_lag1": 0.0, "Area": 0.0
            }

        available_years = sorted(int(k) for k in annual.keys())
        latest_avail = available_years[-1] if available_years else 2023

        def get_yield(y):
            eff_y = min(y, latest_avail)
            yr = annual.get(str(eff_y), {})
            return yr.get("crops", {}).get(crop, {}).get("yield", None)

        def get_area_share(y):
            eff_y = min(y, latest_avail)
            yr = annual.get(str(eff_y), {})
            return yr.get("crops", {}).get(crop, {}).get("area_share", None)

        def get_area(y):
            eff_y = min(y, latest_avail)
            yr = annual.get(str(eff_y), {})
            return yr.get("crops", {}).get(crop, {}).get("area", None)

        # Reference year for lags: if forecasting present (e.g. 2026), latest available harvest is reference
        ref_year = min(year - 1, latest_avail)

        lag1_yield = get_yield(ref_year) or 0.0

        roll3_vals = [v for v in [get_yield(ref_year - i) for i in range(0, 3)] if v is not None]
        roll3 = float(np.mean(roll3_vals)) if roll3_vals else lag1_yield

        roll5_vals = [v for v in [get_yield(ref_year - i) for i in range(0, 5)] if v is not None]
        roll5 = float(np.mean(roll5_vals)) if roll5_vals else roll3

        hist_vals = [v for y in available_years if (v := get_yield(y)) is not None]
        hist_mean = float(np.mean(hist_vals)) if hist_vals else roll5

        area_share = get_area_share(ref_year) or 0.0
        area_share_lag1 = get_area_share(ref_year - 1) or 0.0
        area = get_area(ref_year) or 0.0

        return {
            "Yield_lag1": lag1_yield,
            "Yield_roll3": roll3,
            "Yield_roll5": roll5,
            "Yield_hist_mean": hist_mean,
            "AreaShare": area_share,
            "AreaShare_lag1": area_share_lag1,
            "Area": area,
        }

    def build_feature_matrix(
        self,
        dist_code: int,
        year: int,
        crops: List[str],
        climate_override: Optional[dict] = None,
        ag_override: Optional[dict] = None,
    ) -> Tuple[pd.DataFrame, List[str]]:
        """
        Build N×95 feature matrix for all candidate crops.
        Returns (DataFrame with FEATURE_NAMES columns, list of crop names).
        """
        annual = self._get_annual(dist_code, year)
        prev_annual = self._get_annual(dist_code, year - 1)

        if annual is None:
            raise ValueError(f"No data for district {dist_code}, year {year}")

        ag = dict(annual["agriculture"])
        if ag_override:
            ag.update(ag_override)

        climate = dict(annual["climate"])
        if climate_override:
            # Deep merge season-level overrides
            for season, vals in climate_override.items():
                if season in climate:
                    climate[season] = {**climate[season], **vals}
                else:
                    climate[season] = vals

        prev_ag = prev_annual["agriculture"] if prev_annual else ag
        clim_flat = self._climate_flat(climate)
        normals = self._compute_normals(dist_code, year)

        dist_info = self.data[str(dist_code)]["info"]
        state_code = dist_info["state_code"]

        # Derived district-level features
        gca = ag["GCA"]
        total_fert = ag["total_fertiliser"]
        gia = ag["GIA"]
        npk_per_ha = total_fert / max(gca, 1.0)
        irr_ratio = gia / max(gca, 1.0)

        prev_gca = prev_ag.get("GCA", gca)
        prev_fert = prev_ag.get("total_fertiliser", total_fert)
        prev_gia = prev_ag.get("GIA", gia)
        npk_lag1 = prev_fert / max(prev_gca, 1.0)
        irr_lag1 = prev_gia / max(prev_gca, 1.0)

        rows = []
        for crop in crops:
            crop_h = self._crop_history(dist_code, crop, year)

            row = {}

            # Group 1 — Raw Agricultural
            row["State_Code"] = state_code
            row["GROSS_CROPPED_AREA_(1000_ha)"] = gca
            row["NITROGEN_CONSUMPTION_(tons)"] = ag["nitrogen"]
            row["PHOSPHATE_CONSUMPTION_(tons)"] = ag["phosphate"]
            row["POTASH_CONSUMPTION_(tons)"] = ag["potash"]
            row["TOTAL_FERTILISER_CONSUMPTION_(tons)"] = total_fert
            row["GROSS_IRRIGATED_AREA_(1000_ha)"] = gia

            # Group 2 — Seasonal Climate Raw
            for season in SEASONS:
                sl = SEASON_LABELS[season]
                row[f"{sl}_MAXIMUM_TEMPERATURE_(Centigrate)"] = clim_flat[f"{sl}_max_temp"]
                row[f"{sl}_MINIMUM_TEMPERATURE_(Centigrate)"] = clim_flat[f"{sl}_min_temp"]
                row[f"{sl}_PERCIPITATION_(Millimeters)"] = clim_flat[f"{sl}_precip"]
                row[f"{sl}_ACTUAL_EVAPOTRANSPIRATION_(Millimeters)"] = clim_flat[f"{sl}_et"]
                row[f"{sl}_WINDSPEED_(Meter_per_second)"] = clim_flat[f"{sl}_windspeed"]

            # Group 5 — Engineered Ag Ratios
            row["NPK_per_ha"] = npk_per_ha
            row["IrrRatio"] = irr_ratio
            row["NPK_per_ha_lag1"] = npk_lag1
            row["IrrRatio_lag1"] = irr_lag1
            row["GCA_lag1"] = prev_gca

            # Group 3 — Climate Normals
            for season in SEASONS:
                sl = SEASON_LABELS[season]
                row[f"{sl}_MAXIMUM_TEMPERATURE_(Centigrate)_normal"] = normals.get(f"{sl}_max_temp_normal", clim_flat[f"{sl}_max_temp"])
                row[f"{sl}_MINIMUM_TEMPERATURE_(Centigrate)_normal"] = normals.get(f"{sl}_min_temp_normal", clim_flat[f"{sl}_min_temp"])
                row[f"{sl}_PERCIPITATION_(Millimeters)_normal"] = normals.get(f"{sl}_precip_normal", clim_flat[f"{sl}_precip"])
                row[f"{sl}_ACTUAL_EVAPOTRANSPIRATION_(Millimeters)_normal"] = normals.get(f"{sl}_et_normal", clim_flat[f"{sl}_et"])
                row[f"{sl}_WINDSPEED_(Meter_per_second)_normal"] = normals.get(f"{sl}_windspeed_normal", clim_flat[f"{sl}_windspeed"])

            # Group 4 — Climate Anomalies (current - normal)
            for season in SEASONS:
                sl = SEASON_LABELS[season]
                for var_key, feat_suffix in [
                    ("max_temp", "MAXIMUM_TEMPERATURE_(Centigrate)"),
                    ("min_temp", "MINIMUM_TEMPERATURE_(Centigrate)"),
                    ("precip", "PERCIPITATION_(Millimeters)"),
                    ("et", "ACTUAL_EVAPOTRANSPIRATION_(Millimeters)"),
                    ("windspeed", "WINDSPEED_(Meter_per_second)"),
                ]:
                    curr = clim_flat[f"{sl}_{var_key}"]
                    norm = normals.get(f"{sl}_{var_key}_normal", curr)
                    row[f"{sl}_{feat_suffix}_anomaly"] = curr - norm

            # Group 6 — Aridity & Interaction Features
            for season in SEASONS:
                sl = SEASON_LABELS[season]
                precip = clim_flat[f"{sl}_precip"]
                et = max(clim_flat[f"{sl}_et"], 0.1)
                avg_temp = (clim_flat[f"{sl}_max_temp"] + clim_flat[f"{sl}_min_temp"]) / 2

                aridity = precip / et
                row[f"{sl}_Aridity"] = aridity
                row[f"{sl}_RainTemp"] = precip * avg_temp
                row[f"{sl}_RainIrr"] = precip * irr_ratio
                row[f"{sl}_TempAridity"] = avg_temp * aridity

            # Group 7 — Crop-Level Historical Features
            row["Area"] = crop_h["Area"]
            row["AreaShare"] = crop_h["AreaShare"]
            row["Yield_lag1"] = crop_h["Yield_lag1"]
            row["Yield_roll3"] = crop_h["Yield_roll3"]
            row["Yield_roll5"] = crop_h["Yield_roll5"]
            row["Yield_hist_mean"] = crop_h["Yield_hist_mean"]
            row["AreaShare_lag1"] = crop_h["AreaShare_lag1"]

            rows.append(row)

        df = pd.DataFrame(rows, columns=FEATURE_NAMES)
        return df, crops

    def get_climate_summary(self, dist_code: int, year: int) -> dict:
        annual = self._get_annual(dist_code, year)
        if not annual:
            return {}
        clim = annual["climate"]
        total_precip = sum(clim[s]["precip"] for s in SEASONS if s in clim)
        avg_max = np.mean([clim[s]["max_temp"] for s in SEASONS if s in clim])
        avg_min = np.mean([clim[s]["min_temp"] for s in SEASONS if s in clim])
        rainy_precip = clim.get("Rainy", {}).get("precip", 0)
        return {
            "total_annual_precip_mm": round(total_precip, 1),
            "avg_max_temp_c": round(float(avg_max), 1),
            "avg_min_temp_c": round(float(avg_min), 1),
            "monsoon_precip_mm": round(rainy_precip, 1),
            "irr_ratio": round(annual["agriculture"]["GIA"] / max(annual["agriculture"]["GCA"], 1), 3),
        }
