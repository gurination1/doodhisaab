const kPostHogApiKey = String.fromEnvironment(
  'POSTHOG_API_KEY',
  defaultValue: '',
);
const kPostHogHost = String.fromEnvironment(
  'POSTHOG_HOST',
  defaultValue: 'https://us.i.posthog.com',
);
const kPostHogSessionReplay = bool.fromEnvironment(
  'POSTHOG_SESSION_REPLAY',
  defaultValue: false,
);
const kPostHogSessionReplaySampleRate = String.fromEnvironment(
  'POSTHOG_SESSION_REPLAY_SAMPLE_RATE',
  defaultValue: '0',
);
