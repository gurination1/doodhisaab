import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../db/settings_repository.dart';

part 'settings_provider.g.dart';

// ── LANGUAGE ──────────────────────────────────────────────────────────────────

/// Current app language code ('en' | 'pa' | 'hi' | 'ur').
///
/// Defaults to 'en' (set in SettingsRepository).
/// Used to drive [MaterialApp.locale] — watch this in app.dart when implementing
/// the language toggle in Settings (Step 24).
///
/// After the user changes language:
/// ```dart
/// await SettingsRepository.instance.setLanguage(code);
/// ref.invalidate(languageProvider);
/// ```
@riverpod
Future<String> language(LanguageRef ref) =>
    SettingsRepository.instance.getLanguage();

// ── OUTDOOR MODE ──────────────────────────────────────────────────────────────

/// Whether outdoor/bright-sunlight mode is enabled.
///
/// When true, apply higher-contrast theme values (Step 24):
///   background: kWhite (#FFFFFF) instead of kCream
///   text:       #000000 instead of kInkBlack
///   button:     #155D38 instead of kGreen
///
/// NO ambient light sensor — Tecno Spark / Infinix Hot class devices don't have one.
/// Manual toggle only.
///
/// After the user toggles:
/// ```dart
/// await SettingsRepository.instance.setOutdoorMode(value);
/// ref.invalidate(outdoorModeProvider);
/// ```
@riverpod
Future<bool> outdoorMode(OutdoorModeRef ref) =>
    SettingsRepository.instance.getOutdoorMode();

final themeModeProvider = FutureProvider<String>((ref) {
  return SettingsRepository.instance.getThemeMode();
});

// ── DEVICE ID ─────────────────────────────────────────────────────────────────

/// Persistent device identifier (UUID v4, generated once on first launch).
///
/// Used as [created_by_device] on all delivery and payment rows.
/// Never changes for the lifetime of the app install.
@riverpod
Future<String> deviceId(DeviceIdRef ref) =>
    SettingsRepository.instance.getDeviceId();
