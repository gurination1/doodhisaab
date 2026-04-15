import 'package:posthog_flutter/posthog_flutter.dart';

import '../constants/analytics_constants.dart';

const kAnalyticsEnabled = bool.fromEnvironment(
  'ANALYTICS',
  defaultValue: bool.fromEnvironment('dart.vm.product'),
);

class AnalyticsService {
  AnalyticsService._();

  static final AnalyticsService instance = AnalyticsService._();

  bool _isInitialized = false;
  String? _currentScreenName;
  String? _currentRouteName;

  Future<void> init() async {
    if (!kAnalyticsEnabled || _isInitialized) return;
    if (kPostHogApiKey.isEmpty || kPostHogHost.isEmpty) return;

    try {
      final config = PostHogConfig(kPostHogApiKey);
      config.host = kPostHogHost;
      config.flushAt = 1;
      config.flushInterval = const Duration(seconds: 10);
      config.captureApplicationLifecycleEvents = false;
      config.sendFeatureFlagEvents = false;
      config.preloadFeatureFlags = false;
      config.surveys = false;
      config.personProfiles = PostHogPersonProfiles.identifiedOnly;
      config.debug = !const bool.fromEnvironment('dart.vm.product');
      config.sessionReplay = kPostHogSessionReplay;
      final sessionReplaySampleRate =
          double.tryParse(kPostHogSessionReplaySampleRate);
      if (sessionReplaySampleRate != null &&
          sessionReplaySampleRate > 0 &&
          sessionReplaySampleRate <= 1) {
        config.sessionReplayConfig.sampleRate = sessionReplaySampleRate;
      }
      config.errorTrackingConfig.inAppIncludes.add('package:doodhisaab');

      await Posthog().setup(config);
      _isInitialized = true;
      await trackEvent(
        'analytics_initialized',
        properties: {
          'host': kPostHogHost,
          'sdk': 'posthog_flutter',
        },
      );
    } catch (_) {
      // Analytics must never block or crash the app.
    }
  }

  Future<void> identifyUser(String distinctId) async {
    if (!_canTrack || distinctId.isEmpty) return;

    try {
      await Posthog().identify(
        userId: distinctId,
        userProperties: const {'identity_type': 'local_device'},
      );
    } catch (_) {
      // Analytics must never block or crash the app.
    }
  }

  Future<void> trackEvent(
    String name, {
    Map<String, Object?> properties = const {},
  }) async {
    if (!_canTrack || name.isEmpty) return;

    try {
      await Posthog().capture(
        eventName: name,
        properties: _cleanProperties(properties),
      );
    } catch (_) {
      // Analytics must never block or crash the app.
    }
  }

  Future<void> trackScreenView({
    required String screenName,
    required String routeName,
    String? screenClass,
    String? navigationSource,
  }) async {
    if (!_canTrack || screenName.isEmpty || routeName.isEmpty) return;

    _currentScreenName = screenName;
    _currentRouteName = routeName;

    try {
      await Posthog().screen(
        screenName: screenName,
        properties: _cleanProperties({
          'screen_name': screenName,
          'route_name': routeName,
          'screen_class': screenClass,
          'navigation_source': navigationSource,
        }),
      );
    } catch (_) {
      // Analytics must never block or crash the app.
    }
  }

  Future<void> trackButtonClicked({
    required String buttonName,
    required String screenName,
    required String routeName,
    required String elementType,
    String? elementText,
  }) {
    return trackEvent(
      'button_clicked',
      properties: {
        'button_name': buttonName,
        'screen_name': screenName,
        'route_name': routeName,
        'element_type': elementType,
        'element_text': elementText,
      },
    );
  }

  Future<void> trackFeatureUsed({
    required String featureName,
    String? screenName,
    String? routeName,
    String? customerId,
    String? paymentType,
    double? amount,
    double? liters,
  }) {
    return trackEvent(
      'feature_used',
      properties: {
        'feature_name': featureName,
        'screen_name': screenName ?? _currentScreenName,
        'route_name': routeName ?? _currentRouteName,
        'customer_id': customerId,
        'payment_type': paymentType,
        'amount': amount,
        'liters': liters,
      },
    );
  }

  Future<void> trackTimeSpent({
    required String screenName,
    required String routeName,
    required int durationMs,
    String? nextScreenName,
  }) {
    return trackEvent(
      'time_spent',
      properties: {
        'screen_name': screenName,
        'route_name': routeName,
        'duration_ms': durationMs,
        'time_spent_ms': durationMs,
        'next_screen_name': nextScreenName,
      },
    );
  }

  Future<void> reset() async {
    if (!kAnalyticsEnabled) return;

    try {
      await Posthog().reset();
    } catch (_) {
      // Analytics must never block or crash the app.
    }
  }

  bool get _canTrack =>
      kAnalyticsEnabled &&
      _isInitialized &&
      kPostHogApiKey.isNotEmpty &&
      kPostHogHost.isNotEmpty;

  Map<String, Object> _cleanProperties(Map<String, Object?> properties) {
    return Map<String, Object>.fromEntries(
      properties.entries
          .where(
            (entry) =>
                entry.value != null && '${entry.value}'.trim().isNotEmpty,
          )
          .map((entry) => MapEntry(entry.key, entry.value as Object)),
    );
  }
}
