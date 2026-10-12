import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';

// ── Reusable Stat Card ────────────────────────────────────────
class StatCard extends StatelessWidget {
  final String label, value;
  final String? subValue;
  final IconData icon;
  final Color? iconBg;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.subValue,
    required this.icon,
    this.iconBg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBg ?? AgriCastTheme.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: AgriCastTheme.primaryMed),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 16),
          Text(value,
              style: GoogleFonts.inter(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AgriCastTheme.textPrimary)),
          if (subValue != null) ...[
            const SizedBox(height: 2),
            Text(subValue!,
                style: GoogleFonts.inter(
                    fontSize: 12, color: AgriCastTheme.textMuted)),
          ],
          const SizedBox(height: 4),
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 13, color: AgriCastTheme.textSecondary)),
        ],
      ),
    );
  }
}

// ── Section Header ────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const SectionHeader({super.key, required this.title, this.subtitle, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AgriCastTheme.textPrimary)),
              if (subtitle != null) ...[
                const SizedBox(height: 3),
                Text(subtitle!,
                    style: GoogleFonts.inter(
                        fontSize: 13, color: AgriCastTheme.textSecondary)),
              ],
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

// ── Info Card ─────────────────────────────────────────────────
class InfoCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const InfoCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AgriCastTheme.border),
      ),
      child: child,
    );
  }
}

// ── Crop Confidence Badge ─────────────────────────────────────
class ConfidenceBadge extends StatelessWidget {
  final double value; // 0-100

  const ConfidenceBadge({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    final color = value > 40
        ? AgriCastTheme.success
        : value > 20
            ? AgriCastTheme.warning
            : AgriCastTheme.textMuted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text('${value.toStringAsFixed(1)}%',
          style: GoogleFonts.inter(
              fontSize: 12, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

// ── Direction Tag ─────────────────────────────────────────────
class DirectionTag extends StatelessWidget {
  final String direction; // positive | negative | neutral
  final String magnitude;

  const DirectionTag({super.key, required this.direction, required this.magnitude});

  @override
  Widget build(BuildContext context) {
    final (color, icon, label) = switch (direction) {
      'positive' => (AgriCastTheme.success, Icons.arrow_upward_rounded, 'Favourable'),
      'negative' => (AgriCastTheme.error, Icons.arrow_downward_rounded, 'Unfavourable'),
      _ => (AgriCastTheme.textMuted, Icons.remove_rounded, 'Neutral'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 11, fontWeight: FontWeight.w500, color: color)),
        ],
      ),
    );
  }
}

// ── Rank Number Badge ─────────────────────────────────────────
class RankBadge extends StatelessWidget {
  final int rank;

  const RankBadge({super.key, required this.rank});

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = rank == 1
        ? (AgriCastTheme.primary, Colors.white)
        : rank == 2
            ? (const Color(0xFFDCFCE7), AgriCastTheme.primaryDark)
            : rank == 3
                ? (const Color(0xFFF0FDF4), AgriCastTheme.primaryMed)
                : (AgriCastTheme.border, AgriCastTheme.textMuted);

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Center(
        child: Text('#$rank',
            style: GoogleFonts.inter(
                fontSize: 12, fontWeight: FontWeight.w700, color: fg)),
      ),
    );
  }
}

// ── Loading Overlay ───────────────────────────────────────────
class LoadingOverlay extends StatelessWidget {
  final String message;
  const LoadingOverlay({super.key, this.message = 'Processing...'});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AgriCastTheme.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 40, height: 40,
              child: CircularProgressIndicator(
                  strokeWidth: 3, color: AgriCastTheme.primary),
            ),
            const SizedBox(height: 16),
            Text(message,
                style: GoogleFonts.inter(
                    fontSize: 14, color: AgriCastTheme.textSecondary)),
          ],
        ),
      ),
    );
  }
}

// ── Error Banner ──────────────────────────────────────────────
class ErrorBanner extends StatelessWidget {
  final String message;
  const ErrorBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: AgriCastTheme.error, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message,
                style: GoogleFonts.inter(
                    fontSize: 13, color: AgriCastTheme.error)),
          ),
        ],
      ),
    );
  }
}

// ── Crop Icon ─────────────────────────────────────────────────
String emojiForCrop(String crop) {
  return switch (crop.toLowerCase()) {
    'rice' || 'paddy' => '🌾',
    'wheat' => '🌿',
    'sugarcane' => '🎋',
    'cotton' => '🌸',
    'groundnut' => '🥜',
    'chickpea' || 'gram' => '🫘',
    'maize' => '🌽',
    'millet' || 'bajra' => '🌾',
    'sorghum' || 'jowar' => '🌱',
    'mustard' => '🌻',
    'soybean' => '🫛',
    'lentil' || 'masoor' => '🌰',
    'jute' => '🪢',
    'potato' => '🥔',
    _ => '🌿',
  };
}

Widget cropIcon(String crop) {
  return Text(emojiForCrop(crop), style: const TextStyle(fontSize: 20));
}
