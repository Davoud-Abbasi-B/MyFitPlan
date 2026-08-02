# OpenAI local testing

This temporary direct-client integration is for private testing on a personal
device only. A key embedded in an APK cannot be fully protected. Replace the
direct API call with a backend before distributing the app publicly.

Replace the placeholder with a real key only in your local terminal, and never
save or commit that key in project files, logs, screenshots, or launch settings.

```sh
flutter run --dart-define=OPENAI_API_KEY=YOUR_KEY
flutter build apk --release --dart-define=OPENAI_API_KEY=YOUR_KEY
```

The optional model defaults to `gpt-5-mini` and can be changed at build time:

```sh
flutter run --dart-define=OPENAI_API_KEY=YOUR_KEY --dart-define=OPENAI_MODEL=MODEL_NAME
```

With no `OPENAI_API_KEY` define, Fitora uses its local mock food analyzer.
