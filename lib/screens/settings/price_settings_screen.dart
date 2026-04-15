import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/services/analytics_service.dart';
import '../../db/price_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../models/price_history.dart';
import '../../theme/app_theme.dart';
import '../../widgets/numpad.dart';

/// Step 14 — Pricing Engine UI.
///
/// Architecture notes:
///  - NumpadWidget for price entry — no system keyboard for the amount field.
///  - Note field uses system keyboard (text, not number).
///  - setPrice() inserts a NEW row — historical delivery rows are NEVER recomputed.
///  - Save is disabled when amount == 0 OR amount == currentPrice (prevents
///    duplicate history rows and nonsensical zero-price entries).
///  - isPriceStale() check runs on load and after save (amber banner).
///  - History list uses FutureBuilder — main isolate, no Isolate.run.
///  - Newest history row is at the top (repository orders DESC).
class PriceSettingsScreen extends StatefulWidget {
  const PriceSettingsScreen({super.key});

  @override
  State<PriceSettingsScreen> createState() => _PriceSettingsScreenState();
}

class _PriceSettingsScreenState extends State<PriceSettingsScreen> {
  // ── Repo ───────────────────────────────────────────────────────────────────
  final _priceRepo = PriceRepository();

  // ── Load state ─────────────────────────────────────────────────────────────
  bool _loading = true;

  // ── Current price ──────────────────────────────────────────────────────────
  PriceHistory? _currentRow;
  bool _isStale = false;

  // ── Entry state ────────────────────────────────────────────────────────────
  String _numpadValue = '';
  bool _saving = false;

  // ── History future (rebuilt after each save) ────────────────────────────────
  late Future<List<PriceHistory>> _historyFuture;

  // ── Note ───────────────────────────────────────────────────────────────────
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  // ── Init ────────────────────────────────────────────────────────────────────

  Future<void> _load() async {
    final row = await _priceRepo.getCurrentPriceRow();
    final stale = await _priceRepo.isPriceStale(days: 30);
    final hist = _priceRepo.getHistory();
    if (!mounted) return;
    setState(() {
      _currentRow = row;
      _isStale = stale;
      _historyFuture = hist;
      _loading = false;
    });
  }

  // ── Save ────────────────────────────────────────────────────────────────────

  Future<void> _doSave() async {
    if (_saving) return;
    final amount = double.tryParse(_numpadValue);
    if (amount == null || amount <= 0) return;
    setState(() => _saving = true);
    await AnalyticsService.instance.trackButtonClicked(
      buttonName: 'change_price',
      screenName: 'Price Settings',
      routeName: '/settings/price',
      elementType: 'button',
      elementText: 'Save Price',
    );
    HapticFeedback.selectionClick();

    final note = _noteController.text.trim().isEmpty
        ? null
        : _noteController.text.trim();

    await _priceRepo.setPrice(amount, note: note);

    // Reload current price card + history + stale check
    final row = await _priceRepo.getCurrentPriceRow();
    final stale = await _priceRepo.isPriceStale(days: 30);
    if (!mounted) return;

    setState(() {
      _currentRow = row;
      _isStale = stale;
      _historyFuture = _priceRepo.getHistory();
      _numpadValue = '';
      _saving = false;
    });
    _noteController.clear();
    await AnalyticsService.instance.trackFeatureUsed(
      featureName: 'price_update',
      screenName: 'Price Settings',
      routeName: '/settings/price',
      amount: amount,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.priceSaved),
        backgroundColor: kGreen,
        duration: Duration(seconds: 2),
      ),
    );
  }

  // ── Derived ─────────────────────────────────────────────────────────────────

  double? get _amount => double.tryParse(_numpadValue);

  /// Save disabled when:
  ///  - already saving
  ///  - amount is 0 / empty / non-parseable
  ///  - amount is identical to current price (would create a duplicate history row)
  bool get _canSave {
    if (_saving) return false;
    final a = _amount;
    if (a == null || a <= 0) return false;
    if (_currentRow != null && a == _currentRow!.pricePerLiter) return false;
    return true;
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: kCream,
      appBar: AppBar(
        backgroundColor: kCream,
        elevation: 0,
        centerTitle: true,
        title: Text(
          l10n.priceSettingsTitle,
          style: TextStyle(
            color: kInkBlack,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: const BackButton(color: kInkBlack),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: kGreen))
          : _saving
              ? const Center(child: CircularProgressIndicator(color: kGreen))
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // ── Current price card ──────────────────────────────────
                      _CurrentPriceCard(
                        row: _currentRow,
                        isStale: _isStale,
                      ),
                      const SizedBox(height: 24),

                      // ── Set new price section ───────────────────────────────
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(l10n.newPriceLabel, style: kLabelStyle),
                      ),
                      const SizedBox(height: 8),

                      // Amount display — read-only, NumpadWidget provides input
                      _PriceDisplay(numpadValue: _numpadValue),
                      const SizedBox(height: 16),

                      // Custom numpad — no system keyboard for price entry
                      NumpadWidget(
                        value: _numpadValue,
                        onChanged: (v) => setState(() => _numpadValue = v),
                      ),
                      const SizedBox(height: 20),

                      // Note — system keyboard (text, not number)
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(l10n.optionalNoteLabel, style: kLabelStyle),
                      ),
                      const SizedBox(height: 8),
                      _NoteField(controller: _noteController),
                      const SizedBox(height: 24),

                      // Save button — disabled when canSave is false
                      SizedBox(
                        height: kButtonHeight,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _canSave ? _doSave : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kGreen,
                            disabledBackgroundColor: kSurfaceGray,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            l10n.btnSave,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _canSave ? kWhite : kMutedGray,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),
                      const Divider(color: kSurfaceGray),
                      const SizedBox(height: 16),

                      // ── Price history list ──────────────────────────────────
                      Align(
                        alignment: Alignment.centerRight,
                        child:
                            Text(l10n.priceHistoryTitle, style: kHeadlineStyle),
                      ),
                      const SizedBox(height: 12),

                      FutureBuilder<List<PriceHistory>>(
                        future: _historyFuture,
                        builder: (context, snap) {
                          if (snap.connectionState == ConnectionState.waiting) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 32),
                              child: Center(
                                child: CircularProgressIndicator(color: kGreen),
                              ),
                            );
                          }
                          final history = snap.data ?? [];
                          if (history.isEmpty) {
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 32),
                              child: Center(
                                child: Text(
                                  l10n.noPriceYet,
                                  style: TextStyle(
                                    color: kMutedGray,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            );
                          }
                          return ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: history.length,
                            separatorBuilder: (_, __) =>
                                const Divider(color: kSurfaceGray, height: 1),
                            itemBuilder: (_, i) =>
                                _HistoryRow(entry: history[i]),
                          );
                        },
                      ),
                    ],
                  ),
                ),
    );
  }
}

// ─── Current price card ────────────────────────────────────────────────────────

class _CurrentPriceCard extends StatelessWidget {
  final PriceHistory? row;
  final bool isStale;

  const _CurrentPriceCard({required this.row, required this.isStale});

  String _formatDate(String isoDate) {
    // isoDate = 'YYYY-MM-DD'
    final parts = isoDate.split('-');
    if (parts.length != 3) return isoDate;
    return '${parts[2]}/${parts[1]}/${parts[0]}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kSurfaceGray,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Label
          Text(l10n.currentPriceLabel, style: kLabelStyle),
          const SizedBox(height: 8),

          // Large price display
          if (row != null) ...[
            Text(
              l10n.pricePerLiterValue(row!.pricePerLiter.toStringAsFixed(2)),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: kInkBlack,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.priceDateLabel(_formatDate(row!.effectiveFrom)),
              style: kBodyStyle.copyWith(color: kMutedGray),
            ),
          ] else ...[
            Text(
              l10n.noPriceSet,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: kMutedGray,
              ),
            ),
          ],

          // Stale price banner
          if (isStale) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: kAmber.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: kAmber, width: 1),
              ),
              child: Row(
                textDirection: TextDirection.rtl,
                children: [
                  Icon(Icons.warning_amber, color: kAmber, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.priceStaleWarning,
                      style: TextStyle(
                        color: kAmber,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Price display ─────────────────────────────────────────────────────────────

/// Read-only price display box — NumpadWidget provides all input.
/// System keyboard MUST NOT appear here.
class _PriceDisplay extends StatelessWidget {
  final String numpadValue;
  const _PriceDisplay({required this.numpadValue});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasValue = numpadValue.isNotEmpty &&
        double.tryParse(numpadValue) != null &&
        double.parse(numpadValue) > 0;

    return Container(
      height: kInputHeight,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: hasValue ? kGreen : kMutedGray,
          width: hasValue ? 2 : 1,
        ),
      ),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          numpadValue.isEmpty
              ? l10n.pricePerLiterValue('0')
              : l10n.pricePerLiterValue(numpadValue),
          style: kTitleStyle.copyWith(
            color: numpadValue.isEmpty ? kMutedGray : kInkBlack,
          ),
        ),
      ),
    );
  }
}

// ─── Note field ────────────────────────────────────────────────────────────────

class _NoteField extends StatelessWidget {
  final TextEditingController controller;
  const _NoteField({required this.controller});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      height: kInputHeight,
      child: TextField(
        controller: controller,
        maxLines: 1,
        textAlign: TextAlign.start,
        textDirection: Directionality.of(context),
        style: const TextStyle(fontSize: 16, color: kInkBlack),
        decoration: InputDecoration(
          hintText: l10n.noteExamplePrice,
          hintStyle: const TextStyle(color: kMutedGray, fontSize: 16),
          hintTextDirection: Directionality.of(context),
          filled: true,
          fillColor: kWhite,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: kMutedGray),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: kMutedGray),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: kGreen, width: 2),
          ),
        ),
      ),
    );
  }
}

// ─── History row ───────────────────────────────────────────────────────────────

class _HistoryRow extends StatelessWidget {
  final PriceHistory entry;
  const _HistoryRow({required this.entry});

  String _formatDate(String isoDate) {
    final parts = isoDate.split('-');
    if (parts.length != 3) return isoDate;
    return '${parts[2]}/${parts[1]}/${parts[0]}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      height: kListRowHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            // Right: price (RTL — main info on right)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10n.pricePerLiterValue(
                      entry.pricePerLiter.toStringAsFixed(2),
                    ),
                    style: kBodyStyle.copyWith(
                      fontWeight: FontWeight.w600,
                      color: kInkBlack,
                    ),
                  ),
                  if (entry.note != null && entry.note!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      entry.note!,
                      textDirection: TextDirection.rtl,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: kBodyStyle.copyWith(
                        color: kMutedGray,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 16),

            // Left: date
            Text(
              _formatDate(entry.effectiveFrom),
              style: const TextStyle(
                fontSize: 14,
                color: kMutedGray,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
