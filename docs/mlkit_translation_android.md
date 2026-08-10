# Android on-device food-name translation

Fitora uses Google ML Kit On-Device Translation on Android to translate an
unknown parsed Persian food name to English before searching USDA FoodData
Central.

## Privacy and configuration

- Translation runs on the Android device. It does not use Google Cloud
  Translation, scrape Google Translate, require a translation API key, or
  require Cloud Billing.
- Only the parsed food name is translated. Quantities, units, diaries, profile
  data, nutrition history, workout history, and device identifiers are not sent.
- The local and custom Persian food databases always run first. A local match
  bypasses translation and USDA completely.
- USDA remains optional and still requires `USDA_API_KEY` through
  `--dart-define`. Without it, Fitora uses only its local database.

## First use and offline behavior

The Persian and English ML Kit language models are downloaded lazily when the
first unknown food needs translation. The download requires internet access and
uses some device storage (language models are typically tens of megabytes).
Concurrent requests share the same model download. After download, translation
works offline and translator resources are closed with the Android activity.

Successful translations are cached locally in Hive for 180 days. Failed
translations are not cached. A saved user correction replaces the generated
translation for the same normalized Persian food name.

## Accuracy and fallbacks

ML Kit translation quality can be imperfect, especially for Iranian dishes and
regional food names. USDA is primarily English-focused and may still return
several candidates or no useful match. Users can edit the English query, save a
correction for future searches, select a USDA candidate, or enter nutrition
manually.

This implementation is Android-only. No Web, iOS, macOS, Windows, or Linux
translation implementation or fallback is included.
