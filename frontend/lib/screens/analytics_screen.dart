import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/theme.dart';
import '../providers/app_state.dart';
import '../models/models.dart';
import '../widgets/common_widgets.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String? _selectedCrop;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // District Picker
          _DistrictPicker(
            districts: state.districts,
            selected: state.selectedDistrict,
            onSelect: (d) {
              state.selectDistrict(d);
              if (d != null) state.loadAnalytics(d.distCode);
              setState(() => _selectedCrop = null);
            },
          ),
          const SizedBox(height: 20),

          if (state.loadingAnalytics)
            const LoadingOverlay(message: 'Loading district analytics...')
          else if (state.analytics != null)
            _AnalyticsContent(
              analytics: state.analytics!,
              selectedCrop: _selectedCrop,
              onCropSelected: (c) => setState(() => _selectedCrop = c),
            )
          else
            _EmptyPicker(),
        ],
      ),
    );
  }
}

class _DistrictPicker extends StatelessWidget {
  final List<District> districts;
  final District? selected;
  final ValueChanged<District?> onSelect;
  const _DistrictPicker({required this.districts, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      child: Row(
        children: [
          const Icon(Icons.analytics_outlined, color: AgriCastTheme.primaryMed, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('District Analytics', style: GoogleFonts.inter(
                    fontSize: 18, fontWeight: FontWeight.w600)),
                Text('Historical agricultural and climate profile',
                    style: GoogleFonts.inter(fontSize: 12, color: AgriCastTheme.textMuted)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 260,
            child: DropdownButtonFormField<District>(
              value: selected,
              hint: Text('Select district', style: GoogleFonts.inter(fontSize: 13)),
              decoration: const InputDecoration(),
              items: districts.map((d) => DropdownMenuItem(
                value: d,
                child: Text('${d.distName}, ${d.stateName}',
                    style: GoogleFonts.inter(fontSize: 13)),
              )).toList(),
              onChanged: onSelect,
              isExpanded: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyPicker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          children: [
            Icon(Icons.map_outlined, size: 64, color: AgriCastTheme.borderGreen),
            const SizedBox(height: 16),
            Text('Select a District', style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('Choose a district above to view historical analytics.',
                style: GoogleFonts.inter(fontSize: 13, color: AgriCastTheme.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _AnalyticsContent extends StatelessWidget {
  final DistrictAnalytics analytics;
  final String? selectedCrop;
  final ValueChanged<String?> onCropSelected;
  const _AnalyticsContent({required this.analytics, required this.selectedCrop, required this.onCropSelected});

  @override
  Widget build(BuildContext context) {
    final activeCropTrend = selectedCrop != null
        ? analytics.cropTrends.firstWhere((t) => t.crop == selectedCrop,
            orElse: () => analytics.cropTrends.first)
        : analytics.cropTrends.isNotEmpty
            ? analytics.cropTrends.first
            : null;

    return Column(
      children: [
        // Summary row
        _SummaryRow(analytics: analytics).animate().fadeIn(duration: 500.ms),
        const SizedBox(height: 20),

        // Climate stats
        InfoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(title: 'Seasonal Climate Profile',
                  subtitle: 'Multi-year averages across all seasons'),
              const SizedBox(height: 16),
              _ClimateStatsTable(stats: analytics.climateStats),
            ],
          ),
        ).animate().fadeIn(delay: 100.ms, duration: 500.ms),
        const SizedBox(height: 20),

        // Crop selector + yield chart
        InfoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: SectionHeader(title: 'Crop Yield Trends',
                        subtitle: 'Historical yield in kg/ha per year'),
                  ),
                  DropdownButton<String>(
                    value: selectedCrop ?? (analytics.cropTrends.isNotEmpty ? analytics.cropTrends.first.crop : null),
                    underline: const SizedBox(),
                    style: GoogleFonts.inter(fontSize: 13, color: AgriCastTheme.textPrimary),
                    items: analytics.cropTrends.map((t) => DropdownMenuItem(
                      value: t.crop,
                      child: Text(t.crop),
                    )).toList(),
                    onChanged: onCropSelected,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (activeCropTrend != null)
                _YieldLineChart(trend: activeCropTrend)
              else
                const Center(child: Text('No crop data available')),
            ],
          ),
        ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
        const SizedBox(height: 20),

        // Agricultural trends
        InfoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(title: 'Agricultural Trends',
                  subtitle: 'GCA, GIA and fertiliser usage over the years'),
              const SizedBox(height: 16),
              _AgTrendChart(agTrend: analytics.agTrend),
            ],
          ),
        ).animate().fadeIn(delay: 300.ms, duration: 500.ms),

        const SizedBox(height: 20),

        // Crop area share
        InfoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(title: 'Crop Portfolio', subtitle: 'Area share distribution across crops'),
              const SizedBox(height: 16),
              _CropAreaPie(cropTrends: analytics.cropTrends),
            ],
          ),
        ).animate().fadeIn(delay: 400.ms, duration: 500.ms),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final DistrictAnalytics analytics;
  const _SummaryRow({required this.analytics});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 14,
      runSpacing: 14,
      children: [
        StatCard(
          label: 'Available Crops',
          value: '${analytics.crops.length}',
          icon: Icons.agriculture_rounded,
        ),
        StatCard(
          label: 'Data Years',
          value: '${analytics.availableYears.length}',
          subValue: '${analytics.availableYears.first}–${analytics.availableYears.last}',
          icon: Icons.calendar_today_outlined,
        ),
        StatCard(
          label: 'Climate Zone',
          value: analytics.climateZone.replaceAll('_', ' ').split(' ')
              .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
              .join(' '),
          icon: Icons.cloud_outlined,
        ),
        StatCard(
          label: 'Location',
          value: '${analytics.lat.toStringAsFixed(2)}°N',
          subValue: '${analytics.lon.toStringAsFixed(2)}°E',
          icon: Icons.location_on_outlined,
        ),
      ],
    );
  }
}

class _ClimateStatsTable extends StatelessWidget {
  final List<ClimateStats> stats;
  const _ClimateStatsTable({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder.all(color: AgriCastTheme.border, width: 0.5),
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1.5),
        2: FlexColumnWidth(1.5),
        3: FlexColumnWidth(1.5),
      },
      children: [
        TableRow(
          decoration: const BoxDecoration(color: AgriCastTheme.surface),
          children: ['Season', 'Max Temp (°C)', 'Rainfall (mm)', 'Wind (m/s)']
              .map((h) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Text(h,
                        style: GoogleFonts.inter(
                            fontSize: 12, fontWeight: FontWeight.w600,
                            color: AgriCastTheme.textSecondary)),
                  ))
              .toList(),
        ),
        ...stats.map((s) => TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Text(s.season, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Text('${s.avgMaxTemp.toStringAsFixed(1)} / ${s.avgMinTemp.toStringAsFixed(1)}',
                  style: GoogleFonts.inter(fontSize: 12)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Text(s.avgPrecip.toStringAsFixed(0),
                  style: GoogleFonts.inter(fontSize: 12)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Text(s.avgWindspeed.toStringAsFixed(1),
                  style: GoogleFonts.inter(fontSize: 12)),
            ),
          ],
        )),
      ],
    );
  }
}

class _YieldLineChart extends StatelessWidget {
  final CropTrend trend;
  const _YieldLineChart({required this.trend});

  @override
  Widget build(BuildContext context) {
    if (trend.years.isEmpty) return const Text('No data');
    final minY = trend.yields.reduce((a, b) => a < b ? a : b);
    final maxY = trend.yields.reduce((a, b) => a > b ? a : b);
    final padding = (maxY - minY) * 0.1;

    return SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            drawHorizontalLine: true,
            getDrawingHorizontalLine: (_) => FlLine(color: AgriCastTheme.border, strokeWidth: 1),
            drawVerticalLine: false,
          ),
          borderData: FlBorderData(show: false),
          minY: minY - padding,
          maxY: maxY + padding,
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50,
                getTitlesWidget: (val, _) => Text(
                  val.toStringAsFixed(0),
                  style: GoogleFonts.inter(fontSize: 9, color: AgriCastTheme.textMuted),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                interval: 4,
                getTitlesWidget: (val, _) {
                  final idx = val.toInt();
                  if (idx >= 0 && idx < trend.years.length) {
                    return Text(trend.years[idx].toString(),
                        style: GoogleFonts.inter(fontSize: 9, color: AgriCastTheme.textMuted));
                  }
                  return const SizedBox();
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: trend.yields.asMap().entries
                  .map((e) => FlSpot(e.key.toDouble(), e.value))
                  .toList(),
              isCurved: true,
              color: AgriCastTheme.primary,
              barWidth: 2.5,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: AgriCastTheme.primary.withValues(alpha: 0.08),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (spots) => spots.map((s) {
                final idx = s.x.toInt();
                final year = idx < trend.years.length ? trend.years[idx] : 0;
                return LineTooltipItem(
                  '$year\n${s.y.toStringAsFixed(0)} kg/ha',
                  GoogleFonts.inter(fontSize: 11, color: Colors.white),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class _AgTrendChart extends StatelessWidget {
  final Map<String, dynamic> agTrend;
  const _AgTrendChart({required this.agTrend});

  @override
  Widget build(BuildContext context) {
    final years = (agTrend['years'] as List).cast<int>();
    final gca = (agTrend['gca_1000ha'] as List).cast<double>();
    final gia = (agTrend['gia_1000ha'] as List).cast<double>();

    if (years.isEmpty) return const Text('No data');

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            drawHorizontalLine: true,
            getDrawingHorizontalLine: (_) => FlLine(color: AgriCastTheme.border, strokeWidth: 1),
            drawVerticalLine: false,
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 44,
                getTitlesWidget: (val, _) => Text(
                  val.toStringAsFixed(0),
                  style: GoogleFonts.inter(fontSize: 9, color: AgriCastTheme.textMuted),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                interval: 4,
                getTitlesWidget: (val, _) {
                  final idx = val.toInt();
                  if (idx >= 0 && idx < years.length) {
                    return Text(years[idx].toString(),
                        style: GoogleFonts.inter(fontSize: 9, color: AgriCastTheme.textMuted));
                  }
                  return const SizedBox();
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          lineBarsData: [
            _line(gca, AgriCastTheme.primary),
            _line(gia, AgriCastTheme.accent),
          ],
        ),
      ),
    );
  }

  LineChartBarData _line(List<double> data, Color color) {
    return LineChartBarData(
      spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
      isCurved: true,
      color: color,
      barWidth: 2,
      dotData: const FlDotData(show: false),
    );
  }
}

class _CropAreaPie extends StatelessWidget {
  final List<CropTrend> cropTrends;
  const _CropAreaPie({required this.cropTrends});

  @override
  Widget build(BuildContext context) {
    if (cropTrends.isEmpty) return const Text('No data');
    final lastShares = cropTrends.map((t) => (t.crop, t.areaShares.isNotEmpty ? t.areaShares.last : 0.0)).toList();
    final total = lastShares.fold<double>(0, (s, e) => s + e.$2);

    return SizedBox(
      height: 200,
      child: Row(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sections: lastShares.asMap().entries.map((e) {
                  final color = AgriCastTheme.chartColors[e.key % AgriCastTheme.chartColors.length];
                  return PieChartSectionData(
                    value: e.value.$2,
                    color: color,
                    title: '',
                    radius: 70,
                  );
                }).toList(),
                sectionsSpace: 2,
                centerSpaceRadius: 30,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: ListView.builder(
              itemCount: lastShares.length,
              itemBuilder: (_, i) {
                final color = AgriCastTheme.chartColors[i % AgriCastTheme.chartColors.length];
                final pct = total > 0 ? lastShares[i].$2 / total * 100 : 0.0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Container(width: 10, height: 10,
                          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Expanded(child: Text(lastShares[i].$1,
                          style: GoogleFonts.inter(fontSize: 11))),
                      Text('${pct.toStringAsFixed(1)}%',
                          style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600,
                              color: AgriCastTheme.textGreen)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
