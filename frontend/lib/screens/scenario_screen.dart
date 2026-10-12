import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/theme.dart';
import '../providers/app_state.dart';
import '../models/models.dart';
import '../widgets/common_widgets.dart';
import 'dashboard_screen.dart' show StringExt;

class ScenarioScreen extends StatelessWidget {
  const ScenarioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Scenario Analysis',
                    style: GoogleFonts.inter(
                        fontSize: 20, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(
                    'Evaluate how hypothetical climate and agricultural changes alter crop recommendations.',
                    style: GoogleFonts.inter(
                        fontSize: 13, color: AgriCastTheme.textSecondary)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          LayoutBuilder(builder: (_, constraints) {
            final isWide = constraints.maxWidth > 760;
            final sliders = _SliderPanel();
            final results = state.loadingScenario
                ? const LoadingOverlay(message: 'Running scenario analysis...')
                : state.scenarioError != null
                    ? ErrorBanner(message: state.scenarioError!)
                    : state.scenarioResult != null
                        ? _ScenarioResults(result: state.scenarioResult!)
                        : _ScenarioPlaceholder();

            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 320, child: sliders),
                  const SizedBox(width: 20),
                  Expanded(child: results),
                ],
              );
            }
            return Column(children: [
              sliders,
              const SizedBox(height: 20),
              results,
            ]);
          }),
        ],
      ),
    );
  }
}

class _SliderPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Scenario Parameters',
              style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          if (state.selectedDistrict != null)
            Text('${state.selectedDistrict!.distName} · Present Season ${state.selectedYear}',
                style: GoogleFonts.inter(fontSize: 12, color: AgriCastTheme.primaryMed, fontWeight: FontWeight.w500))
          else
            Text('Select a district on the Dashboard first',
                style: GoogleFonts.inter(fontSize: 12, color: AgriCastTheme.warning)),
          const SizedBox(height: 20),
          _ScenarioSlider(
            label: 'Rainfall Change',
            icon: Icons.water_drop_outlined,
            value: state.rainfallChange,
            min: -50, max: 50, divisions: 20,
            unit: '%',
            onChanged: (v) => state.updateScenarioParams(rainfall: v),
          ),
          _ScenarioSlider(
            label: 'Temperature Change',
            icon: Icons.thermostat_rounded,
            value: state.temperatureChange,
            min: -5, max: 5, divisions: 20,
            unit: '°C',
            onChanged: (v) => state.updateScenarioParams(temperature: v),
          ),
          _ScenarioSlider(
            label: 'Irrigation Change',
            icon: Icons.opacity_rounded,
            value: state.irrigationChange,
            min: -50, max: 50, divisions: 20,
            unit: '%',
            onChanged: (v) => state.updateScenarioParams(irrigation: v),
          ),
          _ScenarioSlider(
            label: 'Fertilizer Change',
            icon: Icons.eco_outlined,
            value: state.fertilizerChange,
            min: -50, max: 50, divisions: 20,
            unit: '%',
            onChanged: (v) => state.updateScenarioParams(fertilizer: v),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: state.selectedDistrict == null || state.loadingScenario
                  ? null
                  : () => state.runScenario(),
              icon: const Icon(Icons.compare_arrows_rounded, size: 18),
              label: Text(state.loadingScenario ? 'Analysing...' : 'Run Scenario'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => state.resetScenario(),
              child: const Text('Reset to Baseline'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScenarioSlider extends StatelessWidget {
  final String label, unit;
  final IconData icon;
  final double value, min, max;
  final int divisions;
  final ValueChanged<double> onChanged;

  const _ScenarioSlider({
    required this.label, required this.icon, required this.value,
    required this.min, required this.max, required this.divisions,
    required this.unit, required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isPos = value > 0;
    final valueColor = isPos ? AgriCastTheme.success : value < 0 ? AgriCastTheme.error : AgriCastTheme.textMuted;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: AgriCastTheme.primaryMed),
              const SizedBox(width: 6),
              Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: valueColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${value >= 0 ? '+' : ''}${value.toStringAsFixed(value.abs() < 1 && unit == '°C' ? 1 : 0)}$unit',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: valueColor),
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${min.toStringAsFixed(0)}$unit',
                  style: GoogleFonts.inter(fontSize: 10, color: AgriCastTheme.textMuted)),
              Text('${max.toStringAsFixed(0)}$unit',
                  style: GoogleFonts.inter(fontSize: 10, color: AgriCastTheme.textMuted)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScenarioPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InfoCard(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              Icon(Icons.compare_arrows_rounded, size: 56,
                  color: AgriCastTheme.borderGreen),
              const SizedBox(height: 16),
              Text('Configure a Scenario',
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text('Adjust the climate and agricultural sliders, then click Run Scenario.',
                  style: GoogleFonts.inter(fontSize: 13, color: AgriCastTheme.textSecondary),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScenarioResults extends StatelessWidget {
  final ScenarioResult result;
  const _ScenarioResults({required this.result});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Status banner
        _StatusBanner(result: result).animate().fadeIn(duration: 500.ms),
        const SizedBox(height: 16),

        // Side-by-side ranking comparison
        InfoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                title: 'Ranking Comparison',
                subtitle: 'Baseline vs scenario rankings',
              ),
              const SizedBox(height: 16),
              _RankingComparison(result: result),
            ],
          ),
        ).animate().fadeIn(delay: 100.ms, duration: 500.ms),

        const SizedBox(height: 16),

        // Explanation
        InfoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(title: 'Scenario Explanation'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: result.recommendationChanged
                      ? const Color(0xFFFEF9C3)
                      : AgriCastTheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: result.recommendationChanged
                        ? const Color(0xFFFDE68A)
                        : AgriCastTheme.borderGreen,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      result.recommendationChanged
                          ? Icons.swap_horiz_rounded
                          : Icons.check_circle_outline_rounded,
                      size: 18,
                      color: result.recommendationChanged
                          ? AgriCastTheme.warning
                          : AgriCastTheme.success,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(result.explanation,
                          style: GoogleFonts.inter(fontSize: 13, height: 1.7)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              // Scenario params recap
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: result.scenarioParams.entries.map((e) {
                  final label = e.key.replaceAll('_', ' ').split(' ')
                      .map((w) => w.capitalize()).join(' ');
                  final val = e.value;
                  return _ParamChip(
                    label: label,
                    value: val,
                    unit: e.key.contains('temp') ? '°C' : '%',
                  );
                }).toList(),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 200.ms, duration: 500.ms),

        const SizedBox(height: 16),

        // Confidence change chart
        InfoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(title: 'Confidence Shift', subtitle: 'Δ from baseline to scenario'),
              const SizedBox(height: 16),
              _ConfidenceShiftChart(result: result),
            ],
          ),
        ).animate().fadeIn(delay: 300.ms, duration: 500.ms),
      ],
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final ScenarioResult result;
  const _StatusBanner({required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: result.recommendationChanged
              ? [const Color(0xFFFFFBEB), const Color(0xFFFEF3C7)]
              : [const Color(0xFFF0FDF4), const Color(0xFFDCFCE7)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: result.recommendationChanged
              ? const Color(0xFFFDE68A)
              : AgriCastTheme.borderGreen,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: result.recommendationChanged
                  ? const Color(0xFFFDE68A)
                  : AgriCastTheme.divider,
              shape: BoxShape.circle,
            ),
            child: Icon(
              result.recommendationChanged
                  ? Icons.swap_horiz_rounded
                  : Icons.check_circle_rounded,
              color: result.recommendationChanged
                  ? AgriCastTheme.warning
                  : AgriCastTheme.success,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.recommendationChanged
                      ? 'Recommendation Changed'
                      : 'Recommendation Unchanged',
                  style: GoogleFonts.inter(
                      fontSize: 15, fontWeight: FontWeight.w700,
                      color: AgriCastTheme.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  result.recommendationChanged
                      ? '${result.baselineTop} → ${result.scenarioTop}'
                      : '${result.baselineTop} remains top recommendation',
                  style: GoogleFonts.inter(fontSize: 13, color: AgriCastTheme.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RankingComparison extends StatelessWidget {
  final ScenarioResult result;
  const _RankingComparison({required this.result});

  @override
  Widget build(BuildContext context) {
    final n = result.baselineRankings.length.clamp(0, 6);
    return LayoutBuilder(builder: (_, constraints) {
      final isWide = constraints.maxWidth > 500;
      if (isWide) {
        return Row(
          children: [
            Expanded(child: _RankList(title: 'Baseline', rankings: result.baselineRankings.take(n).toList(), isBaseline: true)),
            const SizedBox(width: 16),
            Expanded(child: _RankList(title: 'Scenario', rankings: result.scenarioRankings.take(n).toList(), isBaseline: false)),
          ],
        );
      }
      return Column(children: [
        _RankList(title: 'Baseline', rankings: result.baselineRankings.take(n).toList(), isBaseline: true),
        const SizedBox(height: 12),
        _RankList(title: 'Scenario', rankings: result.scenarioRankings.take(n).toList(), isBaseline: false),
      ]);
    });
  }
}

class _RankList extends StatelessWidget {
  final String title;
  final List<ScenarioRankItem> rankings;
  final bool isBaseline;
  const _RankList({required this.title, required this.rankings, required this.isBaseline});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isBaseline ? AgriCastTheme.surface : const Color(0xFFFEF9C3),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(title, style: GoogleFonts.inter(
              fontSize: 12, fontWeight: FontWeight.w600,
              color: isBaseline ? AgriCastTheme.primaryDark : AgriCastTheme.warning)),
        ),
        const SizedBox(height: 8),
        ...rankings.map((r) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              RankBadge(rank: r.rank),
              const SizedBox(width: 8),
              Expanded(child: Text(r.crop, style: GoogleFonts.inter(fontSize: 13))),
              ConfidenceBadge(value: r.confidence),
              if (!isBaseline && r.change != 0) ...[
                const SizedBox(width: 6),
                Icon(
                  r.change > 0 ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                  size: 12,
                  color: r.change > 0 ? AgriCastTheme.success : AgriCastTheme.error,
                ),
              ],
            ],
          ),
        )),
      ],
    );
  }
}

class _ConfidenceShiftChart extends StatelessWidget {
  final ScenarioResult result;
  const _ConfidenceShiftChart({required this.result});

  @override
  Widget build(BuildContext context) {
    final items = result.scenarioRankings.take(6).toList();
    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          barGroups: items.asMap().entries.map((e) {
            final change = e.value.change;
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: change,
                  color: change >= 0 ? AgriCastTheme.accent : AgriCastTheme.error,
                  width: 20,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          }).toList(),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (val, _) {
                  final i = val.toInt();
                  if (i < items.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(items[i].crop.substring(0, 3),
                          style: GoogleFonts.inter(fontSize: 10, color: AgriCastTheme.textMuted)),
                    );
                  }
                  return const SizedBox();
                },
                reservedSize: 22,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                getTitlesWidget: (val, _) => Text(
                  '${val.toStringAsFixed(0)}%',
                  style: GoogleFonts.inter(fontSize: 9, color: AgriCastTheme.textMuted),
                ),
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            drawHorizontalLine: true,
            getDrawingHorizontalLine: (_) => FlLine(color: AgriCastTheme.border, strokeWidth: 1),
            drawVerticalLine: false,
          ),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }
}

class _ParamChip extends StatelessWidget {
  final String label, unit;
  final double value;
  const _ParamChip({required this.label, required this.value, required this.unit});

  @override
  Widget build(BuildContext context) {
    final color = value > 0 ? AgriCastTheme.success : value < 0 ? AgriCastTheme.error : AgriCastTheme.textMuted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AgriCastTheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 11, color: AgriCastTheme.textSecondary)),
          const SizedBox(width: 6),
          Text('${value >= 0 ? '+' : ''}${value.toStringAsFixed(unit == '°C' ? 1 : 0)}$unit',
              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}
