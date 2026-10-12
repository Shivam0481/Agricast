import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';

enum AppScreen { landing, dashboard, scenario, analytics, reports, about }

class AppState extends ChangeNotifier {
  // Navigation
  AppScreen _currentScreen = AppScreen.landing;
  AppScreen get currentScreen => _currentScreen;

  void navigateTo(AppScreen screen) {
    _currentScreen = screen;
    notifyListeners();
  }

  // Districts
  List<District> _districts = [];
  List<District> get districts => _districts;
  bool _loadingDistricts = false;
  bool get loadingDistricts => _loadingDistricts;

  District? _selectedDistrict;
  District? get selectedDistrict => _selectedDistrict;

  void selectDistrict(District? d) {
    _selectedDistrict = d;
    notifyListeners();
  }

  int _selectedYear = 2026;
  int get selectedYear => _selectedYear;

  void selectYear(int y) {
    _selectedYear = y;
    notifyListeners();
  }

  Future<void> loadDistricts() async {
    if (_districts.isNotEmpty) return;
    _loadingDistricts = true;
    notifyListeners();
    try {
      _districts = await ApiService.fetchDistricts();
      _districts.sort((a, b) => a.distName.compareTo(b.distName));
    } catch (e) {
      debugPrint('Error loading districts: $e');
    }
    _loadingDistricts = false;
    notifyListeners();
  }

  // Recommendation
  RecommendationResult? _recommendation;
  RecommendationResult? get recommendation => _recommendation;
  bool _loadingRec = false;
  bool get loadingRec => _loadingRec;
  String? _recError;
  String? get recError => _recError;

  Future<void> getRecommendation() async {
    if (_selectedDistrict == null) return;
    _loadingRec = true;
    _recError = null;
    notifyListeners();
    try {
      _recommendation = await ApiService.getRecommendation(
        districtId: _selectedDistrict!.distCode,
        year: _selectedYear,
      );
      _currentScreen = AppScreen.dashboard;
    } catch (e) {
      _recError = e is ApiException ? e.message : e.toString();
    }
    _loadingRec = false;
    notifyListeners();
  }

  // Scenario
  double rainfallChange = 0;
  double temperatureChange = 0;
  double irrigationChange = 0;
  double fertilizerChange = 0;

  void updateScenarioParams({
    double? rainfall,
    double? temperature,
    double? irrigation,
    double? fertilizer,
  }) {
    if (rainfall != null) rainfallChange = rainfall;
    if (temperature != null) temperatureChange = temperature;
    if (irrigation != null) irrigationChange = irrigation;
    if (fertilizer != null) fertilizerChange = fertilizer;
    notifyListeners();
  }

  void resetScenario() {
    rainfallChange = 0;
    temperatureChange = 0;
    irrigationChange = 0;
    fertilizerChange = 0;
    notifyListeners();
  }

  ScenarioResult? _scenarioResult;
  ScenarioResult? get scenarioResult => _scenarioResult;
  bool _loadingScenario = false;
  bool get loadingScenario => _loadingScenario;
  String? _scenarioError;
  String? get scenarioError => _scenarioError;

  Future<void> runScenario() async {
    if (_selectedDistrict == null) return;
    _loadingScenario = true;
    _scenarioError = null;
    notifyListeners();
    try {
      _scenarioResult = await ApiService.runScenario(
        districtId: _selectedDistrict!.distCode,
        year: _selectedYear,
        rainfallChange: rainfallChange,
        temperatureChange: temperatureChange,
        irrigationChange: irrigationChange,
        fertilizerChange: fertilizerChange,
      );
    } catch (e) {
      _scenarioError = e is ApiException ? e.message : e.toString();
    }
    _loadingScenario = false;
    notifyListeners();
  }

  // District Analytics
  DistrictAnalytics? _analytics;
  DistrictAnalytics? get analytics => _analytics;
  bool _loadingAnalytics = false;
  bool get loadingAnalytics => _loadingAnalytics;

  Future<void> loadAnalytics(int districtId) async {
    _loadingAnalytics = true;
    notifyListeners();
    try {
      _analytics = await ApiService.getDistrictAnalytics(districtId);
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
    _loadingAnalytics = false;
    notifyListeners();
  }

  // Reset
  void reset() {
    _recommendation = null;
    _scenarioResult = null;
    _analytics = null;
    _recError = null;
    _scenarioError = null;
    notifyListeners();
  }
}
