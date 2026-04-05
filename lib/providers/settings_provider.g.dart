// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$languageHash() => r'67897764ce5cabc40aae62ff322210fd88d021b0';

/// Current app language code ('ur' | 'en' | 'pa').
///
/// Defaults to 'ur' (set in SettingsRepository).
/// Used to drive [MaterialApp.locale] — watch this in app.dart when implementing
/// the language toggle in Settings (Step 24).
///
/// After the user changes language:
/// ```dart
/// await SettingsRepository.instance.setLanguage(code);
/// ref.invalidate(languageProvider);
/// ```
///
/// Copied from [language].
@ProviderFor(language)
final languageProvider = AutoDisposeFutureProvider<String>.internal(
  language,
  name: r'languageProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$languageHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LanguageRef = AutoDisposeFutureProviderRef<String>;
String _$outdoorModeHash() => r'5599f2c768d5fd7df31bf00aa788a8c167d2cef8';

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
///
/// Copied from [outdoorMode].
@ProviderFor(outdoorMode)
final outdoorModeProvider = AutoDisposeFutureProvider<bool>.internal(
  outdoorMode,
  name: r'outdoorModeProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$outdoorModeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OutdoorModeRef = AutoDisposeFutureProviderRef<bool>;
String _$deviceIdHash() => r'0cf8d2169ebfb2abba61bea7c9b7be1897e880db';

/// Persistent device identifier (UUID v4, generated once on first launch).
///
/// Used as [created_by_device] on all delivery and payment rows.
/// Never changes for the lifetime of the app install.
///
/// Copied from [deviceId].
@ProviderFor(deviceId)
final deviceIdProvider = AutoDisposeFutureProvider<String>.internal(
  deviceId,
  name: r'deviceIdProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$deviceIdHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DeviceIdRef = AutoDisposeFutureProviderRef<String>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
