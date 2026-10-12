Fitora v8 workout migration

Seed: v7 → v8.

Weekly schedule

| Day | Workout |
|---|---|
| Saturday / شنبه | Upper Body A |
| Sunday / یکشنبه | Lower Body A |
| Monday / دوشنبه | Rest |
| Tuesday / سه‌شنبه | Upper Body B |
| Wednesday / چهارشنبه | Lower Body B |
| Thursday / پنجشنبه | Rest |
| Friday / جمعه | Rest |

Wednesday is Lower Body B. Thursday is rest. Both dashboard and session UI use the shared Saturday-first calendar mapping.

**Upper Body A** — سینه + پشت مکمل + سرشانه میانی + بازو

| Order | Exercise | Sets × reps | RIR | Rest |
|---|---|---|---|---|
| 1 | Bench Press | 3 × 6-10 | 2 | 2-3 minutes |
| 2 | Incline Dumbbell Press | 3 × 8-12 | 1-2 | 2 minutes |
| 3 | Pec Deck | 3 × 12-15 | 1-2 | 60-90 seconds |
| 4 | Chest-Supported Row | 3 × 8-12 | 1-2 | 2 minutes |
| 5 | Dumbbell Lateral Raise | 4 × 12-20 | 1-2 | 60-90 seconds |
| 6 | Overhead Cable Triceps Extension | 3 × 10-15 | 1-2 | 60-90 seconds |
| 7 | Bayesian Cable Curl | 3 × 10-15 | 1-2 | 60-90 seconds |
| 8 | Reverse Curl | 3 × 10-15 | 1-2 | 60-90 seconds |

**Lower Body A** — چهارسر + همسترینگ مکمل + ساق

| Order | Exercise | Sets × reps | RIR | Rest |
|---|---|---|---|---|
| 1 | Smith Squat | 3 × 6-10 | 2 | 2-3 minutes |
| 2 | Leg Press | 3 × 8-12 | 1-2 | 2-3 minutes |
| 3 | Leg Extension | 3 × 10-15 | 1-2 | 60-90 seconds |
| 4 | Lying Leg Curl | 3 × 10-15 | 1-2 | 90 seconds |
| 5 | Standing Calf Raise | 3 × 10-15 | 1-2 | 60-90 seconds |

**Upper Body B** — پشت + سرشانه + سینه مکمل + بازو + کول

| Order | Exercise | Sets × reps | RIR | Rest |
|---|---|---|---|---|
| 1 | Assisted Pull-up | 3 × 6-10 | 1-2 | 2-3 minutes |
| 2 | Seated Row | 3 × 8-12 | 1-2 | 2 minutes |
| 3 | Dumbbell Shoulder Press | 3 × 6-10 | 2 | 2-3 minutes |
| 4 | Machine Chest Press | 3 × 8-12 | 1-2 | 2 minutes |
| 5 | Cable Lateral Raise | 3 × 12-20 | 1-2 | 60-90 seconds |
| 6 | Rear Delt Fly | 3 × 12-20 | 1-2 | 60-90 seconds |
| 7 | Hammer Curl | 3 × 10-15 | 1-2 | 60-90 seconds |
| 8 | Rope Triceps Pushdown | 3 × 10-15 | 1-2 | 60-90 seconds |
| 9 | Barbell Shrug | 3 × 10-15 | 1-2 | 90 seconds |

**Lower Body B** — همسترینگ + باسن + چهارسر مکمل + ساق

| Order | Exercise | Sets × reps | RIR | Rest |
|---|---|---|---|---|
| 1 | Romanian Deadlift | 3 × 6-10 | 2 | 2-3 minutes |
| 2 | Hip Thrust | 3 × 8-12 | 1-2 | 2 minutes |
| 3 | Bulgarian Split Squat | 3 × 8-12 each leg | 1-2 | 2 minutes |
| 4 | Seated Leg Curl | 3 × 10-15 | 1-2 | 90 seconds |
| 5 | Leg Extension | 3 × 12-20 | 1-2 | 60-90 seconds |
| 6 | Seated Calf Raise | 3 × 12-20 | 1-2 | 60-90 seconds |

**Migration and data safety**

The existing migration replaces only the active `workouts` and `workout_seed_version` entries. Workout-day IDs are `upper-lower-v8-day-1` through `upper-lower-v8-day-4`; exercise IDs use `upper-lower-v8-dN-eN`. Existing v7 drafts retain their original keys and cannot attach to v8 days. New completed sessions store an optional `workoutDayId` and use date plus workout ID for session IDs and duplicate detection. Legacy snapshots retain their old IDs, titles, focus, exercise records, and unknown metadata. Appending a session preserves existing raw snapshots verbatim. Migration is idempotent.

Automated Hive tests confirm completed history, old drafts, nutrition, progress, profile, checklist/history, supplements, cravings, and unrelated entries are preserved. No app-data clearing, uninstall, or Hive wipe occurred. Actual phone data preservation could not be physically verified because no Android device was detected.

**Image coverage**

28 exercise entries, 27 unique exercises: 23 existing images reused and 4 newly generated static PNGs (`pec_deck.png`, `barbell_shrug.png`, `seated_leg_curl.png`, `dumbbell_shoulder_press.png`). Every active exercise has an explicit seed path and name fallback. The existing `leg_curl.png` depicts lying curl and is reused only for that active exercise. The existing machine shoulder press image remains available for historical names; the active dumbbell press uses its new image. Existing artworks were visually inspected; new images were inspected individually. Unknown names retain the placeholder; artwork uses BoxFit.contain.

**Validation**

- `dart format lib test`: completed; unrelated formatter changes reverted.
- `flutter test --no-pub`: all 72 tests passed, including exact prescriptions, seven-day calendar resolution, migration safety, session isolation, static assets, bundle loading and PNG decoding.
- `flutter analyze --no-pub`: 18 pre-existing issues (16 info, 2 warnings); no errors or new warnings. It exits nonzero because existing issues remain.
- `git diff --check`: passed.
- Debug APK: built successfully using `flutter build apk --debug --no-pub`.
- Initial debug build hit Google Storage HTTP 403. Retry used process-local FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn, the CFUG mirror documented by Flutter: https://docs.flutter.dev/community/china. No repository configuration was changed.
- Device QA/logcat/signature check/replacement install: not performed; no Android device detected. No emulator launched.

**Changed files**

- `lib/data/local/default_seed_data.dart`: version 8.
- `lib/data/local/hypertrophy_workout_seed.dart`: exact four-day program, Persian focus, v8 IDs, explicit image paths.
- `lib/data/local/local_storage_service.dart`: isolate submissions by workout ID and preserve legacy snapshots when appending.
- `lib/features/dashboard/screens/dashboard_screen.dart`: shared calendar resolution.
- `lib/features/workout/models/workout_day_model.dart`: shared Saturday-first calendar helpers.
- `lib/features/workout/models/workout_session_model.dart`: optional workout ID and new session IDs.
- `lib/features/workout/screens/workout_plan_screen.dart`: schedule, program guide, image fallbacks, submission matching.
- `test/workout_program_test.dart`: exact program, schedule and data-safety tests.
- `test/exercise_static_assets_test.dart`: complete static asset and decoding coverage.
- Four new PNGs in `assets/exercises/`.
- `release_output/`: requested APK copy, build/test/analyzer logs, asset audit and this report.

**Remaining manual checks**

On the phone, replace-install only if certificates match; use `adb install -r`, never uninstall or clear data. Verify historical workouts, progress and nutrition history; the four active days and Thursday rest; representative exercise guides, including all four new images. Check fresh logcat for crashes, Flutter errors, missing assets, image decode failures, overflows and uncaught exceptions. Existing release configuration uses the debug signing key; this was left unchanged.

**Release and APK audit**

Release build succeeded (`flutter build apk --release --no-pub`, process-local mirror).

Standard artifact: `C:\Users\Ayan\Documents\Programming\MyFitPlan\build\app\outputs\flutter-apk\app-release.apk`

Copied artifact: `C:\Users\Ayan\Documents\Programming\MyFitPlan\release_output\Fitora-v8-workout.apk`

Size: 183,797,712 bytes (183.8 MB / 175.28 MiB). Both artifacts remain and SHA-256 hashes match: `61140bd9fc86bba2a4287bda5779b66c3f3777f38435f03c1f30f923f1e1aa3b`.

ZIP integrity passed. All 27 active static PNGs are included and have PNG signatures; no GIF files, motion-directory entries, missing active assets, or invalid PNGs. No release installation was attempted because no device was detected.

**Existing active artwork reused**

`assisted_pullup.png`, `bayesian_cable_curl.png`, `bench_press.png`, `bulgarian_split_squat.png`, `cable_lateral_raise.png`, `chest_press.png`, `chest_supported_row.png`, `hammer_curl.png`, `hip_thrust.png`, `incline_dumbbell_press.png`, `lateral_raise.png`, `leg_curl.png`, `leg_extension.png`, `leg_press.png`, `overhead_triceps_extension.png`, `rear_delt_fly.png`, `reverse_curl.png`, `romanian_deadlift.png`, `seated_calf_raise.png`, `seated_row.png`, `smith_squat.png`, `standing_calf_raise.png`, `triceps_pushdown.png`.

**Final Git summary**

Nine tracked files changed: 492 insertions, 664 deletions. Four new exercise PNGs and release_output artifacts are untracked. No unrelated formatter changes remain. Final git status and diff summary inspected; git diff --check passed. Nothing was committed or pushed.
