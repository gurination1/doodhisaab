import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:path/path.dart' as p;

import '../../services/backup_service.dart';
import '../../theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// BackupScreen
//
// Shows a "بیک اپ لیں" button that calls BackupService.backupNow(), then lists
// the existing .db backups from Downloads/DoodHisaab/ in reverse-chron order.
//
// BackupService prunes to 7 backups automatically after each backup — the list
// never shows more than 7 rows.
//
// Auto-backup is handled by WorkManager (callbackDispatcher); this screen only
// triggers a manual backup and shows what's on disk.
// ─────────────────────────────────────────────────────────────────────────────

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  List<File> _backups = [];
  bool _listLoading = true;
  bool _backing = false;

  @override
  void initState() {
    super.initState();
    _loadBackups();
  }

  // ── Load existing backups from disk ─────────────────────────────────────────

  Future<void> _loadBackups() async {
    setState(() => _listLoading = true);
    try {
      final dir = await BackupService.getBackupDir();
      final files = dir
          .listSync()
          .whereType<File>()
          .where((f) => p.extension(f.path) == '.db')
          .toList()
        // Reverse-chrono: newest first (ISO-prefixed names sort correctly).
        ..sort((a, b) => p.basename(b.path).compareTo(p.basename(a.path)));
      if (mounted) {
        setState(() {
          _backups = files;
          _listLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _backups = [];
          _listLoading = false;
        });
      }
    }
  }

  // ── Manual backup ────────────────────────────────────────────────────────────

  Future<void> _runBackup() async {
    setState(() => _backing = true);
    try {
      final file = await BackupService.backupNow();
      await _loadBackups();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'بیک اپ محفوظ: ${p.basename(file.path)}',
              textDirection: TextDirection.rtl,
            ),
            backgroundColor: kGreen,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'بیک اپ ناکام ہوا',
              textDirection: TextDirection.rtl,
            ),
            backgroundColor: kAlertRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _backing = false);
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  /// Parses `doodhisaab_YYYYMMDD_HHmm.db` → human-readable date+time string.
  String _formatBackupDate(File file) {
    try {
      // basenameWithoutExtension → 'doodhisaab_20260403_1430'
      final name  = p.basenameWithoutExtension(file.path);
      final parts = name.split('_'); // ['doodhisaab', '20260403', '1430']
      if (parts.length >= 3) {
        final d = parts[1]; // '20260403'
        final t = parts[2]; // '1430'
        final dt = DateTime(
          int.parse(d.substring(0, 4)),
          int.parse(d.substring(4, 6)),
          int.parse(d.substring(6, 8)),
          int.parse(t.substring(0, 2)),
          int.parse(t.substring(2, 4)),
        );
        return intl.DateFormat('dd MMM yyyy — HH:mm').format(dt);
      }
    } catch (_) {}
    return p.basename(file.path);
  }

  String _formatSize(File file) {
    try {
      final bytes = file.lengthSync();
      if (bytes < 1024)        return '$bytes B';
      if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } catch (_) {
      return '';
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCream,
      appBar: AppBar(
        backgroundColor: kCream,
        elevation: 0,
        leading: const BackButton(color: kInkBlack),
        centerTitle: true,
        title: const Text(
          'بیک اپ',
          textDirection: TextDirection.rtl,
          style: TextStyle(
            color: kInkBlack,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [

          // ── Backup now button ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: SizedBox(
              width: double.infinity,
              height: kConfirmButtonHeight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _backing ? kSurfaceGray : kGreen,
                  foregroundColor: kWhite,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _backing ? null : _runBackup,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  textDirection: TextDirection.rtl,
                  children: [
                    if (_backing)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: kGreen,
                        ),
                      )
                    else
                      const Icon(Icons.backup_outlined, size: 24, color: kWhite),
                    const SizedBox(width: 10),
                    Text(
                      _backing ? 'محفوظ ہو رہا ہے...' : 'بیک اپ لیں',
                      textDirection: TextDirection.rtl,
                      style: kBodyStyle.copyWith(
                        color: _backing ? kMutedGray : kWhite,
                        fontWeight: FontWeight.w600,
                        fontSize: 17,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Auto-backup badge ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: kSurfaceGray,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  textDirection: TextDirection.rtl,
                  children: [
                    const Icon(Icons.schedule, size: 14, color: kMittiBrown),
                    const SizedBox(width: 5),
                    Text(
                      'آٹو بیک اپ: روزانہ',
                      textDirection: TextDirection.rtl,
                      style: kLabelStyle.copyWith(color: kMittiBrown),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── Section header ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 2),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                'محفوظ شدہ بیک اپ',
                textDirection: TextDirection.rtl,
                style: kLabelStyle.copyWith(
                  color: kMittiBrown,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),

          // ── Backup list ────────────────────────────────────────────────────
          Expanded(
            child: _listLoading
                ? const Center(
                    child: CircularProgressIndicator(color: kGreen),
                  )
                : _backups.isEmpty
                    ? Center(
                        child: Text(
                          'کوئی بیک اپ نہیں',
                          textDirection: TextDirection.rtl,
                          style: kBodyStyle.copyWith(color: kMutedGray),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _backups.length,
                        // Max 7 backups (pruneOldBackups) — itemExtent still
                        // eliminates measurement overhead and keeps height stable.
                        itemExtent: kListRowHeight,
                        itemBuilder: (context, i) {
                          final file     = _backups[i];
                          final isLatest = i == 0;
                          return Container(
                            height: kListRowHeight,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom:
                                    BorderSide(color: kSurfaceGray, width: 1),
                              ),
                            ),
                            child: Row(
                              textDirection: TextDirection.rtl,
                              children: [
                                Icon(
                                  Icons.storage_rounded,
                                  color: isLatest ? kGreen : kMutedGray,
                                  size: 22,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.end,
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _formatBackupDate(file),
                                        textDirection: TextDirection.ltr,
                                        style: kBodyStyle.copyWith(
                                          fontWeight: FontWeight.w500,
                                          color: kInkBlack,
                                        ),
                                      ),
                                      Text(
                                        _formatSize(file),
                                        textDirection: TextDirection.ltr,
                                        style: kLabelStyle.copyWith(
                                          color: kMutedGray,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isLatest) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: kGreen.withOpacity(0.12),
                                      borderRadius:
                                          BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      'تازہ',
                                      textDirection: TextDirection.rtl,
                                      style: kLabelStyle.copyWith(
                                        color: kGreen,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
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
