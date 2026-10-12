class District {
  final int distCode;
  final String distName;
  final String stateName;
  final int stateCode;
  final String zone;
  final double lat;
  final double lon;

  const District({
    required this.distCode,
    required this.distName,
    required this.stateName,
    required this.stateCode,
    required this.zone,
    required this.lat,
    required this.lon,
  });

  factory District.fromJson(Map<String, dynamic> json) => District(
        distCode: json['dist_code'] as int,
        distName: json['dist_name'] as String,
        stateName: json['state_name'] as String,
        stateCode: json['state_code'] as int,
        zone: json['zone'] as String? ?? 'unknown',
        lat: (json['lat'] as num).toDouble(),
        lon: (json['lon'] as num).toDouble(),
      );

  @override
  String toString() => '$distName, $stateName';
}

class CropRank {
  final int rank;
  final String crop;
  final double score;
  final double confidence;
  final double? yieldLag1;
  final double? yieldHistMean;
  final double? areaShare;

  const CropRank({
    required this.rank,
    required this.crop,
    required this.score,
    required this.confidence,
    this.yieldLag1,
    this.yieldHistMean,
    this.areaShare,
  });

  factory CropRank.fromJson(Map<String, dynamic> json) => CropRank(
        rank: json['rank'] as int,
        crop: json['crop'] as String,
        score: (json['score'] as num).toDouble(),
        confidence: (json['confidence'] as num).toDouble(),
        yieldLag1: json['yield_lag1'] != null
            ? (json['yield_lag1'] as num).toDouble()
            : null,
        yieldHistMean: json['yield_hist_mean'] != null
            ? (json['yield_hist_mean'] as num).toDouble()
            : null,
        areaShare: json['area_share'] != null
            ? (json['area_share'] as num).toDouble()
            : null,
      );
}

class FeatureInfluence {
  final String featureGroup;
  final String displayName;
  final String direction;
  final String magnitude;

  const FeatureInfluence({
    required this.featureGroup,
    required this.displayName,
    required this.direction,
    required this.magnitude,
  });

  factory FeatureInfluence.fromJson(Map<String, dynamic> json) =>
      FeatureInfluence(
        featureGroup: json['feature_group'] as String,
        displayName: json['display_name'] as String,
        direction: json['direction'] as String,
        magnitude: json['magnitude'] as String,
      );
}

class RecommendationResult {
  final int districtId;
  final String districtName;
  final String stateName;
  final int year;
  final String topCrop;
  final double topConfidence;
  final List<CropRank> rankings;
  final String explanation;
  final List<FeatureInfluence> featureInfluences;
  final Map<String, dynamic> climateSummary;
  final bool modelLoaded;

  const RecommendationResult({
    required this.districtId,
    required this.districtName,
    required this.stateName,
    required this.year,
    required this.topCrop,
    required this.topConfidence,
    required this.rankings,
    required this.explanation,
    required this.featureInfluences,
    required this.climateSummary,
    required this.modelLoaded,
  });

  factory RecommendationResult.fromJson(Map<String, dynamic> json) =>
      RecommendationResult(
        districtId: json['district_id'] as int,
        districtName: json['district_name'] as String,
        stateName: json['state_name'] as String,
        year: json['year'] as int,
        topCrop: json['top_crop'] as String,
        topConfidence: (json['top_confidence'] as num).toDouble(),
        rankings: (json['rankings'] as List)
            .map((e) => CropRank.fromJson(e as Map<String, dynamic>))
            .toList(),
        explanation: json['explanation'] as String,
        featureInfluences: (json['feature_influences'] as List)
            .map((e) => FeatureInfluence.fromJson(e as Map<String, dynamic>))
            .toList(),
        climateSummary:
            Map<String, dynamic>.from(json['climate_summary'] as Map),
        modelLoaded: json['model_loaded'] as bool,
      );
}

class ScenarioRankItem {
  final int rank;
  final String crop;
  final double confidence;
  final double change;

  const ScenarioRankItem({
    required this.rank,
    required this.crop,
    required this.confidence,
    required this.change,
  });

  factory ScenarioRankItem.fromJson(Map<String, dynamic> json) =>
      ScenarioRankItem(
        rank: json['rank'] as int,
        crop: json['crop'] as String,
        confidence: (json['confidence'] as num).toDouble(),
        change: (json['change'] as num).toDouble(),
      );
}

class ScenarioResult {
  final int districtId;
  final String districtName;
  final int year;
  final String baselineTop;
  final String scenarioTop;
  final bool recommendationChanged;
  final List<ScenarioRankItem> baselineRankings;
  final List<ScenarioRankItem> scenarioRankings;
  final String explanation;
  final Map<String, double> scenarioParams;

  const ScenarioResult({
    required this.districtId,
    required this.districtName,
    required this.year,
    required this.baselineTop,
    required this.scenarioTop,
    required this.recommendationChanged,
    required this.baselineRankings,
    required this.scenarioRankings,
    required this.explanation,
    required this.scenarioParams,
  });

  factory ScenarioResult.fromJson(Map<String, dynamic> json) => ScenarioResult(
        districtId: json['district_id'] as int,
        districtName: json['district_name'] as String,
        year: json['year'] as int,
        baselineTop: json['baseline_top'] as String,
        scenarioTop: json['scenario_top'] as String,
        recommendationChanged: json['recommendation_changed'] as bool,
        baselineRankings: (json['baseline_rankings'] as List)
            .map((e) => ScenarioRankItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        scenarioRankings: (json['scenario_rankings'] as List)
            .map((e) => ScenarioRankItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        explanation: json['explanation'] as String,
        scenarioParams: Map<String, double>.from(
            (json['scenario_params'] as Map).map(
                (k, v) => MapEntry(k as String, (v as num).toDouble()))),
      );
}

class ClimateStats {
  final String season;
  final double avgMaxTemp;
  final double avgMinTemp;
  final double avgPrecip;
  final double avgEt;
  final double avgWindspeed;

  const ClimateStats({
    required this.season,
    required this.avgMaxTemp,
    required this.avgMinTemp,
    required this.avgPrecip,
    required this.avgEt,
    required this.avgWindspeed,
  });

  factory ClimateStats.fromJson(Map<String, dynamic> json) => ClimateStats(
        season: json['season'] as String,
        avgMaxTemp: (json['avg_max_temp'] as num).toDouble(),
        avgMinTemp: (json['avg_min_temp'] as num).toDouble(),
        avgPrecip: (json['avg_precip'] as num).toDouble(),
        avgEt: (json['avg_et'] as num).toDouble(),
        avgWindspeed: (json['avg_windspeed'] as num).toDouble(),
      );
}

class CropTrend {
  final String crop;
  final List<int> years;
  final List<double> yields;
  final List<double> areas;
  final List<double> areaShares;

  const CropTrend({
    required this.crop,
    required this.years,
    required this.yields,
    required this.areas,
    required this.areaShares,
  });

  factory CropTrend.fromJson(Map<String, dynamic> json) => CropTrend(
        crop: json['crop'] as String,
        years: (json['years'] as List).map((e) => e as int).toList(),
        yields: (json['yields'] as List).map((e) => (e as num).toDouble()).toList(),
        areas: (json['areas'] as List).map((e) => (e as num).toDouble()).toList(),
        areaShares:
            (json['area_shares'] as List).map((e) => (e as num).toDouble()).toList(),
      );
}

class DistrictAnalytics {
  final int districtId;
  final String districtName;
  final String stateName;
  final double lat;
  final double lon;
  final String climateZone;
  final List<int> availableYears;
  final List<String> crops;
  final List<ClimateStats> climateStats;
  final List<CropTrend> cropTrends;
  final Map<String, dynamic> agTrend;

  const DistrictAnalytics({
    required this.districtId,
    required this.districtName,
    required this.stateName,
    required this.lat,
    required this.lon,
    required this.climateZone,
    required this.availableYears,
    required this.crops,
    required this.climateStats,
    required this.cropTrends,
    required this.agTrend,
  });

  factory DistrictAnalytics.fromJson(Map<String, dynamic> json) =>
      DistrictAnalytics(
        districtId: json['district_id'] as int,
        districtName: json['district_name'] as String,
        stateName: json['state_name'] as String,
        lat: (json['lat'] as num).toDouble(),
        lon: (json['lon'] as num).toDouble(),
        climateZone: json['climate_zone'] as String,
        availableYears:
            (json['available_years'] as List).map((e) => e as int).toList(),
        crops: (json['crops'] as List).map((e) => e as String).toList(),
        climateStats: (json['climate_stats'] as List)
            .map((e) => ClimateStats.fromJson(e as Map<String, dynamic>))
            .toList(),
        cropTrends: (json['crop_trends'] as List)
            .map((e) => CropTrend.fromJson(e as Map<String, dynamic>))
            .toList(),
        agTrend: Map<String, dynamic>.from(json['ag_trend'] as Map),
      );
}
