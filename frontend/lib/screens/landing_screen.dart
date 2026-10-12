import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/theme.dart';
import '../providers/app_state.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _HeroSection(),
            _HowItWorksSection(),
            _FeaturesSection(),
            _MethodologySection(),
            _TechStackSection(),
            _FooterSection(),
          ],
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF052E16), Color(0xFF14532D), Color(0xFF166534)],
        ),
      ),
      child: Stack(
        children: [
          // Subtle grid pattern
          Positioned.fill(
            child: CustomPaint(painter: _GridPainter()),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 6, height: 6,
                          decoration: const BoxDecoration(color: AgriCastTheme.accent, shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Text('LambdaMART · Learning-to-Rank · 95 Features',
                          style: GoogleFonts.inter(color: AgriCastTheme.accent,
                              fontSize: 12, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2),
                const SizedBox(height: 28),
                // Main Title
                Text('AgriCAST',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 64,
                      fontWeight: FontWeight.w800,
                      height: 1.05,
                      letterSpacing: -1.5,
                    ),
                    textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 100.ms, duration: 700.ms).slideY(begin: 0.2),
                const SizedBox(height: 12),
                Text('Climate-Adaptive Crop Recommendation\nUsing Learning-to-Rank AI',
                    style: GoogleFonts.inter(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 20,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 200.ms, duration: 700.ms),
                const SizedBox(height: 48),
                // CTA Buttons
                Wrap(
                  spacing: 14,
                  runSpacing: 14,
                  alignment: WrapAlignment.center,
                  children: [
                    _LandingCTA(
                      label: 'Start Analysis',
                      icon: Icons.play_arrow_rounded,
                      isPrimary: true,
                      onTap: () {
                        state.navigateTo(AppScreen.dashboard);
                      },
                    ),
                    _LandingCTA(
                      label: 'View Analytics',
                      icon: Icons.analytics_outlined,
                      isPrimary: false,
                      onTap: () => state.navigateTo(AppScreen.analytics),
                    ),
                  ],
                ).animate().fadeIn(delay: 350.ms, duration: 600.ms),
                const SizedBox(height: 80),
                // Stats row
                Wrap(
                  spacing: 40,
                  runSpacing: 20,
                  alignment: WrapAlignment.center,
                  children: const [
                    _StatChip(value: '56', label: 'Districts'),
                    _StatChip(value: '23 yrs', label: 'Training Data'),
                    _StatChip(value: '95', label: 'Features'),
                    _StatChip(value: 'LambdaRank', label: 'Algorithm'),
                  ],
                ).animate().fadeIn(delay: 500.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LandingCTA extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isPrimary;
  final VoidCallback onTap;
  const _LandingCTA({required this.label, required this.icon, required this.isPrimary, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (isPrimary) {
      return ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: AgriCastTheme.accent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String value, label;
  const _StatChip({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.inter(color: AgriCastTheme.accent,
            fontSize: 22, fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text(label, style: GoogleFonts.inter(
            color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
      ],
    );
  }
}

class _HowItWorksSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'How AgriCAST Works',
      subtitle: 'A streamlined three-step process from district selection to actionable recommendation.',
      child: Wrap(
        spacing: 20,
        runSpacing: 20,
        alignment: WrapAlignment.center,
        children: const [
          _StepCard(num: '01', icon: Icons.location_on_outlined, title: 'Select District & Year',
              desc: 'Choose your district from 56 covered across India and the target pre-season year.'),
          _StepCard(num: '02', icon: Icons.memory_rounded, title: 'AI Processes All Data',
              desc: 'The system retrieves historical yields, climate patterns, fertiliser usage, and computes 95 model features automatically.'),
          _StepCard(num: '03', icon: Icons.format_list_numbered_rounded, title: 'Ranked Recommendations',
              desc: 'LambdaMART ranks all eligible crops with confidence scores and an evidence-based natural language explanation.'),
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final String num, title, desc;
  final IconData icon;
  const _StepCard({required this.num, required this.title, required this.desc, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AgriCastTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AgriCastTheme.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AgriCastTheme.primary, size: 20),
              ),
              const Spacer(),
              Text(num, style: GoogleFonts.inter(color: AgriCastTheme.borderGreen,
                  fontSize: 28, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 16),
          Text(title, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600,
              color: AgriCastTheme.textPrimary)),
          const SizedBox(height: 8),
          Text(desc, style: GoogleFonts.inter(fontSize: 13, color: AgriCastTheme.textSecondary, height: 1.6)),
        ],
      ),
    );
  }
}

class _FeaturesSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _Section(
      bgColor: AgriCastTheme.surface,
      title: 'Platform Features',
      subtitle: 'Everything a farmer, officer, or researcher needs in one place.',
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        alignment: WrapAlignment.center,
        children: const [
          _FeatureChip(icon: Icons.agriculture_rounded, label: 'Crop Rankings'),
          _FeatureChip(icon: Icons.wb_sunny_outlined, label: 'Climate Analysis'),
          _FeatureChip(icon: Icons.tune_rounded, label: 'Scenario Engine'),
          _FeatureChip(icon: Icons.insights_rounded, label: 'District Trends'),
          _FeatureChip(icon: Icons.picture_as_pdf_rounded, label: 'PDF Reports'),
          _FeatureChip(icon: Icons.psychology_rounded, label: 'AI Explanations'),
          _FeatureChip(icon: Icons.water_drop_outlined, label: 'Irrigation Insights'),
          _FeatureChip(icon: Icons.emoji_nature_outlined, label: 'Aridity Modelling'),
        ],
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _FeatureChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AgriCastTheme.borderGreen),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AgriCastTheme.primaryMed),
          const SizedBox(width: 8),
          Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500,
              color: AgriCastTheme.textGreen)),
        ],
      ),
    );
  }
}

class _MethodologySection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final steps = [
      ('Raw Dataset', Icons.storage_outlined),
      ('Data Cleaning', Icons.cleaning_services_outlined),
      ('Feature Engineering', Icons.construction_outlined),
      ('Ranking Dataset', Icons.table_chart_outlined),
      ('LambdaMART Training', Icons.model_training_outlined),
      ('Recommendation Engine', Icons.hub_outlined),
      ('Decision Support', Icons.dashboard_outlined),
    ];
    return _Section(
      title: 'Research Methodology',
      subtitle: 'A rigorous pipeline from raw data to actionable pre-season recommendations.',
      child: SizedBox(
        width: double.infinity,
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 4,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: steps.asMap().entries.expand((entry) {
            final idx = entry.key;
            final (label, icon) = entry.value;
            final widgets = <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AgriCastTheme.primary.withValues(alpha: idx == steps.length - 1 ? 1 : 0.08 + idx * 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AgriCastTheme.borderGreen),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 14,
                        color: idx == steps.length - 1 ? Colors.white : AgriCastTheme.primaryMed),
                    const SizedBox(width: 6),
                    Text(label, style: GoogleFonts.inter(
                      fontSize: 12, fontWeight: FontWeight.w500,
                      color: idx == steps.length - 1 ? Colors.white : AgriCastTheme.primaryDark,
                    )),
                  ],
                ),
              ),
            ];
            if (idx < steps.length - 1) {
              widgets.add(Icon(Icons.arrow_forward_rounded, size: 16, color: AgriCastTheme.primaryBright));
            }
            return widgets;
          }).toList(),
        ),
      ),
    );
  }
}

class _TechStackSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _Section(
      bgColor: AgriCastTheme.surface,
      title: 'Technology Stack',
      subtitle: 'Built with production-grade tools for reliability and performance.',
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        alignment: WrapAlignment.center,
        children: const [
          _TechCard(label: 'Flutter', sub: 'Frontend', icon: Icons.phone_android_rounded),
          _TechCard(label: 'FastAPI', sub: 'Backend', icon: Icons.api_rounded),
          _TechCard(label: 'LightGBM', sub: 'ML Engine', icon: Icons.memory_rounded),
          _TechCard(label: 'LambdaRank', sub: 'Algorithm', icon: Icons.sort_rounded),
          _TechCard(label: 'ReportLab', sub: 'PDF Engine', icon: Icons.picture_as_pdf_rounded),
          _TechCard(label: 'Docker', sub: 'Deployment', icon: Icons.cloud_rounded),
        ],
      ),
    );
  }
}

class _TechCard extends StatelessWidget {
  final String label, sub;
  final IconData icon;
  const _TechCard({required this.label, required this.sub, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AgriCastTheme.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: AgriCastTheme.primary, size: 26),
          const SizedBox(height: 8),
          Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
          Text(sub, style: GoogleFonts.inter(fontSize: 11, color: AgriCastTheme.textMuted)),
        ],
      ),
    );
  }
}

class _FooterSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AgriCastTheme.surfaceDark,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 40),
      child: Row(
        children: [
          Row(children: [
            const Icon(Icons.eco_rounded, color: AgriCastTheme.accent, size: 18),
            const SizedBox(width: 8),
            Text('AgriCAST', style: GoogleFonts.inter(color: Colors.white,
                fontSize: 15, fontWeight: FontWeight.w600)),
          ]),
          const Spacer(),
          Text('AI-Powered Crop Recommendation System  ·  v1.0',
              style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.35), fontSize: 12)),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title, subtitle;
  final Widget child;
  final Color bgColor;
  const _Section({required this.title, required this.subtitle,
    required this.child, this.bgColor = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: bgColor,
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 32),
      child: Column(
        children: [
          Text(title, style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700,
              color: AgriCastTheme.textPrimary), textAlign: TextAlign.center),
          const SizedBox(height: 10),
          Text(subtitle, style: GoogleFonts.inter(fontSize: 15, color: AgriCastTheme.textSecondary,
              height: 1.6), textAlign: TextAlign.center),
          const SizedBox(height: 40),
          child,
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 1;
    const spacing = 50.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }
  @override
  bool shouldRepaint(_) => false;
}
