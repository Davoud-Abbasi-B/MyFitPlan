# USDA FoodData Central local testing

Fitora uses its bundled Persian food database first. USDA FoodData Central is an optional fallback for foods that are not confidently matched locally.

## Obtain an API key

Create a FoodData Central API key from the official USDA FoodData Central website. Keep the key private and never commit it to source control.

## Build without a key

```sh
flutter build apk --release
```

The local Persian database, manual entry, saved custom foods, drafts, reports, and history continue to work without internet or a USDA key.

## Build with a key

```sh
flutter build apk --release --dart-define=USDA_API_KEY=YOUR_KEY
```

Replace `YOUR_KEY` only in your private local build command. Do not add a real key to this document, source files, Gradle files, or version control.

## Coverage and fallback

USDA coverage for Iranian mixed dishes can be limited. Fitora therefore uses curated local estimates for common Iranian foods and clearly labels them as approximate. If a food or portion cannot be resolved reliably, use the manual-entry option. Manual definitions can optionally be saved in “خوراکی‌های من” for future exact matches.

FoodData Central is credited as the source of online nutrient data: https://fdc.nal.usda.gov/
