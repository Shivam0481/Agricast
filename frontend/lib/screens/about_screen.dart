import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';
import '../widgets/common_widgets.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AgriCastTheme.primaryDark, AgriCastTheme.primary],
              ),
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.eco_rounded, color: AgriCastTheme.accent, size: 28),
                    const SizedBox(width: 10),
                    Text('AgriCAST', style: GoogleFonts.inter(
                        color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                  ],
                ),
                const SizedBox(height: 6),
                Text('AI-Powered Climate-Adaptive Crop Recommendation System',
                    style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.7), fontSize: 14)),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: ['v1.0.0', 'LambdaMART', '56 Districts', '2001–2023 Data', 'Production Ready']
                      .map((s) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: Text(s, style: GoogleFonts.inter(color: Colors.white, fontSize: 11)),
                  )).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          LayoutBuilder(builder: (_, constraints) {
            final isWide = constraints.maxWidth > 700;
            final overview = _OverviewCard();
            final methodology = _MethodologyCard();
            final lambdaCard = _LambdaMARTCard();
            final techCard = _TechStackCard();

            if (isWide) {
              return Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: overview),
                      const SizedBox(width: 16),
                      Expanded(child: methodology),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: lambdaCard),
                      const SizedBox(width: 16),
                      Expanded(child: techCard),
                    ],
                  ),
                ],
              );
            }
            return Column(children: [
              overview,
              const SizedBox(height: 16),
              methodology,
              const SizedBox(height: 16),
              lambdaCard,
              const SizedBox(height: 16),
              techCard,
            ]);
          }),

          const SizedBox(height: 16),
          _DisclaimerCard(),
        ],
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: 'Project Overview'),
          const SizedBox(height: 12),
          Text(
            'AgriCAST (Agricultural Climate-Adaptive Suitability and Timing) is a pre-season crop '
            'recommendation and decision-support platform designed for farmers, agricultural officers, '
            'researchers, and government agencies.\n\n'
            'The system combines 23 years of historical agricultural data with seasonal climate records '
            'across 56 major Indian districts to deliver ranked crop recommendations powered by '
            'LambdaMART Learning-to-Rank AI — the same family of algorithms used by major search engines.',
            style: GoogleFonts.inter(fontSize: 13, height: 1.7, color: AgriCastTheme.textPrimary),
          ),
          const SizedBox(height: 16),
          _InfoRow(Icons.people_outlined, 'Target Users',
              'Farmers · Officers · Researchers · Government'),
          _InfoRow(Icons.calendar_today_outlined, 'Use Case', 'Pre-season crop selection (not yield prediction)'),
          _InfoRow(Icons.location_on_outlined, 'Coverage', '56 districts across 12 Indian states'),
        ],
      ),
    );
  }
}

class _MethodologyCard extends StatelessWidget {
  final _steps = const [
    ('Raw Dataset', 'Multiyear agricultural + climate records per district'),
    ('Data Cleaning', 'Outlier removal, imputation, temporal alignment'),
    ('Feature Engineering', '95 features: climate, yield lags, area share, aridity'),
    ('Ranking Dataset', 'District-year queries with per-crop relevance labels'),
    ('LambdaMART Training', 'Gradient boosted trees optimised for NDCG ranking'),
    ('Recommendation Engine', 'Inference pipeline: input → 95 features → scores → ranks'),
    ('Scenario Analysis', 'What-if simulation by modifying climate/ag parameters'),
    ('Decision Support', 'Ranked output + natural language explanations + PDF'),
  ];

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: 'Research Methodology'),
          const SizedBox(height: 12),
          ..._steps.asMap().entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 22, height: 22,
                  decoration: BoxDecoration(
                    color: e.key < 5 ? AgriCastTheme.primaryDark : AgriCastTheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text('${e.key + 1}',
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 10,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.value.$1, style: GoogleFonts.inter(
                          fontSize: 12, fontWeight: FontWeight.w600)),
                      Text(e.value.$2, style: GoogleFonts.inter(
                          fontSize: 11, color: AgriCastTheme.textSecondary, height: 1.4)),
                    ],
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class _LambdaMARTCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: 'LambdaMART Algorithm'),
          const SizedBox(height: 12),
          Text(
            'LambdaMART is a gradient boosted tree algorithm that directly optimises ranking metrics '
            '(NDCG). Unlike classification or regression models, it learns the relative order of items '
            'within a query group — ideal for ranking crops within a district-year context.\n\n'
            'The model treats each (district, year) combination as a "query" and each crop as a '
            '"document". It outputs a relevance score per crop, which are then ranked to produce '
            'the final recommendation.',
            style: GoogleFonts.inter(fontSize: 13, height: 1.7, color: AgriCastTheme.textPrimary),
          ),
          const SizedBox(height: 16),
          _InfoRow(Icons.memory_rounded, 'Implementation', 'LightGBM LGBMRanker · lambdarank objective'),
          _InfoRow(Icons.tune_rounded, 'Configuration', '300 trees · LR 0.05 · num_leaves 31'),
          _InfoRow(Icons.bar_chart_rounded, 'Metric', 'NDCG (Normalised Discounted Cumulative Gain)'),
          _InfoRow(Icons.list_alt_rounded, 'Features', '95 total across 7 feature groups'),
          _InfoRow(Icons.emoji_events_outlined, 'Top Feature', 'Yield_lag1 (previous year crop yield)'),
        ],
      ),
    );
  }
}

class _TechStackCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final stack = [
      (Icons.phone_android_rounded, 'Flutter 3.44', 'Frontend — cross-platform UI'),
      (Icons.api_rounded, 'FastAPI', 'Backend REST API — async Python'),
      (Icons.memory_rounded, 'LightGBM 4.5', 'ML inference engine'),
      (Icons.storage_rounded, 'JSON Data', 'Synthetic historical dataset (2.5MB)'),
      (Icons.picture_as_pdf_rounded, 'ReportLab', 'Professional PDF generation'),
      (Icons.cloud_outlined, 'Docker', 'Containerised deployment'),
      (Icons.bar_chart_rounded, 'fl_chart', 'Flutter charting library'),
      (Icons.code_rounded, 'Dart + Python', 'Primary languages'),
    ];

    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: 'Technology Stack'),
          const SizedBox(height: 12),
          ...stack.map((s) => _InfoRow(s.$1, s.$2, s.$3)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AgriCastTheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AgriCastTheme.borderGreen),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: AgriCastTheme.success, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('All model artifacts (agricast_lambdamart_v1.pkl, agricast_features_v1.pkl) loaded at API startup.',
                      style: GoogleFonts.inter(fontSize: 12, color: AgriCastTheme.primaryDark)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DisclaimerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AgriCastTheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AgriCastTheme.borderGreen),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 18, color: AgriCastTheme.primaryMed),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'AgriCAST recommendations are decision-support tools based on historical patterns and '
              'should be validated with local agricultural expertise before operational use. '
              'The system does not predict future yields — it ranks crop suitability based on '
              'historical evidence and current climate conditions.',
              style: GoogleFonts.inter(fontSize: 12, color: AgriCastTheme.textSecondary, height: 1.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _InfoRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: AgriCastTheme.primaryMed),
          const SizedBox(width: 8),
          SizedBox(
            width: 110,
            child: Text(label, style: GoogleFonts.inter(
                fontSize: 12, fontWeight: FontWeight.w500, color: AgriCastTheme.textSecondary)),
          ),
          Expanded(
            child: Text(value, style: GoogleFonts.inter(fontSize: 12, color: AgriCastTheme.textPrimary)),
          ),
        ],
      ),
    );
  }
}
