import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_fit_plan/features/nutrition/providers/daily_nutrition_provider.dart';
import 'package:my_fit_plan/features/nutrition/services/food_name_translation_service.dart';

void main() {
  test('cached translation skips ML Kit and updates last use', () async {
    final now = DateTime(2026, 8, 2);
    final cache = MemoryFoodTranslationCacheService(now: () => now);
    await cache.put(FoodTranslationCacheEntry(
      persianText: 'چیپس سیب زمینی',
      englishText: 'potato chips',
      source: TranslationSource.onDeviceMlKit,
      createdAt: now.subtract(const Duration(days: 2)),
      lastUsedAt: now.subtract(const Duration(days: 1)),
    ));
    final device = _FakeOnDeviceTranslator('wrong');
    final service = CachedFoodNameTranslationService(
      cache: cache,
      onDeviceTranslator: device,
      now: () => now,
    );

    final result = await service.translateFoodName('چیپس سیب زمینی');

    expect(result.translatedText, 'potato chips');
    expect(result.source, TranslationSource.cache);
    expect(device.translateCalls, 0);
    expect(cache.entries['چیپس سیب زمینی']?.lastUsedAt, now);
  });

  test('user override has highest priority and is reused', () async {
    final cache = MemoryFoodTranslationCacheService();
    final device = _FakeOnDeviceTranslator('machine phrase');
    final service = CachedFoodNameTranslationService(
      cache: cache,
      onDeviceTranslator: device,
    );
    await service.saveUserOverride('چیپس سیب زمینی', 'potato crisps');

    final result = await service.translateFoodName('چیپس سیب زمینی');

    expect(result.translatedText, 'potato crisps');
    expect(result.source, TranslationSource.userOverride);
    expect(device.translateCalls, 0);
  });

  test('unknown food uses on-device translation and preserves modifiers',
      () async {
    final device = _FakeOnDeviceTranslator('cooked test food');
    final service = CachedFoodNameTranslationService(
      cache: MemoryFoodTranslationCacheService(),
      onDeviceTranslator: device,
    );

    final result = await service.translateFoodName('  خوراک آزمایشی پخته  ');

    expect(device.lastInput, 'خوراک آزمایشی پخته');
    expect(result.translatedText, 'cooked test food');
    expect(result.source, TranslationSource.onDeviceMlKit);
    expect(device.downloadCalls, 1);
    expect(device.translateCalls, 1);
  });

  test('download failure maps to safe MODEL_DOWNLOAD_FAILED diagnostic',
      () async {
    final device = _FakeOnDeviceTranslator(
      'unused',
      downloadFailuresRemaining: 1,
    );
    final service = CachedFoodNameTranslationService(
      cache: MemoryFoodTranslationCacheService(),
      onDeviceTranslator: device,
    );

    final result = await service.translateFoodName('خوراک ناشناخته');

    expect(result.isAvailable, isFalse);
    expect(result.warning, contains('MODEL_DOWNLOAD_FAILED: MlKitException'));
    expect(device.downloadCalls, 1);
    expect(device.translateCalls, 0);
  });

  test('retry starts a new download after a failed attempt', () async {
    final device = _FakeOnDeviceTranslator(
      'unused',
      downloadFailuresRemaining: 1,
    );
    final service = CachedFoodNameTranslationService(
      cache: MemoryFoodTranslationCacheService(),
      onDeviceTranslator: device,
    );

    await expectLater(
      service.ensureModelsDownloaded(),
      throwsA(isA<PlatformException>()),
    );
    await service.ensureModelsDownloaded();

    expect(device.downloadCalls, 2);
    expect(device.modelsReady, isTrue);
  });

  test('duplicate retries share one active model download', () async {
    final device = _FakeOnDeviceTranslator(
      'unused',
      downloadDelay: const Duration(milliseconds: 20),
    );
    final service = CachedFoodNameTranslationService(
      cache: MemoryFoodTranslationCacheService(),
      onDeviceTranslator: device,
    );

    await Future.wait([
      service.ensureModelsDownloaded(),
      service.ensureModelsDownloaded(),
    ]);

    expect(device.downloadCalls, 1);
    expect(device.maxConcurrentDownloads, 1);
  });

  test('duplicate translations share one ML Kit request', () async {
    final device = _FakeOnDeviceTranslator(
      'potato chips',
      translationDelay: const Duration(milliseconds: 20),
    );
    final service = CachedFoodNameTranslationService(
      cache: MemoryFoodTranslationCacheService(),
      onDeviceTranslator: device,
    );

    await Future.wait([
      service.translateFoodName('چیپس سیب زمینی'),
      service.translateFoodName('چیپس سیب زمینی'),
    ]);

    expect(device.translateCalls, 1);
    expect(device.downloadCalls, 1);
  });

  test('failed or invalid translations are not cached', () async {
    final cache = MemoryFoodTranslationCacheService();
    final device = _FakeOnDeviceTranslator('چیپس سیب زمینی');
    final service = CachedFoodNameTranslationService(
      cache: cache,
      onDeviceTranslator: device,
    );

    final result = await service.translateFoodName('چیپس سیب زمینی');

    expect(result.isAvailable, isFalse);
    expect(cache.entries, isEmpty);
  });

  test('translation UI provider starts without a transient error', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final state = container.read(translationUiStateProvider);

    expect(state.status, TranslationModelStatus.unknown);
    expect(state.diagnostic, isNull);
    expect(state.translatorInitialized, isFalse);
  });

  test('starting retry clears the previous native diagnostic', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final controller = container.read(translationUiStateProvider.notifier);
    controller.failed(
      TranslationModelStatus.downloadFailed,
      'TRANSLATOR_INIT_FAILED: NullPointerException',
    );

    controller.operationStarted(downloading: true);

    final state = container.read(translationUiStateProvider);
    expect(state.status, TranslationModelStatus.downloading);
    expect(state.diagnostic, isNull);
  });

  test('successful initialization and download clear every prior error', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final controller = container.read(translationUiStateProvider.notifier);
    controller.failed(
      TranslationModelStatus.downloadFailed,
      'MODEL_DOWNLOAD_FAILED: MlKitException',
    );

    controller.succeeded();

    final state = container.read(translationUiStateProvider);
    expect(state.status, TranslationModelStatus.ready);
    expect(state.translatorInitialized, isTrue);
    expect(state.diagnostic, isNull);
  });

  test('successful translation status cannot coexist with init failure', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final controller = container.read(translationUiStateProvider.notifier);
    controller.failed(
      TranslationModelStatus.translationFailed,
      'TRANSLATION_FAILED: MlKitException',
    );

    controller.applyServiceStatus(TranslationModelStatus.ready);

    final state = container.read(translationUiStateProvider);
    expect(state.isReady, isTrue);
    expect(state.diagnostic, isNull);
  });

  test('reopening Nutrition clears a current-session transient failure', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final controller = container.read(translationUiStateProvider.notifier);
    controller.failed(
      TranslationModelStatus.downloadFailed,
      'TRANSLATOR_INIT_FAILED: NullPointerException',
    );

    controller.screenOpened();

    final state = container.read(translationUiStateProvider);
    expect(state.status, TranslationModelStatus.unknown);
    expect(state.diagnostic, isNull);
  });

  test('old native errors are not restored but translation cache survives',
      () async {
    final cache = MemoryFoodTranslationCacheService();
    final firstService = CachedFoodNameTranslationService(
      cache: cache,
      onDeviceTranslator: _FakeOnDeviceTranslator('potato chips'),
    );
    final firstResult = await firstService.translateFoodName('چیپس سیب زمینی');
    expect(firstResult.isAvailable, isTrue);

    final firstContainer = ProviderContainer();
    firstContainer.read(translationUiStateProvider.notifier).failed(
          TranslationModelStatus.downloadFailed,
          'MODEL_DOWNLOAD_FAILED: MlKitException',
        );
    firstContainer.dispose();

    final restartedContainer = ProviderContainer();
    addTearDown(restartedContainer.dispose);
    expect(
      restartedContainer.read(translationUiStateProvider).diagnostic,
      isNull,
    );
    final restartedDevice = _FakeOnDeviceTranslator('wrong');
    final restartedService = CachedFoodNameTranslationService(
      cache: cache,
      onDeviceTranslator: restartedDevice,
    );
    final cached = await restartedService.translateFoodName('چیپس سیب زمینی');
    expect(cached.source, TranslationSource.cache);
    expect(cached.translatedText, 'potato chips');
    expect(restartedDevice.translateCalls, 0);
  });
}

class _FakeOnDeviceTranslator implements OnDeviceFoodNameTranslator {
  _FakeOnDeviceTranslator(
    this.output, {
    this.supported = true,
    this.modelsReady = false,
    this.translationDelay = Duration.zero,
    this.downloadDelay = Duration.zero,
    this.downloadFailuresRemaining = 0,
  });

  final String output;
  final bool supported;
  bool modelsReady;
  final Duration translationDelay;
  final Duration downloadDelay;
  int downloadFailuresRemaining;
  int downloadCalls = 0;
  int activeDownloads = 0;
  int maxConcurrentDownloads = 0;
  int translateCalls = 0;
  String? lastInput;

  @override
  Future<OnDeviceTranslationAvailability> availability() async =>
      OnDeviceTranslationAvailability(
        isSupported: supported,
        modelsReady: modelsReady,
      );

  @override
  Future<void> ensureModelsDownloaded() async {
    downloadCalls++;
    activeDownloads++;
    if (activeDownloads > maxConcurrentDownloads) {
      maxConcurrentDownloads = activeDownloads;
    }
    try {
      if (downloadDelay > Duration.zero) {
        await Future<void>.delayed(downloadDelay);
      }
      if (downloadFailuresRemaining > 0) {
        downloadFailuresRemaining--;
        throw PlatformException(
          code: 'MODEL_DOWNLOAD_FAILED',
          message: 'MODEL_DOWNLOAD_FAILED: MlKitException',
        );
      }
      modelsReady = true;
    } finally {
      activeDownloads--;
    }
  }

  @override
  Future<String> translate(String persianFoodName) async {
    translateCalls++;
    lastInput = persianFoodName;
    if (translationDelay > Duration.zero) {
      await Future<void>.delayed(translationDelay);
    }
    return output;
  }

  @override
  Future<void> deleteModels() async {
    modelsReady = false;
  }
}
