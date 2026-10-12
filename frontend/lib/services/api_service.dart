import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  // ── Districts ─────────────────────────────────────────────
  static Future<List<District>> fetchDistricts() async {
    final res = await http.get(Uri.parse('$baseUrl/api/districts'));
    _checkStatus(res);
    final List<dynamic> json = jsonDecode(res.body);
    return json.map((e) => District.fromJson(e as Map<String, dynamic>)).toList();
  }

  // ── Recommendation ────────────────────────────────────────
  static Future<RecommendationResult> getRecommendation({
    required int districtId,
    required int year,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/recommend'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'district_id': districtId, 'year': year}),
    );
    _checkStatus(res);
    return RecommendationResult.fromJson(
        jsonDecode(res.body) as Map<String, dynamic>);
  }

  // ── Scenario ──────────────────────────────────────────────
  static Future<ScenarioResult> runScenario({
    required int districtId,
    required int year,
    required double rainfallChange,
    required double temperatureChange,
    required double irrigationChange,
    required double fertilizerChange,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/scenario'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'district_id': districtId,
        'year': year,
        'rainfall_change': rainfallChange,
        'temperature_change': temperatureChange,
        'irrigation_change': irrigationChange,
        'fertilizer_change': fertilizerChange,
      }),
    );
    _checkStatus(res);
    return ScenarioResult.fromJson(
        jsonDecode(res.body) as Map<String, dynamic>);
  }

  // ── District Analytics ────────────────────────────────────
  static Future<DistrictAnalytics> getDistrictAnalytics(int districtId) async {
    final res =
        await http.get(Uri.parse('$baseUrl/api/district/$districtId'));
    _checkStatus(res);
    return DistrictAnalytics.fromJson(
        jsonDecode(res.body) as Map<String, dynamic>);
  }

  // ── Report URL & Download ─────────────────────────────────
  static String reportDownloadUrl(int districtId, int year, {bool includeScenario = false}) =>
      '$baseUrl/api/report/download?district_id=$districtId&year=$year&include_scenario=$includeScenario';

  static Future<Uint8List> fetchReportBytes({
    required int districtId,
    required int year,
    bool includeScenario = false,
  }) async {
    final url = reportDownloadUrl(districtId, year, includeScenario: includeScenario);
    final res = await http.get(Uri.parse(url));
    if (res.statusCode >= 400) {
      throw ApiException(statusCode: res.statusCode, message: 'Failed to generate PDF report');
    }
    return res.bodyBytes;
  }

  // ── Health ────────────────────────────────────────────────
  static Future<Map<String, dynamic>> health() async {
    final res = await http.get(Uri.parse('$baseUrl/health'));
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  static void _checkStatus(http.Response res) {
    if (res.statusCode >= 400) {
      final body = jsonDecode(res.body);
      throw ApiException(
        statusCode: res.statusCode,
        message: body['detail']?.toString() ?? 'Request failed',
      );
    }
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException($statusCode): $message';
}
