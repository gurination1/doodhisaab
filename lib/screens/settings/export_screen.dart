import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:path/path.dart' as p;

import '../../core/services/analytics_service.dart';
import '../../l10n/app_localizations.dart';
import '../../services/csv_export_service.dart';
import '../../services/share_service.dart';
import '../../theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ExportScreen
//
// Lets the user pick a date range and export all farm data to CSV.
// After export, calls ShareService.shareFile() → system share sheet.
// The file is also saved to Downloads/DoodHisaab/ (handled by CsvExportService).
//
// Default range: first day of current month → today.
// ─────────────────────────────────────────────────────────────────────────────

class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key});

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  late DateTime _from;
  late DateTime _to;
  bool _exporting = false;
  File? _lastFile;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _from = DateTime(now.year, now.month, 1);
    _to = DateTime(now.year, now.month, now.day);
  }

  // ── Date pickers ─────────────────────────────────────────────────────────────

  Future<void> _pickFrom() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _from,
      firstDate: DateTime(2020),
      lastDate: _to,
      builder: _calendarTheme,
    );
    if (picked != null && mounted) {
      setState(() {
        _from = picked;
        _lastFile = null;
      });
    }
  }

  Future<void> _pickTo() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _to,
      firstDate: _from,
      lastDate: DateTime.now(),
      builder: _calendarTheme,
    );
    if (picked != null && mounted) {
      setState(() {
        _to = picked;
        _lastFile = null;
      });
    }
  }

  Widget _calendarTheme(BuildContext ctx, Widget? child) {
    return Theme(
      data: Theme.of(ctx).copyWith(
        colorScheme: const ColorScheme.light(
          primary: kGreen,
          onPrimary: kWhite,
          onSurface: kInkBlack,
        ),
      ),
      child: child!,
    );
  }

  // ── Export ────────────────────────────────────────────────────────────────────

  Future<void> _exportAndShare() async {
    final l10n = AppLocalizations.of(context)!;
    await AnalyticsService.instance.trackButtonClicked(
      buttonName: 'export_csv',
      screenName: 'Export',
      routeName: '/settings/export',
      elementType: 'button',
      elementText: 'Export CSV',
    );
    setState(() {
      _exporting = true;
      _lastFile = null;
    });
    try {
      final file = await CsvExportService.exportAll(from: _from, to: _to);
      if (mounted) setState(() => _lastFile = file);
      await AnalyticsService.instance.trackFeatureUsed(
        featureName: 'backup_export',
        screenName: 'Export',
        routeName: '/settings/export',
      );
      await ShareService.shareFile(file);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.exportFailed),
            backgroundColor: kAlertRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final fmt = intl.DateFormat('dd MMM yyyy');

    return Scaffold(
      backgroundColor: kCream,
      appBar: AppBar(
        backgroundColor: kCream,
        elevation: 0,
        leading: const BackButton(color: kInkBlack),
        centerTitle: true,
        title: Text(
          l10n.exportTitle,
          style: TextStyle(
            color: kInkBlack,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Date range section ───────────────────────────────────────────
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                l10n.exportDateRange,
                style: kLabelStyle.copyWith(
                  color: kMittiBrown,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: _DateTile(
                    label: l10n.exportFrom,
                    value: fmt.format(_from),
                    onTap: _exporting ? null : _pickFrom,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DateTile(
                    label: l10n.exportTo,
                    value: fmt.format(_to),
                    onTap: _exporting ? null : _pickTo,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ── Content info ─────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: kSurfaceGray,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    l10n.exportIncludes,
                    style: kLabelStyle.copyWith(
                      color: kInkBlack,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  for (final item in [
                    l10n.exportIncludesDeliveries,
                    l10n.exportIncludesPayments,
                    l10n.exportIncludesExpenses,
                    l10n.exportIncludesOtherIncome,
                  ])
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Row(
                        children: [
                          const Icon(Icons.check, size: 14, color: kGreen),
                          const SizedBox(width: 6),
                          Text(
                            item,
                            style: kLabelStyle.copyWith(color: kMutedGray),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            const Spacer(),

            // ── Last exported file indicator ──────────────────────────────────
            if (_lastFile != null) ...[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: kGreen.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: kGreen.withOpacity(0.3)),
                ),
                child: Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    const Icon(Icons.check_circle_outline,
                        color: kGreen, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        p.basename(_lastFile!.path),
                        textDirection: TextDirection.ltr,
                        style: kLabelStyle.copyWith(
                          color: kGreen,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // ── Export + share button ─────────────────────────────────────────
            SizedBox(
              height: kConfirmButtonHeight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _exporting ? kSurfaceGray : kGreen,
                  foregroundColor: kWhite,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _exporting ? null : _exportAndShare,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_exporting)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: kGreen,
                        ),
                      )
                    else
                      const Icon(Icons.file_download, size: 24, color: kWhite),
                    const SizedBox(width: 10),
                    Text(
                      _exporting
                          ? l10n.exportPreparing
                          : l10n.exportCreateShare,
                      style: kBodyStyle.copyWith(
                        color: _exporting ? kMutedGray : kWhite,
                        fontWeight: FontWeight.w600,
                        fontSize: 17,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            Center(
              child: Text(
                l10n.exportSavedNotice,
                style: kLabelStyle.copyWith(color: kMutedGray),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _DateTile — tappable tile showing label + formatted date value.
// Used for the From / To date range pickers.
// ─────────────────────────────────────────────────────────────────────────────

class _DateTile extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _DateTile({
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kSurfaceGray,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          height: kInputHeight,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: kLabelStyle.copyWith(color: kMittiBrown),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                textDirection: TextDirection.ltr,
                style: kBodyStyle.copyWith(
                  fontWeight: FontWeight.w600,
                  color: kInkBlack,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
