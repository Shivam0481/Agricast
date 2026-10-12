import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/theme.dart';
import '../providers/app_state.dart';
import '../models/models.dart';
import '../widgets/common_widgets.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Input Panel
          _InputPanel(),
          const SizedBox(height: 24),
          if (state.loadingRec)
            const LoadingOverlay(message: 'Running LambdaMART inference...')
          else if (state.recError != null)
            ErrorBanner(message: state.recError!)
          else if (state.recommendation != null)
            _ResultPanel(rec: state.recommendation!)
          else
            _EmptyState(),
        ],
      ),
    );
  }
}

// ── Input Panel ───────────────────────────────────────────────
class _InputPanel extends StatefulWidget {
  @override
  State<_InputPanel> createState() => _InputPanelState();
}

class _InputPanelState extends State<_InputPanel> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Pre-Sowing Crop Recommendation',
                  style: GoogleFonts.inter(
                      fontSize: 20, fontWeight: FontWeight.w700,
                      color: AgriCastTheme.textPrimary)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AgriCastTheme.surfaceGreen,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AgriCastTheme.borderGreen),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bolt_rounded, size: 14, color: AgriCastTheme.primaryDark),
                    const SizedBox(width: 4),
                    Text('Present Season 2026',
                        style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AgriCastTheme.primaryDark)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Select your district to compute real-time suitability rankings for the upcoming pre-sowing season using trained LambdaMART intelligence.',
            style: GoogleFonts.inter(
                fontSize: 13, color: AgriCastTheme.textSecondary),
          ),
          const SizedBox(height: 22),
          // Responsive form row
          LayoutBuilder(builder: (context, constraints) {
            final isWide = constraints.maxWidth > 700;
            final districtField = _DistrictSearch(
              districts: state.districts,
              selected: state.selectedDistrict,
              onSelect: state.selectDistrict,
            );
            final seasonField = _SeasonHorizonSelector(
              selectedYear: state.selectedYear,
              onSelect: state.selectYear,
            );
            final btn = _GenerateButton(
              loading: state.loadingRec,
              disabled: state.selectedDistrict == null,
              onPressed: () => state.getRecommendation(),
            );

            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(flex: 4, child: districtField),
                  const SizedBox(width: 14),
                  Expanded(flex: 3, child: seasonField),
                  const SizedBox(width: 14),
                  btn,
                ],
              );
            }
            return Column(
              children: [
                districtField,
                const SizedBox(height: 12),
                seasonField,
                const SizedBox(height: 14),
                SizedBox(width: double.infinity, child: btn),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _DistrictSearch extends StatefulWidget {
  final List<District> districts;
  final District? selected;
  final ValueChanged<District?> onSelect;

  const _DistrictSearch({required this.districts, required this.selected, required this.onSelect});

  @override
  State<_DistrictSearch> createState() => _DistrictSearchState();
}

class _DistrictSearchState extends State<_DistrictSearch> {
  final _ctrl = TextEditingController();
  final _focusNode = FocusNode();
  List<District> _filtered = [];
  bool _open = false;

  @override
  void initState() {
    super.initState();
    if (widget.selected != null) {
      _ctrl.text = widget.selected!.distName;
    }
  }

  void _filter(String query) {
    final q = query.toLowerCase();
    setState(() {
      _filtered = widget.districts
          .where((d) =>
              d.distName.toLowerCase().contains(q) ||
              d.stateName.toLowerCase().contains(q))
          .take(10)
          .toList();
      _open = query.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('District', style: GoogleFonts.inter(
            fontSize: 13, fontWeight: FontWeight.w500,
            color: AgriCastTheme.textPrimary)),
        const SizedBox(height: 6),
        TextField(
          controller: _ctrl,
          focusNode: _focusNode,
          decoration: const InputDecoration(
            hintText: 'Search district or state...',
            prefixIcon: Icon(Icons.search_rounded, size: 18),
          ),
          onChanged: _filter,
          onTap: () => _filter(_ctrl.text),
        ),
        if (_open && _filtered.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            constraints: const BoxConstraints(maxHeight: 220),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AgriCastTheme.border),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _filtered.length,
              itemBuilder: (_, i) {
                final d = _filtered[i];
                return InkWell(
                  onTap: () {
                    widget.onSelect(d);
                    _ctrl.text = d.distName;
                    setState(() => _open = false);
                    _focusNode.unfocus();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 14,
                            color: AgriCastTheme.primaryMed),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(d.distName, style: GoogleFonts.inter(
                                  fontSize: 13, fontWeight: FontWeight.w500)),
                              Text(d.stateName, style: GoogleFonts.inter(
                                  fontSize: 11, color: AgriCastTheme.textMuted)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AgriCastTheme.surface,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(d.zone.replaceAll('_', ' '),
                              style: GoogleFonts.inter(
                                  fontSize: 10, color: AgriCastTheme.textGreen)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _SeasonHorizonSelector extends StatelessWidget {
  final int selectedYear;
  final ValueChanged<int> onSelect;

  const _SeasonHorizonSelector({
    required this.selectedYear,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Forecast Season',
                style: GoogleFonts.inter(
                    fontSize: 13, fontWeight: FontWeight.w600, color: AgriCastTheme.textPrimary)),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
              decoration: BoxDecoration(
                color: AgriCastTheme.surfaceGreen,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AgriCastTheme.borderGreen),
              ),
              child: Text(selectedYear == 2026 ? 'PRESENT' : 'FUTURE',
                  style: GoogleFonts.inter(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: AgriCastTheme.primaryDark)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AgriCastTheme.border),
          ),
          child: Row(
            children: [
              const Icon(Icons.event_available_rounded, size: 18, color: AgriCastTheme.primaryMed),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: selectedYear,
                    isDense: true,
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AgriCastTheme.textPrimary,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 2026,
                        child: Text('2026 · Present Pre-Sowing Season'),
                      ),
                      DropdownMenuItem(
                        value: 2027,
                        child: Text('2027 · Next Season Horizon'),
                      ),
                      DropdownMenuItem(
                        value: 2028,
                        child: Text('2028 · Extended Projection'),
                      ),
                    ],
                    onChanged: (v) {
                      if (v != null) onSelect(v);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GenerateButton extends StatelessWidget {
  final bool loading, disabled;
  final VoidCallback onPressed;

  const _GenerateButton({required this.loading, required this.disabled, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: ElevatedButton.icon(
        onPressed: (loading || disabled) ? null : onPressed,
        icon: loading
            ? const SizedBox(width: 16, height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Icon(Icons.play_arrow_rounded, size: 18),
        label: Text(loading ? 'Running...' : 'Generate'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}

// ── Result Panel ──────────────────────────────────────────────
class _ResultPanel extends StatelessWidget {
  final RecommendationResult rec;
  const _ResultPanel({required this.rec});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top row cards
        LayoutBuilder(builder: (_, constraints) {
          final isWide = constraints.maxWidth > 700;
          final topCropCard = _TopCropCard(rec: rec);
          final statsRow = Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              SizedBox(
                width: isWide ? 160 : double.infinity,
                child: StatCard(
                  label: 'Total Crops Evaluated',
                  value: '${rec.rankings.length}',
                  icon: Icons.agriculture_rounded,
                ),
              ),
              SizedBox(
                width: isWide ? 160 : double.infinity,
                child: StatCard(
                  label: 'Monsoon Rainfall',
                  value: '${rec.climateSummary['monsoon_precip_mm']?.toStringAsFixed(0) ?? '—'} mm',
                  icon: Icons.water_drop_outlined,
                ),
              ),
              SizedBox(
                width: isWide ? 160 : double.infinity,
                child: StatCard(
                  label: 'Avg Max Temperature',
                  value: '${rec.climateSummary['avg_max_temp_c']?.toStringAsFixed(1) ?? '—'}°C',
                  icon: Icons.wb_sunny_outlined,
                ),
              ),
            ],
          );

          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: topCropCard),
                const SizedBox(width: 16),
                Expanded(child: statsRow),
              ],
            );
          }
          return Column(children: [
            topCropCard,
            const SizedBox(height: 16),
            statsRow,
          ]);
        }).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1),

        const SizedBox(height: 20),

        // Rankings + Explanation
        LayoutBuilder(builder: (_, constraints) {
          final isWide = constraints.maxWidth > 760;
          final rankingsCard = _RankingsCard(rankings: rec.rankings);
          final explanationCard = _ExplanationCard(rec: rec);
          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: rankingsCard),
                const SizedBox(width: 16),
                Expanded(flex: 2, child: explanationCard),
              ],
            );
          }
          return Column(children: [
            rankingsCard,
            const SizedBox(height: 16),
            explanationCard,
          ]);
        }).animate().fadeIn(delay: 100.ms, duration: 500.ms).slideY(begin: 0.1),

        const SizedBox(height: 20),

        // Confidence Chart + Feature Influences
        LayoutBuilder(builder: (_, constraints) {
          final isWide = constraints.maxWidth > 760;
          final chartCard = _ConfidenceChart(rankings: rec.rankings);
          final influencesCard = _InfluencesCard(influences: rec.featureInfluences);
          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: chartCard),
                const SizedBox(width: 16),
                Expanded(flex: 3, child: influencesCard),
              ],
            );
          }
          return Column(children: [
            chartCard,
            const SizedBox(height: 16),
            influencesCard,
          ]);
        }).animate().fadeIn(delay: 200.ms, duration: 500.ms).slideY(begin: 0.1),
      ],
    );
  }
}

class _TopCropCard extends StatelessWidget {
  final RecommendationResult rec;
  const _TopCropCard({required this.rec});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AgriCastTheme.primaryDark, AgriCastTheme.primary],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('Top Recommendation',
                    style: GoogleFonts.inter(
                        fontSize: 11, color: Colors.white, fontWeight: FontWeight.w500)),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AgriCastTheme.accent.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('${rec.topConfidence.toStringAsFixed(1)}% confidence',
                    style: GoogleFonts.inter(
                        fontSize: 11, color: AgriCastTheme.accent, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(emojiForCrop(rec.topCrop),
                  style: const TextStyle(fontSize: 40)),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(rec.topCrop,
                      style: GoogleFonts.inter(
                          fontSize: 30, fontWeight: FontWeight.w800,
                          color: Colors.white, height: 1.1)),
                  Text('${rec.districtName} · Present Season ${rec.year}',
                      style: GoogleFonts.inter(
                          fontSize: 13, color: Colors.white.withValues(alpha: 0.8))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Mini confidence bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: rec.topConfidence / 100,
              backgroundColor: Colors.white.withValues(alpha: 0.15),
              valueColor: const AlwaysStoppedAnimation(AgriCastTheme.accent),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

class _RankingsCard extends StatelessWidget {
  final List<CropRank> rankings;
  const _RankingsCard({required this.rankings});

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      padding: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: SectionHeader(
              title: 'Crop Rankings',
              subtitle: 'All evaluated crops ranked by suitability',
            ),
          ),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: rankings.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final r = rankings[i];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    RankBadge(rank: r.rank),
                    const SizedBox(width: 12),
                    cropIcon(r.crop),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r.crop, style: GoogleFonts.inter(
                              fontSize: 14, fontWeight: FontWeight.w500)),
                          if (r.yieldLag1 != null)
                            Text('Prev yield: ${r.yieldLag1!.toStringAsFixed(0)} kg/ha',
                                style: GoogleFonts.inter(
                                    fontSize: 11, color: AgriCastTheme.textMuted)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        ConfidenceBadge(value: r.confidence),
                        if (r.areaShare != null) ...[
                          const SizedBox(height: 2),
                          Text('${(r.areaShare! * 100).toStringAsFixed(1)}% area',
                              style: GoogleFonts.inter(
                                  fontSize: 10, color: AgriCastTheme.textMuted)),
                        ],
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ExplanationCard extends StatelessWidget {
  final RecommendationResult rec;
  const _ExplanationCard({required this.rec});

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'AI Explanation',
            subtitle: 'Why this crop was recommended',
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AgriCastTheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AgriCastTheme.borderGreen),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.format_quote_rounded,
                    color: AgriCastTheme.primaryMed, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(rec.explanation,
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AgriCastTheme.textPrimary,
                          height: 1.7)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Key metrics
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AgriCastTheme.border),
            ),
            child: Column(
              children: [
                _MetricRow('Irrigation Coverage',
                    '${((rec.climateSummary['irr_ratio'] as double? ?? 0) * 100).toStringAsFixed(0)}%'),
                const SizedBox(height: 8),
                _MetricRow('Annual Precipitation',
                    '${(rec.climateSummary['total_annual_precip_mm'] as double? ?? 0).toStringAsFixed(0)} mm'),
                const SizedBox(height: 8),
                _MetricRow('Model Status',
                    rec.modelLoaded ? '✓ LambdaMART Active' : '⚠ Fallback Mode'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  final String label, value;
  const _MetricRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 12, color: AgriCastTheme.textSecondary)),
        Text(value, style: GoogleFonts.inter(
            fontSize: 12, fontWeight: FontWeight.w600, color: AgriCastTheme.textPrimary)),
      ],
    );
  }
}

class _ConfidenceChart extends StatelessWidget {
  final List<CropRank> rankings;
  const _ConfidenceChart({required this.rankings});

  @override
  Widget build(BuildContext context) {
    final top5 = rankings.take(5).toList();
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: 'Confidence Distribution', subtitle: 'Top 5 crops'),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: top5.asMap().entries.map((e) {
                  final idx = e.key;
                  final r = e.value;
                  final color = AgriCastTheme.chartColors[idx % AgriCastTheme.chartColors.length];
                  return PieChartSectionData(
                    value: r.confidence,
                    color: color,
                    title: idx == 0 ? r.crop : '',
                    titleStyle: GoogleFonts.inter(
                        fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                    radius: idx == 0 ? 70 : 55,
                    badgeWidget: idx == 0
                        ? Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                                color: Colors.white, shape: BoxShape.circle),
                            child: cropIcon(r.crop))
                        : null,
                    badgePositionPercentageOffset: 1.0,
                  );
                }).toList(),
                centerSpaceRadius: 0,
                sectionsSpace: 2,
              ),
            ),
          ),
          const SizedBox(height: 14),
          // Legend
          ...top5.asMap().entries.map((e) {
            final color = AgriCastTheme.chartColors[e.key % AgriCastTheme.chartColors.length];
            final r = e.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Container(width: 10, height: 10,
                      decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Text(r.crop, style: GoogleFonts.inter(fontSize: 12)),
                  const Spacer(),
                  Text('${r.confidence.toStringAsFixed(1)}%',
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600,
                          color: AgriCastTheme.textGreen)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _InfluencesCard extends StatelessWidget {
  final List<FeatureInfluence> influences;
  const _InfluencesCard({required this.influences});

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Key Influencing Factors',
            subtitle: 'Climate and agricultural drivers for this recommendation',
          ),
          const SizedBox(height: 16),
          ...influences.map((inf) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AgriCastTheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AgriCastTheme.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(inf.displayName, style: GoogleFonts.inter(
                            fontSize: 13, fontWeight: FontWeight.w500)),
                        Text(inf.featureGroup, style: GoogleFonts.inter(
                            fontSize: 11, color: AgriCastTheme.textMuted)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      DirectionTag(direction: inf.direction, magnitude: inf.magnitude),
                      const SizedBox(height: 3),
                      Text(inf.magnitude.capitalize(), style: GoogleFonts.inter(
                          fontSize: 10, color: AgriCastTheme.textMuted)),
                    ],
                  ),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(48),
        child: Column(
          children: [
            Icon(Icons.agriculture_rounded, size: 64,
                color: AgriCastTheme.borderGreen),
            const SizedBox(height: 16),
            Text('Ready to Recommend',
                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600,
                    color: AgriCastTheme.textPrimary)),
            const SizedBox(height: 8),
            Text('Select a district and year above, then click Generate.',
                style: GoogleFonts.inter(fontSize: 13,
                    color: AgriCastTheme.textSecondary)),
          ],
        ),
      ),
    );
  }
}

extension StringExt on String {
  String capitalize() => isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
