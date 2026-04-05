import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import 'db_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Known keys in app_settings table.
//
//   device_id         — persistent UUID, generated once on first launch
//   language          — 'en' | 'pa' | 'hi' | 'ur'  (default: 'en')
//   app_version       — last recorded app version string
//   first_launch_done — '1' once onboarding wizard is completed
//   pin_hash          — SHA-256 of PIN string  (Step 17)
//   outdoor_mode      — '1' | '0'              (Step 24)
//   theme_mode        — 'system' | 'light' | 'dark'
// ─────────────────────────────────────────────────────────────────────────────

const _kDeviceId        = 'device_id';
const _kLanguage        = 'language';
const _kAppVersion      = 'app_version';
const _kFirstLaunchDone = 'first_launch_done';
const _kPinHash         = 'pin_hash';
const _kThemeMode       = 'theme_mode';

const _kTable = 'app_settings';

class SettingsRepository {
  SettingsRepository._();
  static final SettingsRepository instance = SettingsRepository._();

  // ── LOW-LEVEL HELPERS ──────────────────────────────────────────────────────

  Future<String?> _get(String key) async {
    final db = await DatabaseProvider.database;
    final rows = await db.query(
      _kTable,
      columns: ['value'],
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first['value'] as String?;
  }

  Future<void> _set(String key, String value) async {
    final db = await DatabaseProvider.database;
    await db.insert(
      _kTable,
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ── DEVICE ID ──────────────────────────────────────────────────────────────

  Future<String> getDeviceId() async {
    final existing = await _get(_kDeviceId);
    if (existing != null && existing.isNotEmpty) return existing;
    final newId = const Uuid().v4();
    await _set(_kDeviceId, newId);
    return newId;
  }

  // ── LANGUAGE ───────────────────────────────────────────────────────────────

  Future<String> getLanguage() async {
    return (await _get(_kLanguage)) ?? 'en';
  }

  Future<void> setLanguage(String languageCode) async {
    assert(
      ['en', 'pa', 'hi', 'ur'].contains(languageCode),
      'Unknown language code: $languageCode',
    );
    await _set(_kLanguage, languageCode);
  }

  // ── APP VERSION ────────────────────────────────────────────────────────────

  Future<String?> getAppVersion() async => _get(_kAppVersion);

  Future<void> setAppVersion(String version) async =>
      _set(_kAppVersion, version);

  // ── FIRST LAUNCH / ONBOARDING ──────────────────────────────────────────────

  /// Returns true once [markFirstLaunchDone] has been called.
  Future<bool> isFirstLaunchDone() async {
    return (await _get(_kFirstLaunchDone)) == '1';
  }

  Future<void> markFirstLaunchDone() async {
    await _set(_kFirstLaunchDone, '1');
  }

  // ── PIN SECURITY (Step 17) ─────────────────────────────────────────────────

  /// Returns the stored SHA-256 PIN hash, or null if no PIN has been set.
  ///
  /// Null means PIN is disabled — [LockScreen] routes directly to /home
  /// without showing the PIN pad. PIN is always optional in DoodHisaab.
  Future<String?> getPinHash() async => _get(_kPinHash);

  /// Hashes [plainPin] with SHA-256 and stores the hex digest.
  ///
  /// Called from the "PIN لگائیں / تبدیل کریں" flow in [SettingsScreen].
  Future<void> setPinHash(String plainPin) async {
    final digest = sha256.convert(utf8.encode(plainPin));
    await _set(_kPinHash, digest.toString());
  }

  /// Removes the PIN entirely. After clearing, [getPinHash] returns null and
  /// [LockScreen] skips the PIN pad on next cold start.
  Future<void> clearPin() async {
    final db = await DatabaseProvider.database;
    await db.delete(_kTable, where: 'key = ?', whereArgs: [_kPinHash]);
  }

  // ── OUTDOOR MODE (Step 24) ────────────────────────────────────────────────

  Future<bool> getOutdoorMode() async {
    return (await _get('outdoor_mode')) == '1';
  }

  Future<void> setOutdoorMode(bool enabled) =>
      _set('outdoor_mode', enabled ? '1' : '0');

  Future<String> getThemeMode() async {
    final mode = await _get(_kThemeMode);
    if (mode == null || !['system', 'light', 'dark'].contains(mode)) {
      return 'system';
    }
    return mode;
  }

  Future<void> setThemeMode(String mode) async {
    assert(
      ['system', 'light', 'dark'].contains(mode),
      'Unknown theme mode: $mode',
    );
    await _set(_kThemeMode, mode);
  }
}
