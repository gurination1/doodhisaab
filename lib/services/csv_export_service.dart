import 'dart:io';

import 'package:path/path.dart' as p;

import '../db/db_provider.dart';
import 'backup_service.dart';

/// Exports all farm data to a single CSV file with 4 sections.
///
/// Sections: Deliveries → Payments → Expenses → Other Income.
/// Each section has a header row + data rows, separated by a blank line.
///
/// All amounts are plain numbers — no currency prefix — so the file opens
/// cleanly in Excel / Sheets.
///
/// Customer names are resolved via a single SQL JOIN per section (not N+1
/// per-row queries).
class CsvExportService {
  CsvExportService._();

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Exports records between [from] and [to] (inclusive) to a dated CSV file.
  ///
  /// Returns the written [File]. Saved to the same public Downloads/DoodHisaab/
  /// directory used by [BackupService].
  static Future<File> exportAll({
    required DateTime from,
    required DateTime to,
  }) async {
    final db = await DatabaseProvider.database;

    final fromStr = _dateStr(from);
    final toStr   = _dateStr(to);

    final buf = StringBuffer();

    // ── Section 1: Deliveries ─────────────────────────────────────────────────
    buf.writeln('DELIVERIES');
    buf.writeln(_row(['date', 'customer_name', 'liters', 'price_per_liter', 'total_value', 'status']));

    final delivRows = await db.rawQuery(
      '''
      SELECT d.date, c.name AS customer_name,
             d.liters, d.price_per_liter, d.total_value, d.status
      FROM deliveries d
      JOIN customers c ON c.customer_id = d.customer_id
      WHERE d.date >= ? AND d.date <= ?
        AND d.status = 'confirmed'
      ORDER BY d.date ASC, c.name ASC
      ''',
      [fromStr, toStr],
    );
    for (final r in delivRows) {
      buf.writeln(_row([
        r['date'],
        r['customer_name'],
        _num(r['liters']),
        _num(r['price_per_liter']),
        _num(r['total_value']),
        r['status'],
      ]));
    }
    buf.writeln(); // blank line between sections

    // ── Section 2: Payments ───────────────────────────────────────────────────
    buf.writeln('PAYMENTS');
    buf.writeln(_row(['date', 'customer_name', 'amount', 'note']));

    final payRows = await db.rawQuery(
      '''
      SELECT p.date, c.name AS customer_name, p.amount, p.note
      FROM payments p
      JOIN customers c ON c.customer_id = p.customer_id
      WHERE p.date >= ? AND p.date <= ?
      ORDER BY p.date ASC, c.name ASC
      ''',
      [fromStr, toStr],
    );
    for (final r in payRows) {
      buf.writeln(_row([
        r['date'],
        r['customer_name'],
        _num(r['amount']),
        r['note'] ?? '',
      ]));
    }
    buf.writeln();

    // ── Section 3: Expenses ───────────────────────────────────────────────────
    buf.writeln('EXPENSES');
    buf.writeln(_row(['date', 'category', 'amount', 'note']));

    final expRows = await db.rawQuery(
      '''
      SELECT date, category, amount, note
      FROM expenses
      WHERE date >= ? AND date <= ?
      ORDER BY date ASC
      ''',
      [fromStr, toStr],
    );
    for (final r in expRows) {
      buf.writeln(_row([
        r['date'],
        r['category'],
        _num(r['amount']),
        r['note'] ?? '',
      ]));
    }
    buf.writeln();

    // ── Section 4: Other Income ───────────────────────────────────────────────
    buf.writeln('OTHER INCOME');
    buf.writeln(_row(['date', 'category', 'amount', 'note']));

    final incRows = await db.rawQuery(
      '''
      SELECT date, category, amount, note
      FROM other_income
      WHERE date >= ? AND date <= ?
      ORDER BY date ASC
      ''',
      [fromStr, toStr],
    );
    for (final r in incRows) {
      buf.writeln(_row([
        r['date'],
        r['category'],
        _num(r['amount']),
        r['note'] ?? '',
      ]));
    }

    // ── Write file ─────────────────────────────────────────────────────────────
    final dir      = await BackupService.getBackupDir();
    final stamp    = _dateStamp(from);
    final file     = File(p.join(dir.path, 'doodhisaab_export_$stamp.csv'));
    await file.writeAsString(buf.toString(), flush: true);

    return file;
  }

  // ---------------------------------------------------------------------------
  // Internal helpers
  // ---------------------------------------------------------------------------

  /// Formats a [DateTime] as `YYYY-MM-DD` for SQL WHERE comparisons.
  static String _dateStr(DateTime dt) =>
      '${dt.year.toString().padLeft(4, '0')}'
      '-${dt.month.toString().padLeft(2, '0')}'
      '-${dt.day.toString().padLeft(2, '0')}';

  /// Formats a [DateTime] as `YYYYMMDD` for the export filename.
  static String _dateStamp(DateTime dt) =>
      '${dt.year.toString().padLeft(4, '0')}'
      '${dt.month.toString().padLeft(2, '0')}'
      '${dt.day.toString().padLeft(2, '0')}';

  /// Formats a numeric DB value as a plain decimal string (2dp).
  ///
  /// SQLite returns numeric columns as [int] or [double] depending on the
  /// stored value. This normalises both to a 2dp string without a currency
  /// prefix so the CSV opens cleanly in spreadsheet apps.
  static String _num(Object? value) {
    if (value == null) return '0.00';
    final d = (value as num).toDouble();
    return d.toStringAsFixed(2);
  }

  /// Encodes one CSV row.
  ///
  /// Fields containing commas, double-quotes, or newlines are wrapped in
  /// double-quotes; internal double-quotes are escaped as `""`.
  static String _row(List<Object?> fields) {
    return fields.map((f) {
      final s = (f ?? '').toString();
      if (s.contains(',') || s.contains('"') || s.contains('\n')) {
        return '"${s.replaceAll('"', '""')}"';
      }
      return s;
    }).join(',');
  }
}
