import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:printing/printing.dart';
import '../config/theme.dart';
import '../providers/app_state.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../widgets/common_widgets.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  bool _generating = false;
  String? _error;
  bool _includeScenario = false;

  Future<void> _generateReport(BuildContext context) async {
    final state = context.read<AppState>();
    final rec = state.recommendation;
    if (rec == null) {
      setState(() => _error = 'Please generate a recommendation first from the Dashboard.');
      return;
    }

    setState(() { _generating = true; _error = null; });

    try {
      final fileName = 'AgriCAST_${rec.districtName}_${rec.year}.pdf';
      final downloadUrl = ApiService.reportDownloadUrl(
        rec.districtId,
        rec.year,
        includeScenario: _includeScenario,
      );

      // Fetch actual PDF binary bytes from backend
      final Uint8List pdfBytes = await ApiService.fetchReportBytes(
        districtId: rec.districtId,
        year: rec.year,
        includeScenario: _includeScenario,
      );

      // Trigger native download/share in browser
      await Printing.sharePdf(bytes: pdfBytes, filename: fileName);

      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: AgriCastTheme.success, size: 24),
                const SizedBox(width: 8),
                Text('Report Ready',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 18)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your official AgriCAST agronomic dossier for ${rec.districtName} (Season ${rec.year}) has been generated.',
                  style: GoogleFonts.inter(fontSize: 13.5, color: AgriCastTheme.textSecondary),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AgriCastTheme.surfaceGreen,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AgriCastTheme.borderGreen),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.picture_as_pdf_rounded, color: AgriCastTheme.primaryDark, size: 24),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fileName,
                              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AgriCastTheme.primaryDark),
                            ),
                            Text(
                              '${(pdfBytes.lengthInBytes / 1024).toStringAsFixed(1)} KB · 2 Pages · Ready',
                              style: GoogleFonts.inter(fontSize: 11, color: AgriCastTheme.primaryMed),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Your browser download has been initiated. You can also view or print the document directly.',
                  style: GoogleFonts.inter(fontSize: 12, color: AgriCastTheme.textMuted),
                ),
              ],
            ),
            actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close'),
              ),
              OutlinedButton.icon(
                onPressed: () async {
                  await Printing.layoutPdf(
                    onLayout: (_) async => pdfBytes,
                    name: fileName,
                  );
                },
                icon: const Icon(Icons.visibility_rounded, size: 16),
                label: const Text('Preview & Print'),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  await launchUrl(
                    Uri.parse(downloadUrl),
                    mode: LaunchMode.externalApplication,
                  );
                },
                icon: const Icon(Icons.download_rounded, size: 16),
                label: const Text('Direct Download'),
              ),
            ],
          ),
        );
    } catch (e) {
      setState(() => _error = 'Report generation failed: $e');
    }

    setState(() => _generating = false);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final rec = state.recommendation;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('PDF Report Generator',
                    style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('Export a professional AgriCAST report with crop rankings, explanations, and climate data.',
                    style: GoogleFonts.inter(fontSize: 13, color: AgriCastTheme.textSecondary)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          if (_error != null) ...[
            ErrorBanner(message: _error!),
            const SizedBox(height: 16),
          ],

          LayoutBuilder(builder: (_, constraints) {
            final isWide = constraints.maxWidth > 700;
            final config = _ReportConfig(
              rec: rec,
              includeScenario: _includeScenario,
              onIncludeScenarioChanged: (v) => setState(() => _includeScenario = v),
              generating: _generating,
              onGenerate: () => _generateReport(context),
            );
            final preview = _ReportPreview(rec: rec);
            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 340, child: config),
                  const SizedBox(width: 20),
                  Expanded(child: preview),
                ],
              );
            }
            return Column(children: [
              config,
              const SizedBox(height: 20),
              preview,
            ]);
          }),
        ],
      ),
    );
  }
}

class _ReportConfig extends StatelessWidget {
  final RecommendationResult? rec;
  final bool includeScenario, generating;
  final ValueChanged<bool> onIncludeScenarioChanged;
  final VoidCallback onGenerate;

  const _ReportConfig({
    required this.rec, required this.includeScenario,
    required this.generating, required this.onIncludeScenarioChanged,
    required this.onGenerate,
  });

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Report Configuration',
              style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),

          if (rec != null) ...[
            _ConfigItem(label: 'District', value: rec!.districtName),
            _ConfigItem(label: 'State', value: rec!.stateName),
            _ConfigItem(label: 'Year', value: rec!.year.toString()),
            _ConfigItem(label: 'Top Crop', value: rec!.topCrop),
            _ConfigItem(label: 'Confidence', value: '${rec!.topConfidence.toStringAsFixed(1)}%'),
          ] else
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF9C3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, size: 16, color: AgriCastTheme.warning),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Generate a recommendation on the Dashboard first.',
                      style: GoogleFonts.inter(fontSize: 12, color: AgriCastTheme.warning))),
                ],
              ),
            ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),

          Text('Report Contents', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          ...[
            ('Crop Rankings Table', true),
            ('Confidence Scores', true),
            ('AI Explanation', true),
            ('Climate Summary', true),
            ('Feature Influences', true),
          ].map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(Icons.check_circle_rounded, size: 16, color: AgriCastTheme.success),
                const SizedBox(width: 8),
                Text(item.$1, style: GoogleFonts.inter(fontSize: 13)),
              ],
            ),
          )),

          SwitchListTile(
            title: Text('Include Scenario Analysis',
                style: GoogleFonts.inter(fontSize: 13)),
            subtitle: Text('Adds scenario comparison if available',
                style: GoogleFonts.inter(fontSize: 11, color: AgriCastTheme.textMuted)),
            value: includeScenario,
            onChanged: onIncludeScenarioChanged,
            activeTrackColor: AgriCastTheme.primary,
            contentPadding: EdgeInsets.zero,
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: (rec == null || generating) ? null : onGenerate,
              icon: generating
                  ? const SizedBox(width: 16, height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.picture_as_pdf_rounded, size: 18),
              label: Text(generating ? 'Generating...' : 'Export PDF Report'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: rec == null
                  ? null
                  : () async {
                      final downloadUrl = ApiService.reportDownloadUrl(
                        rec!.districtId,
                        rec!.year,
                        includeScenario: includeScenario,
                      );
                      await launchUrl(
                        Uri.parse(downloadUrl),
                        mode: LaunchMode.externalApplication,
                      );
                    },
              icon: const Icon(Icons.file_download_outlined, size: 18),
              label: const Text('Instant Browser Download'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfigItem extends StatelessWidget {
  final String label, value;
  const _ConfigItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: GoogleFonts.inter(
                fontSize: 12, color: AgriCastTheme.textMuted)),
          ),
          Expanded(
            child: Text(value, style: GoogleFonts.inter(
                fontSize: 13, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

class _ReportPreview extends StatelessWidget {
  final RecommendationResult? rec;
  const _ReportPreview({required this.rec});

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Report Preview', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          // Mock PDF preview
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AgriCastTheme.border),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                // Header mock
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: AgriCastTheme.primaryDark,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(7),
                      topRight: Radius.circular(7),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.eco_rounded, color: AgriCastTheme.accent, size: 16),
                      const SizedBox(width: 8),
                      Text('AgriCAST', style: GoogleFonts.inter(
                          color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                      const Spacer(),
                      Text(rec != null ? '${rec!.districtName}  ·  ${rec!.year}' : 'No data',
                          style: GoogleFonts.inter(
                              color: Colors.white.withValues(alpha: 0.7), fontSize: 11)),
                    ],
                  ),
                ),
                // Content mock
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Crop Recommendation Report',
                          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700,
                              color: AgriCastTheme.primaryDark)),
                      Text(rec != null
                          ? '${rec!.districtName}, ${rec!.stateName}  ·  ${rec!.year}'
                          : '—',
                          style: GoogleFonts.inter(fontSize: 12, color: AgriCastTheme.textMuted)),
                      const SizedBox(height: 12),
                      if (rec != null) ...[
                        // Mock summary box
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AgriCastTheme.surface,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AgriCastTheme.borderGreen),
                          ),
                          child: Row(
                            children: [
                              Text(emojiForCrop(rec!.topCrop),
                                  style: const TextStyle(fontSize: 24)),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(rec!.topCrop, style: GoogleFonts.inter(
                                      fontSize: 15, fontWeight: FontWeight.w700,
                                      color: AgriCastTheme.primaryDark)),
                                  Text('Confidence: ${rec!.topConfidence.toStringAsFixed(1)}%',
                                      style: GoogleFonts.inter(
                                          fontSize: 12, color: AgriCastTheme.primaryMed)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Mock rankings preview
                        ...rec!.rankings.take(3).map((r) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              Text('#${r.rank}', style: GoogleFonts.inter(
                                  fontSize: 12, fontWeight: FontWeight.w600,
                                  color: AgriCastTheme.textGreen)),
                              const SizedBox(width: 10),
                              Text(r.crop, style: GoogleFonts.inter(fontSize: 12)),
                              const Spacer(),
                              Text('${r.confidence.toStringAsFixed(1)}%',
                                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        )),
                        const SizedBox(height: 4),
                        Text('... and more sections',
                            style: GoogleFonts.inter(fontSize: 11, color: AgriCastTheme.textMuted,
                                fontStyle: FontStyle.italic)),
                      ] else
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Text('Generate a recommendation to preview the report.'),
                          ),
                        ),
                    ],
                  ),
                ),
                // Footer mock
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: const BoxDecoration(
                    color: AgriCastTheme.surface,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(7),
                      bottomRight: Radius.circular(7),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text('AgriCAST v1.0 · Confidential',
                          style: GoogleFonts.inter(fontSize: 9, color: AgriCastTheme.textMuted)),
                      const Spacer(),
                      Text('Page 1',
                          style: GoogleFonts.inter(fontSize: 9, color: AgriCastTheme.textMuted)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
