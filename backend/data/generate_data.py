"""
AgriCAST Data Generator
Generates synthetic but realistic agricultural data for Indian districts.
Run once: python generate_data.py
"""
import json
import numpy as np
import os

np.random.seed(42)

DISTRICTS = [
    {"dist_code": 901, "dist_name": "Lucknow", "state_code": 9, "state_name": "Uttar Pradesh", "lat": 26.85, "lon": 80.95, "zone": "semi_arid"},
    {"dist_code": 902, "dist_name": "Kanpur Nagar", "state_code": 9, "state_name": "Uttar Pradesh", "lat": 26.45, "lon": 80.33, "zone": "semi_arid"},
    {"dist_code": 903, "dist_name": "Agra", "state_code": 9, "state_name": "Uttar Pradesh", "lat": 27.18, "lon": 78.01, "zone": "semi_arid"},
    {"dist_code": 904, "dist_name": "Prayagraj", "state_code": 9, "state_name": "Uttar Pradesh", "lat": 25.44, "lon": 81.84, "zone": "semi_arid"},
    {"dist_code": 905, "dist_name": "Varanasi", "state_code": 9, "state_name": "Uttar Pradesh", "lat": 25.32, "lon": 83.01, "zone": "semi_arid"},
    {"dist_code": 906, "dist_name": "Gorakhpur", "state_code": 9, "state_name": "Uttar Pradesh", "lat": 26.76, "lon": 83.37, "zone": "sub_humid"},
    {"dist_code": 907, "dist_name": "Meerut", "state_code": 9, "state_name": "Uttar Pradesh", "lat": 28.98, "lon": 77.71, "zone": "semi_arid"},
    {"dist_code": 908, "dist_name": "Bareilly", "state_code": 9, "state_name": "Uttar Pradesh", "lat": 28.37, "lon": 79.41, "zone": "sub_humid"},
    {"dist_code": 909, "dist_name": "Aligarh", "state_code": 9, "state_name": "Uttar Pradesh", "lat": 27.88, "lon": 78.08, "zone": "semi_arid"},
    {"dist_code": 910, "dist_name": "Moradabad", "state_code": 9, "state_name": "Uttar Pradesh", "lat": 28.84, "lon": 78.78, "zone": "sub_humid"},
    {"dist_code": 301, "dist_name": "Ludhiana", "state_code": 3, "state_name": "Punjab", "lat": 30.91, "lon": 75.85, "zone": "sub_humid"},
    {"dist_code": 302, "dist_name": "Amritsar", "state_code": 3, "state_name": "Punjab", "lat": 31.63, "lon": 74.87, "zone": "sub_humid"},
    {"dist_code": 303, "dist_name": "Jalandhar", "state_code": 3, "state_name": "Punjab", "lat": 31.33, "lon": 75.58, "zone": "sub_humid"},
    {"dist_code": 304, "dist_name": "Patiala", "state_code": 3, "state_name": "Punjab", "lat": 30.34, "lon": 76.39, "zone": "sub_humid"},
    {"dist_code": 305, "dist_name": "Bathinda", "state_code": 3, "state_name": "Punjab", "lat": 30.21, "lon": 74.95, "zone": "arid"},
    {"dist_code": 601, "dist_name": "Hisar", "state_code": 6, "state_name": "Haryana", "lat": 29.15, "lon": 75.72, "zone": "semi_arid"},
    {"dist_code": 602, "dist_name": "Rohtak", "state_code": 6, "state_name": "Haryana", "lat": 28.89, "lon": 76.60, "zone": "semi_arid"},
    {"dist_code": 603, "dist_name": "Karnal", "state_code": 6, "state_name": "Haryana", "lat": 29.69, "lon": 76.99, "zone": "sub_humid"},
    {"dist_code": 604, "dist_name": "Ambala", "state_code": 6, "state_name": "Haryana", "lat": 30.38, "lon": 76.78, "zone": "sub_humid"},
    {"dist_code": 801, "dist_name": "Jaipur", "state_code": 8, "state_name": "Rajasthan", "lat": 26.91, "lon": 75.79, "zone": "arid"},
    {"dist_code": 802, "dist_name": "Jodhpur", "state_code": 8, "state_name": "Rajasthan", "lat": 26.29, "lon": 73.02, "zone": "arid"},
    {"dist_code": 803, "dist_name": "Udaipur", "state_code": 8, "state_name": "Rajasthan", "lat": 24.58, "lon": 73.68, "zone": "semi_arid"},
    {"dist_code": 804, "dist_name": "Kota", "state_code": 8, "state_name": "Rajasthan", "lat": 25.18, "lon": 75.84, "zone": "semi_arid"},
    {"dist_code": 805, "dist_name": "Bikaner", "state_code": 8, "state_name": "Rajasthan", "lat": 28.01, "lon": 73.31, "zone": "arid"},
    {"dist_code": 2301, "dist_name": "Indore", "state_code": 23, "state_name": "Madhya Pradesh", "lat": 22.72, "lon": 75.86, "zone": "semi_arid"},
    {"dist_code": 2302, "dist_name": "Bhopal", "state_code": 23, "state_name": "Madhya Pradesh", "lat": 23.26, "lon": 77.41, "zone": "sub_humid"},
    {"dist_code": 2303, "dist_name": "Jabalpur", "state_code": 23, "state_name": "Madhya Pradesh", "lat": 23.18, "lon": 79.95, "zone": "sub_humid"},
    {"dist_code": 2304, "dist_name": "Gwalior", "state_code": 23, "state_name": "Madhya Pradesh", "lat": 26.22, "lon": 78.18, "zone": "semi_arid"},
    {"dist_code": 2305, "dist_name": "Ujjain", "state_code": 23, "state_name": "Madhya Pradesh", "lat": 23.17, "lon": 75.78, "zone": "semi_arid"},
    {"dist_code": 2701, "dist_name": "Pune", "state_code": 27, "state_name": "Maharashtra", "lat": 18.52, "lon": 73.86, "zone": "tropical"},
    {"dist_code": 2702, "dist_name": "Nashik", "state_code": 27, "state_name": "Maharashtra", "lat": 19.99, "lon": 73.79, "zone": "tropical"},
    {"dist_code": 2703, "dist_name": "Nagpur", "state_code": 27, "state_name": "Maharashtra", "lat": 21.14, "lon": 79.09, "zone": "tropical"},
    {"dist_code": 2704, "dist_name": "Solapur", "state_code": 27, "state_name": "Maharashtra", "lat": 17.69, "lon": 75.90, "zone": "arid"},
    {"dist_code": 2705, "dist_name": "Aurangabad", "state_code": 27, "state_name": "Maharashtra", "lat": 19.88, "lon": 75.34, "zone": "semi_arid"},
    {"dist_code": 1001, "dist_name": "Patna", "state_code": 10, "state_name": "Bihar", "lat": 25.60, "lon": 85.12, "zone": "sub_humid"},
    {"dist_code": 1002, "dist_name": "Gaya", "state_code": 10, "state_name": "Bihar", "lat": 24.78, "lon": 85.01, "zone": "sub_humid"},
    {"dist_code": 1003, "dist_name": "Muzaffarpur", "state_code": 10, "state_name": "Bihar", "lat": 26.12, "lon": 85.39, "zone": "sub_humid"},
    {"dist_code": 1004, "dist_name": "Bhagalpur", "state_code": 10, "state_name": "Bihar", "lat": 25.24, "lon": 86.97, "zone": "sub_humid"},
    {"dist_code": 1901, "dist_name": "Bardhaman", "state_code": 19, "state_name": "West Bengal", "lat": 23.23, "lon": 87.86, "zone": "humid"},
    {"dist_code": 1902, "dist_name": "Murshidabad", "state_code": 19, "state_name": "West Bengal", "lat": 24.18, "lon": 88.27, "zone": "humid"},
    {"dist_code": 1903, "dist_name": "Hooghly", "state_code": 19, "state_name": "West Bengal", "lat": 22.90, "lon": 88.39, "zone": "humid"},
    {"dist_code": 2401, "dist_name": "Anand", "state_code": 24, "state_name": "Gujarat", "lat": 22.56, "lon": 72.93, "zone": "semi_arid"},
    {"dist_code": 2402, "dist_name": "Rajkot", "state_code": 24, "state_name": "Gujarat", "lat": 22.30, "lon": 70.80, "zone": "arid"},
    {"dist_code": 2403, "dist_name": "Vadodara", "state_code": 24, "state_name": "Gujarat", "lat": 22.31, "lon": 73.18, "zone": "semi_arid"},
    {"dist_code": 2404, "dist_name": "Surat", "state_code": 24, "state_name": "Gujarat", "lat": 21.17, "lon": 72.83, "zone": "tropical"},
    {"dist_code": 2901, "dist_name": "Dharwad", "state_code": 29, "state_name": "Karnataka", "lat": 15.46, "lon": 75.01, "zone": "tropical"},
    {"dist_code": 2902, "dist_name": "Mysore", "state_code": 29, "state_name": "Karnataka", "lat": 12.30, "lon": 76.65, "zone": "tropical"},
    {"dist_code": 2903, "dist_name": "Bellary", "state_code": 29, "state_name": "Karnataka", "lat": 15.14, "lon": 76.93, "zone": "arid"},
    {"dist_code": 2904, "dist_name": "Belagavi", "state_code": 29, "state_name": "Karnataka", "lat": 15.85, "lon": 74.50, "zone": "tropical"},
    {"dist_code": 3301, "dist_name": "Coimbatore", "state_code": 33, "state_name": "Tamil Nadu", "lat": 11.00, "lon": 76.97, "zone": "tropical"},
    {"dist_code": 3302, "dist_name": "Madurai", "state_code": 33, "state_name": "Tamil Nadu", "lat": 9.92, "lon": 78.12, "zone": "tropical"},
    {"dist_code": 3303, "dist_name": "Tirunelveli", "state_code": 33, "state_name": "Tamil Nadu", "lat": 8.73, "lon": 77.70, "zone": "tropical"},
    {"dist_code": 3304, "dist_name": "Salem", "state_code": 33, "state_name": "Tamil Nadu", "lat": 11.65, "lon": 78.15, "zone": "tropical"},
    {"dist_code": 2801, "dist_name": "Kurnool", "state_code": 28, "state_name": "Andhra Pradesh", "lat": 15.83, "lon": 78.05, "zone": "arid"},
    {"dist_code": 2802, "dist_name": "Guntur", "state_code": 28, "state_name": "Andhra Pradesh", "lat": 16.31, "lon": 80.44, "zone": "tropical"},
    {"dist_code": 2803, "dist_name": "Krishna", "state_code": 28, "state_name": "Andhra Pradesh", "lat": 16.61, "lon": 80.80, "zone": "tropical"},
]

CLIMATE_BASE = {
    "semi_arid": {
        "Winter": {"max_temp": 22.5, "min_temp": 7.5, "precip": 22.0, "et": 48.0, "windspeed": 2.1},
        "Summer": {"max_temp": 40.0, "min_temp": 25.0, "precip": 32.0, "et": 155.0, "windspeed": 3.2},
        "Rainy":  {"max_temp": 34.0, "min_temp": 26.0, "precip": 780.0, "et": 260.0, "windspeed": 2.6},
        "Autumn": {"max_temp": 28.0, "min_temp": 14.0, "precip": 52.0, "et": 88.0, "windspeed": 2.0},
    },
    "sub_humid": {
        "Winter": {"max_temp": 19.5, "min_temp": 5.5, "precip": 35.0, "et": 43.0, "windspeed": 1.9},
        "Summer": {"max_temp": 37.5, "min_temp": 22.0, "precip": 55.0, "et": 140.0, "windspeed": 2.9},
        "Rainy":  {"max_temp": 32.5, "min_temp": 25.0, "precip": 920.0, "et": 275.0, "windspeed": 2.4},
        "Autumn": {"max_temp": 26.0, "min_temp": 11.5, "precip": 68.0, "et": 78.0, "windspeed": 1.8},
    },
    "arid": {
        "Winter": {"max_temp": 25.0, "min_temp": 7.0, "precip": 10.0, "et": 62.0, "windspeed": 2.6},
        "Summer": {"max_temp": 43.5, "min_temp": 27.0, "precip": 15.0, "et": 205.0, "windspeed": 3.6},
        "Rainy":  {"max_temp": 36.5, "min_temp": 26.5, "precip": 340.0, "et": 195.0, "windspeed": 2.9},
        "Autumn": {"max_temp": 30.0, "min_temp": 11.0, "precip": 18.0, "et": 82.0, "windspeed": 2.3},
    },
    "humid": {
        "Winter": {"max_temp": 26.5, "min_temp": 12.5, "precip": 42.0, "et": 55.0, "windspeed": 1.6},
        "Summer": {"max_temp": 36.0, "min_temp": 24.0, "precip": 85.0, "et": 120.0, "windspeed": 2.1},
        "Rainy":  {"max_temp": 32.0, "min_temp": 27.0, "precip": 1450.0, "et": 285.0, "windspeed": 2.1},
        "Autumn": {"max_temp": 28.5, "min_temp": 17.5, "precip": 105.0, "et": 92.0, "windspeed": 1.6},
    },
    "tropical": {
        "Winter": {"max_temp": 30.5, "min_temp": 17.5, "precip": 28.0, "et": 72.0, "windspeed": 1.9},
        "Summer": {"max_temp": 38.5, "min_temp": 25.0, "precip": 65.0, "et": 162.0, "windspeed": 2.6},
        "Rainy":  {"max_temp": 32.0, "min_temp": 24.0, "precip": 780.0, "et": 252.0, "windspeed": 2.3},
        "Autumn": {"max_temp": 30.5, "min_temp": 19.5, "precip": 205.0, "et": 102.0, "windspeed": 1.9},
    },
}

AG_BASE = {
    "semi_arid": {"GCA": 900.0, "nitrogen": 130000, "phosphate": 50000, "potash": 22000, "GIA_ratio": 0.72},
    "sub_humid":  {"GCA": 870.0, "nitrogen": 112000, "phosphate": 43000, "potash": 20000, "GIA_ratio": 0.65},
    "arid":       {"GCA": 580.0, "nitrogen": 58000,  "phosphate": 21000, "potash": 7500,  "GIA_ratio": 0.32},
    "humid":      {"GCA": 1020.0,"nitrogen": 155000, "phosphate": 57000, "potash": 31000, "GIA_ratio": 0.55},
    "tropical":   {"GCA": 760.0, "nitrogen": 92000,  "phosphate": 36000, "potash": 15500, "GIA_ratio": 0.50},
}

CROPS_BY_ZONE = {
    "semi_arid": ["Wheat", "Rice", "Sugarcane", "Mustard", "Chickpea", "Lentil", "Maize", "Groundnut"],
    "sub_humid":  ["Rice", "Wheat", "Maize", "Sugarcane", "Chickpea", "Mustard", "Soybean", "Lentil"],
    "arid":       ["Millet", "Groundnut", "Mustard", "Chickpea", "Sorghum", "Cotton", "Wheat"],
    "humid":      ["Rice", "Maize", "Jute", "Wheat", "Mustard", "Potato", "Lentil"],
    "tropical":   ["Rice", "Sorghum", "Sugarcane", "Cotton", "Groundnut", "Chickpea", "Soybean", "Maize"],
}

CROP_BASE_YIELD = {
    "Rice": 2800.0, "Wheat": 3500.0, "Sugarcane": 65000.0,
    "Cotton": 460.0, "Groundnut": 1500.0, "Chickpea": 1100.0,
    "Maize": 2800.0, "Millet": 1200.0, "Sorghum": 1300.0,
    "Mustard": 1200.0, "Soybean": 1500.0, "Lentil": 900.0,
    "Jute": 2500.0, "Potato": 18000.0,
}

CROP_TREND = {
    "Rice": 18.0, "Wheat": 22.0, "Sugarcane": 250.0,
    "Cotton": 5.0, "Groundnut": 8.0, "Chickpea": 6.0,
    "Maize": 20.0, "Millet": 5.0, "Sorghum": 4.0,
    "Mustard": 7.0, "Soybean": 10.0, "Lentil": 4.0,
    "Jute": 12.0, "Potato": 80.0,
}

YEARS = list(range(2001, 2024))


def generate_climate_year(base, year, district_seed):
    """Generate climate data for a year with realistic variation."""
    rng = np.random.RandomState(district_seed * 10000 + year)
    climate = {}
    trend_factor = (year - 2001) * 0.02  # slight warming
    seasons = ["Winter", "Summer", "Rainy", "Autumn"]
    for season in seasons:
        b = base[season]
        climate[season] = {
            "max_temp": round(b["max_temp"] + trend_factor + rng.normal(0, 0.8), 2),
            "min_temp": round(b["min_temp"] + trend_factor * 0.7 + rng.normal(0, 0.7), 2),
            "precip": round(max(0, b["precip"] * (1 + rng.normal(0, 0.18))), 2),
            "et": round(max(10, b["et"] * (1 + rng.normal(0, 0.08))), 2),
            "windspeed": round(max(0.5, b["windspeed"] + rng.normal(0, 0.2)), 2),
        }
    return climate


def generate_ag_year(base_ag, year, district_seed):
    """Generate district-level agricultural data for a year."""
    rng = np.random.RandomState(district_seed * 20000 + year)
    trend = (year - 2001) * 0.012
    gca = round(base_ag["GCA"] * (1 + trend + rng.normal(0, 0.03)), 2)
    irr_ratio = min(0.95, base_ag["GIA_ratio"] * (1 + trend * 0.5 + rng.normal(0, 0.02)))
    gia = round(gca * irr_ratio, 2)
    n_scale = 1 + trend * 1.5 + rng.normal(0, 0.04)
    return {
        "GCA": gca,
        "nitrogen": round(base_ag["nitrogen"] * n_scale),
        "phosphate": round(base_ag["phosphate"] * (1 + trend + rng.normal(0, 0.04))),
        "potash": round(base_ag["potash"] * (1 + trend + rng.normal(0, 0.04))),
        "total_fertiliser": round(base_ag["nitrogen"] * n_scale +
                                  base_ag["phosphate"] * (1 + trend) +
                                  base_ag["potash"] * (1 + trend)),
        "GIA": gia,
    }


def generate_crop_data(district, crops, all_ag, years):
    """Generate per-crop data using area shares."""
    dist_seed = district["dist_code"]
    rng = np.random.RandomState(dist_seed * 30000)
    n_crops = len(crops)

    # Generate stable base area shares for each crop
    raw_shares = rng.dirichlet(np.ones(n_crops) * 2.5)
    # Primary crops (first 3) get more area
    raw_shares[:min(3, n_crops)] *= 2
    raw_shares /= raw_shares.sum()

    crop_data = {crop: {} for crop in crops}

    for year in years:
        ag = all_ag[year]
        gca = ag["GCA"]
        year_rng = np.random.RandomState(dist_seed * 40000 + year)

        # Small year-to-year shift in shares
        shares = raw_shares + year_rng.normal(0, 0.015, n_crops)
        shares = np.clip(shares, 0.01, None)
        shares /= shares.sum()

        for i, crop in enumerate(crops):
            area = round(gca * shares[i], 3)
            trend = CROP_TREND[crop] * (year - 2001)
            noise = year_rng.normal(0, CROP_BASE_YIELD[crop] * 0.10)
            yield_val = round(max(50, CROP_BASE_YIELD[crop] + trend + noise), 2)
            crop_data[crop][year] = {
                "area": area,
                "yield": yield_val,
                "area_share": round(float(shares[i]), 5),
            }

    return crop_data


def main():
    out_dir = os.path.dirname(os.path.abspath(__file__))

    all_data = {}

    for dist in DISTRICTS:
        dc = dist["dist_code"]
        zone = dist["zone"]
        base_clim = CLIMATE_BASE[zone]
        base_ag = AG_BASE[zone]
        crops = CROPS_BY_ZONE[zone]

        # Generate agricultural data for all years
        all_ag = {y: generate_ag_year(base_ag, y, dc) for y in YEARS}

        # Generate climate data for all years
        all_clim = {y: generate_climate_year(base_clim, y, dc) for y in YEARS}

        # Generate crop data
        crop_hist = generate_crop_data(dist, crops, all_ag, YEARS)

        all_data[dc] = {
            "info": dist,
            "crops": crops,
            "annual": {}
        }

        for y in YEARS:
            all_data[dc]["annual"][y] = {
                "agriculture": all_ag[y],
                "climate": all_clim[y],
                "crops": {crop: crop_hist[crop][y] for crop in crops},
            }

    # Save districts list
    districts_out = [d["info"] for d in all_data.values()]
    with open(os.path.join(out_dir, "districts.json"), "w") as f:
        json.dump(districts_out, f, indent=2)
    print(f"Saved {len(districts_out)} districts.")

    # Save full historical data
    # Convert int keys to strings for JSON
    hist_out = {}
    for dc, ddata in all_data.items():
        hist_out[str(dc)] = {
            "info": ddata["info"],
            "crops": ddata["crops"],
            "annual": {str(y): v for y, v in ddata["annual"].items()}
        }

    with open(os.path.join(out_dir, "historical_data.json"), "w") as f:
        json.dump(hist_out, f, indent=2)
    print(f"Saved historical data for {len(hist_out)} districts × {len(YEARS)} years.")


if __name__ == "__main__":
    main()
