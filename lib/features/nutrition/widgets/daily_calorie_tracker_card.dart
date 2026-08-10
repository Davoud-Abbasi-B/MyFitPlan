import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/app_card.dart';
import '../models/daily_nutrition_model.dart';
import '../models/food_analysis_result.dart';
import '../providers/daily_nutrition_provider.dart';
import '../services/food_analysis_service.dart';
import '../services/food_name_translation_service.dart';
import '../services/local_food_database_service.dart';
import '../services/persian_food_parser.dart';

class DailyCalorieTrackerCard extends ConsumerStatefulWidget {
  const DailyCalorieTrackerCard({super.key, this.isActive = false});

  final bool isActive;

  @override
  ConsumerState<DailyCalorieTrackerCard> createState() =>
      _DailyCalorieTrackerCardState();
}

class _DailyCalorieTrackerCardState
    extends ConsumerState<DailyCalorieTrackerCard> {
  final _inputController = TextEditingController();
  final _inputFocusNode = FocusNode();
  FoodAnalysisBatchResult? _preview;
  FoodConfirmationGuard _confirmationGuard = FoodConfirmationGuard();
  bool _isAnalyzing = false;
  bool _isAddingPreview = false;
  bool _isDownloadingTranslator = false;
  String? _inputError;

  @override
  void didUpdateWidget(covariant DailyCalorieTrackerCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(translationUiStateProvider.notifier).screenOpened();
      });
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  Future<void> _analyze() async {
    if (_isAnalyzing || _isAddingPreview) return;
    final input = _inputController.text.trim();
    if (input.isEmpty) {
      setState(() => _inputError = 'لطفاً خوراکی و مقدار آن را وارد کنید.');
      return;
    }
    setState(() {
      _isAnalyzing = true;
      _inputError = null;
      _preview = null;
      _confirmationGuard = FoodConfirmationGuard();
    });
    ref.read(translationUiStateProvider.notifier).operationStarted();
    try {
      final result = await ref.read(foodAnalysisServiceProvider).analyze(input);
      if (!mounted) return;
      final resolved = await _resolveBatch(result);
      if (!mounted) return;
      setState(() {
        _preview = resolved;
        if (resolved.needsUserAction) {
          _inputError =
              'برای موارد حل‌نشده، مقدار یا خوراکی مناسب را مشخص کنید.';
        }
      });
    } on FoodNotRecognizedException {
      if (!mounted) return;
      setState(() {
        _inputError = 'این خوراکی در نسخه فعلی قابل محاسبه نیست.';
      });
    } on FoodAnalysisException catch (error) {
      if (!mounted) return;
      setState(() => _inputError = foodAnalysisErrorMessage(error));
    } catch (error) {
      if (!mounted) return;
      setState(() => _inputError = foodAnalysisErrorMessage(error));
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  Future<void> _downloadTranslator() async {
    if (_isDownloadingTranslator) return;
    setState(() {
      _isDownloadingTranslator = true;
    });
    final translationUi = ref.read(translationUiStateProvider.notifier);
    translationUi.operationStarted(downloading: true);
    try {
      await ref
          .read(foodNameTranslationServiceProvider)
          .ensureModelsDownloaded();
      if (!mounted) return;
      translationUi.succeeded();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('مترجم آفلاین آماده است.')),
      );
    } on PlatformException catch (error) {
      if (!mounted) return;
      translationUi.failed(
        error.code == 'UNSUPPORTED_LANGUAGE'
            ? TranslationModelStatus.unavailable
            : TranslationModelStatus.downloadFailed,
        safeTranslationDiagnostic(error),
      );
    } catch (error) {
      if (!mounted) return;
      translationUi.failed(
        TranslationModelStatus.downloadFailed,
        'MODEL_DOWNLOAD_FAILED',
      );
    } finally {
      if (mounted) setState(() => _isDownloadingTranslator = false);
    }
  }

  Future<FoodAnalysisBatchResult> _resolveBatch(
    FoodAnalysisBatchResult batch,
  ) async {
    final items = [...batch.items];
    final remaining = <UnresolvedFoodItem>[];
    final hybrid = ref.read(hybridFoodAnalysisServiceProvider);
    for (final unresolved in batch.unresolvedItems) {
      FoodAnalysisResult? result;
      if (unresolved.candidates.isNotEmpty) {
        final choice = await _showCandidateSheet(unresolved);
        if (!mounted) return batch;
        if (choice.candidate != null) {
          result = await hybrid.resolveCandidate(
            unresolved,
            choice.candidate!,
          );
        } else if (choice.action == _CandidateAction.manual) {
          result = await _showManualEntry(unresolved);
        } else if (choice.action == _CandidateAction.retry) {
          _inputController.text = unresolved.originalSegment;
          _inputFocusNode.requestFocus();
        } else if (choice.action == _CandidateAction.correctTranslation) {
          final correction = await _showTranslationCorrection(unresolved);
          if (!mounted) return batch;
          if (correction != null) {
            final corrected = await hybrid.analyzeWithUserTranslation(
              unresolved,
              correction.englishPhrase,
              saveForLater: correction.saveForLater,
            );
            if (!mounted) return batch;
            final resolvedCorrection = await _resolveBatch(corrected);
            items.addAll(resolvedCorrection.items);
            remaining.addAll(resolvedCorrection.unresolvedItems);
            continue;
          }
        }
      }
      if (result != null) {
        items.add(result);
      } else {
        remaining.add(unresolved);
      }
    }
    return FoodAnalysisBatchResult(
      originalInput: batch.originalInput,
      items: items,
      unresolvedItems: remaining,
      warnings: batch.warnings,
    );
  }

  Future<_TranslationCorrection?> _showTranslationCorrection(
    UnresolvedFoodItem unresolved,
  ) async {
    final controller = TextEditingController(text: unresolved.searchPhrase);
    var saveForLater = true;
    final result = await showDialog<_TranslationCorrection>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('اصلاح عبارت انگلیسی'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(unresolved.foodName),
              const SizedBox(height: 10),
              TextField(
                controller: controller,
                autofocus: true,
                textDirection: TextDirection.ltr,
                decoration: const InputDecoration(
                  labelText: 'عبارت انگلیسی برای USDA',
                ),
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: saveForLater,
                onChanged: (value) => setDialogState(
                  () => saveForLater = value ?? false,
                ),
                title: const Text('ذخیره ترجمه برای دفعات بعد'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('لغو'),
            ),
            FilledButton(
              onPressed: () {
                final phrase = controller.text.trim();
                if (phrase.isEmpty) return;
                Navigator.pop(
                  context,
                  _TranslationCorrection(
                    englishPhrase: phrase,
                    saveForLater: saveForLater,
                  ),
                );
              },
              child: const Text('جست‌وجوی دوباره'),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    return result;
  }

  Future<void> _resolveManually(UnresolvedFoodItem unresolved) async {
    final result = await _showManualEntry(unresolved);
    if (!mounted || result == null) return;
    _replaceUnresolved(unresolved, result);
  }

  Future<void> _correctUnresolvedTranslation(
    UnresolvedFoodItem unresolved,
  ) async {
    final correction = await _showTranslationCorrection(unresolved);
    if (!mounted || correction == null) return;
    final corrected = await ref
        .read(hybridFoodAnalysisServiceProvider)
        .analyzeWithUserTranslation(
          unresolved,
          correction.englishPhrase,
          saveForLater: correction.saveForLater,
        );
    if (!mounted) return;
    final resolved = await _resolveBatch(corrected);
    if (!mounted) return;
    _replaceUnresolvedBatch(unresolved, resolved);
  }

  Future<void> _enterItemWeight(UnresolvedFoodItem unresolved) async {
    final controller = TextEditingController();
    final gramsPerItem = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('وزن تقریبی هر عدد'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'وزن هر عدد به گرم',
            suffixText: 'گرم',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('لغو'),
          ),
          FilledButton(
            onPressed: () {
              final value = double.tryParse(
                normalizePersianText(controller.text),
              );
              if (value != null && value > 0) Navigator.pop(context, value);
            },
            child: const Text('محاسبه'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (!mounted || gramsPerItem == null) return;
    final result = await ref
        .read(hybridFoodAnalysisServiceProvider)
        .resolveLocalPortion(unresolved, gramsPerItem);
    if (!mounted || result == null) return;
    _replaceUnresolved(unresolved, result);
  }

  void _replaceUnresolved(
    UnresolvedFoodItem unresolved,
    FoodAnalysisResult result,
  ) {
    _replaceUnresolvedBatch(
      unresolved,
      FoodAnalysisBatchResult(
        originalInput: unresolved.originalSegment,
        items: [result],
      ),
    );
  }

  void _replaceUnresolvedBatch(
    UnresolvedFoodItem unresolved,
    FoodAnalysisBatchResult replacement,
  ) {
    final preview = _preview;
    if (preview == null) return;
    setState(() {
      _preview = FoodAnalysisBatchResult(
        originalInput: preview.originalInput,
        items: [...preview.items, ...replacement.items],
        unresolvedItems: [
          ...preview.unresolvedItems.where(
            (item) => !identical(item, unresolved),
          ),
          ...replacement.unresolvedItems,
        ],
        warnings: [...preview.warnings, ...replacement.warnings],
      );
      _inputError = _preview!.needsUserAction
          ? 'برای موارد حل‌نشده، مقدار یا خوراکی مناسب را مشخص کنید.'
          : null;
    });
  }

  Future<_CandidateSheetResult> _showCandidateSheet(
    UnresolvedFoodItem unresolved,
  ) async {
    return await showModalBottomSheet<_CandidateSheetResult>(
          context: context,
          isScrollControlled: true,
          showDragHandle: true,
          builder: (context) => SafeArea(
            top: false,
            child: FractionallySizedBox(
              heightFactor: 0.88,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                    child: Text(
                      'انتخاب خوراکی مشابه',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                    child: Text(
                      'برای «${unresolved.foodName}»',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: unresolved.candidates.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final candidate = unresolved.candidates[index];
                        return _UsdaCandidateCard(
                          candidate: candidate,
                          onSelect: () => Navigator.pop(
                            context,
                            _CandidateSheetResult(candidate: candidate),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.pop(
                            context,
                            const _CandidateSheetResult(
                              action: _CandidateAction.retry,
                            ),
                          ),
                          child: const Text('جست‌وجوی دوباره'),
                        ),
                        OutlinedButton(
                          onPressed: () => Navigator.pop(
                            context,
                            const _CandidateSheetResult(
                              action: _CandidateAction.manual,
                            ),
                          ),
                          child: const Text('ورود دستی'),
                        ),
                        if (unresolved.searchPhrase != null)
                          OutlinedButton(
                            onPressed: () => Navigator.pop(
                              context,
                              const _CandidateSheetResult(
                                action: _CandidateAction.correctTranslation,
                              ),
                            ),
                            child: const Text('اصلاح عبارت انگلیسی'),
                          ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('لغو'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ) ??
        const _CandidateSheetResult(action: _CandidateAction.cancel);
  }

  Future<FoodAnalysisResult?> _showManualEntry(
    UnresolvedFoodItem unresolved,
  ) async {
    final nameController = TextEditingController(text: unresolved.foodName);
    final quantityController = TextEditingController(
      text: unresolved.quantity?.toString() ?? '',
    );
    final caloriesController = TextEditingController();
    final proteinController = TextEditingController();
    final carbsController = TextEditingController();
    final fatController = TextEditingController();
    var unit = FoodUnit.values.firstWhere(
      (item) => item.name == unresolved.unit,
      orElse: () => FoodUnit.gram,
    );
    if (unit == FoodUnit.unsupported) unit = FoodUnit.gram;
    var saveCustom = false;

    final result = await showDialog<FoodAnalysisResult>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('ورود دستی خوراکی'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                    'مقادیر غذایی را برای همین مقدار مصرف‌شده وارد کنید.'),
                const SizedBox(height: 10),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'نام خوراکی'),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: quantityController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration:
                            const InputDecoration(labelText: 'مقدار مصرف'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<FoodUnit>(
                        initialValue: unit,
                        decoration: const InputDecoration(labelText: 'واحد'),
                        items: FoodUnit.values
                            .where((item) => item != FoodUnit.unsupported)
                            .map((item) => DropdownMenuItem(
                                  value: item,
                                  child: Text(item.label),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setDialogState(() => unit = value);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _ManualMacroField(
                    controller: caloriesController, label: 'کالری'),
                _ManualMacroField(
                    controller: proteinController, label: 'پروتئین'),
                _ManualMacroField(
                    controller: carbsController, label: 'کربوهیدرات'),
                _ManualMacroField(controller: fatController, label: 'چربی'),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: saveCustom,
                  onChanged: (value) =>
                      setDialogState(() => saveCustom = value ?? false),
                  title: const Text('ذخیره در خوراکی‌های من'),
                  subtitle: const Text(
                    'ذخیره خودکار فقط برای مقدار گرم یا کیلوگرم انجام می‌شود.',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('لغو'),
            ),
            FilledButton(
              onPressed: () async {
                double? parseNumber(TextEditingController controller) =>
                    double.tryParse(normalizePersianText(controller.text));
                final quantity = parseNumber(quantityController);
                final calories = parseNumber(caloriesController);
                final protein = parseNumber(proteinController);
                final carbs = parseNumber(carbsController);
                final fat = parseNumber(fatController);
                final name = nameController.text.trim();
                if (quantity == null ||
                    quantity <= 0 ||
                    calories == null ||
                    protein == null ||
                    carbs == null ||
                    fat == null ||
                    name.isEmpty) {
                  return;
                }
                final grams = unit == FoodUnit.gram
                    ? quantity
                    : unit == FoodUnit.kilogram
                        ? quantity * 1000
                        : null;
                if (saveCustom && grams != null) {
                  final multiplier = 100 / grams;
                  await ref.read(localStorageServiceProvider).saveCustomFood(
                        LocalFoodDefinition(
                          id: 'custom-${DateTime.now().microsecondsSinceEpoch}',
                          nameFa: name,
                          aliasesFa: const [],
                          searchTermsEn: const [],
                          basisAmount: 100,
                          calories: calories * multiplier,
                          proteinGrams: protein * multiplier,
                          carbsGrams: carbs * multiplier,
                          fatGrams: fat * multiplier,
                          source: 'user_custom',
                          defaultGramConversions: const {},
                          isCustom: true,
                        ),
                      );
                  ref.read(localFoodDatabaseProvider).invalidateCustomFoods();
                }
                if (!context.mounted) return;
                Navigator.pop(
                  context,
                  FoodAnalysisResult(
                    originalInput: unresolved.originalSegment,
                    foodName: name,
                    quantityText: '${_number(quantity)} ${unit.label}',
                    consumedGrams: grams,
                    calories: calories,
                    proteinGrams: protein,
                    carbsGrams: carbs,
                    fatGrams: fat,
                    isEstimated: true,
                    confidence: 'high',
                    assumptions: const ['مقادیر توسط کاربر وارد شده‌اند.'],
                    sourceType: FoodSourceType.manual,
                    sourceLabel: 'ورود دستی',
                  ),
                );
              },
              child: const Text('ثبت'),
            ),
          ],
        ),
      ),
    );
    nameController.dispose();
    quantityController.dispose();
    caloriesController.dispose();
    proteinController.dispose();
    carbsController.dispose();
    fatController.dispose();
    return result;
  }

  Future<void> _addPreview() async {
    final preview = _preview;
    if (preview == null ||
        _isAddingPreview ||
        !_confirmationGuard.tryConfirm()) {
      return;
    }
    setState(() => _isAddingPreview = true);
    try {
      await ref
          .read(dailyNutritionProvider.notifier)
          .addAnalyses(preview.items);
      if (!mounted) return;
      setState(() {
        _preview = null;
        _inputError = null;
        _inputController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('خوراکی‌ها به فهرست امروز افزوده شدند.')),
      );
    } finally {
      if (mounted) setState(() => _isAddingPreview = false);
    }
  }

  void _editInput() {
    setState(() => _preview = null);
    _inputFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final dailyAsync = ref.watch(dailyNutritionProvider);
    return AppCard(
      child: ExpansionTile(
        initiallyExpanded: true,
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.zero,
        shape: const Border(),
        collapsedShape: const Border(),
        leading: const Icon(Icons.calculate_outlined, color: AppColors.primary),
        title: Text(
          'کالری‌شمار روزانه',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        children: [
          dailyAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
            error: (error, stackTrace) => const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text('اطلاعات کالری‌شمار بارگذاری نشد.'),
            ),
            data: (daily) => _buildContent(context, daily),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, DailyNutritionState daily) {
    final totals = daily.totals;
    final isTraining = daily.dayType == NutritionDayType.training;
    final lowerCalories = isTraining ? 2300 : 2100;
    final upperCalories = isTraining ? 2400 : 2200;
    final translationUi = ref.watch(translationUiStateProvider);
    final translationStatus = translationUi.status;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DailySummary(
          totals: totals,
          lowerCalories: lowerCalories,
          upperCalories: upperCalories,
          isTraining: isTraining,
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _inputController,
          focusNode: _inputFocusNode,
          enabled: !_isAnalyzing && !_isAddingPreview,
          minLines: 1,
          maxLines: 2,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _isAnalyzing ? null : _analyze(),
          decoration: InputDecoration(
            labelText: 'چه چیزی خوردی؟',
            hintText: 'مثلاً ۴ عدد تخم‌مرغ یا ۱۰۰ گرم نان بربری',
            errorText: _inputError,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _isAnalyzing || _isAddingPreview ? null : _analyze,
            icon: _isAnalyzing
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.auto_awesome_outlined),
            label: Text(_isAnalyzing ? 'در حال محاسبه...' : 'محاسبه'),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          !isUsdaFoodSearchEnabled
              ? 'فقط پایگاه غذایی داخلی فعال است'
              : translationStatus == TranslationModelStatus.ready
                  ? 'ترجمه آفلاین و پایگاه غذایی آنلاین فعال هستند'
                  : translationStatus == TranslationModelStatus.downloading
                      ? 'پایگاه غذایی آنلاین فعال است؛ مترجم در حال آماده‌سازی است'
                      : 'مترجم آفلاین هنگام اولین استفاده بررسی می‌شود',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        if (isUsdaFoodSearchEnabled &&
            translationStatus == TranslationModelStatus.downloading)
          const Text('در حال آماده‌سازی مترجم آفلاین...'),
        if (isUsdaFoodSearchEnabled &&
            translationStatus == TranslationModelStatus.ready)
          const Text('مترجم آفلاین آماده است.'),
        if (isUsdaFoodSearchEnabled &&
            translationStatus == TranslationModelStatus.downloadFailed)
          Row(
            children: [
              const Expanded(
                child: Text(
                  'مدل ترجمه دانلود نشد. اتصال اینترنت را بررسی کنید.',
                  style: TextStyle(color: AppColors.warning),
                ),
              ),
              TextButton(
                onPressed:
                    _isDownloadingTranslator ? null : _downloadTranslator,
                child: const Text('تلاش دوباره'),
              ),
            ],
          ),
        if (translationUi.diagnostic != null &&
            translationStatus != TranslationModelStatus.ready)
          Text(
            translationUi.diagnostic!,
            textDirection: TextDirection.ltr,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.warning,
                ),
          ),
        if (isUsdaFoodSearchEnabled &&
            translationStatus != TranslationModelStatus.ready)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: OutlinedButton.icon(
              onPressed: _isDownloadingTranslator ? null : _downloadTranslator,
              icon: _isDownloadingTranslator
                  ? const SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.download_outlined),
              label: const Text('دانلود مترجم آفلاین'),
            ),
          ),
        Text(
          'مقادیر غذایی تقریبی هستند و ممکن است با برند، دستور پخت و اندازه واقعی وعده متفاوت باشند.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        if (_preview != null) ...[
          const SizedBox(height: 12),
          _AnalysisPreview(
            batch: _preview!,
            isAdding: _isAddingPreview,
            onAdd: _addPreview,
            onEdit: _editInput,
            onManual: _resolveManually,
            onPortion: _enterItemWeight,
            onRetry: _downloadTranslator,
            onCorrection: _correctUnresolvedTranslation,
            onCancel:
                _isAddingPreview ? null : () => setState(() => _preview = null),
          ),
        ],
        if (daily.entries.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'خوراکی‌های امروز',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          ...daily.entries.map(
            (entry) => _FoodEntryTile(
              entry: entry,
              onDelete: () => _confirmDeleteEntry(context, entry),
            ),
          ),
        ],
        const SizedBox(height: 12),
        if (daily.isSubmitted)
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(Icons.verified_outlined,
                    size: 18, color: AppColors.primary),
                SizedBox(width: 6),
                Text(
                  'ثبت‌شده',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: daily.entries.isEmpty ? null : _submitReport,
            icon: const Icon(Icons.task_alt_outlined),
            label: const Text('ثبت گزارش غذایی امروز'),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmDeleteEntry(
    BuildContext context,
    DailyNutritionEntry entry,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف خوراکی'),
        content: const Text(
          'آیا این خوراکی از فهرست امروز حذف شود؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('لغو'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(dailyNutritionProvider.notifier).deleteEntry(entry.id);
    }
  }

  Future<void> _submitReport() async {
    final result =
        await ref.read(dailyNutritionProvider.notifier).submitReport();
    if (!mounted) return;
    final message = switch (result) {
      NutritionReportSubmissionResult.submitted =>
        'گزارش غذایی امروز با موفقیت ثبت شد.',
      NutritionReportSubmissionResult.duplicate =>
        'گزارش غذایی امروز قبلاً ثبت شده است.',
      NutritionReportSubmissionResult.empty =>
        'برای ثبت گزارش، ابتدا یک خوراکی اضافه کنید.',
    };
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

enum _CandidateAction { select, retry, manual, correctTranslation, cancel }

class _CandidateSheetResult {
  const _CandidateSheetResult({
    this.candidate,
    this.action = _CandidateAction.select,
  });
  final FoodAnalysisCandidate? candidate;
  final _CandidateAction action;
}

class _TranslationCorrection {
  const _TranslationCorrection({
    required this.englishPhrase,
    required this.saveForLater,
  });

  final String englishPhrase;
  final bool saveForLater;
}

class _UsdaCandidateCard extends StatelessWidget {
  const _UsdaCandidateCard({
    required this.candidate,
    required this.onSelect,
  });

  final FoodAnalysisCandidate candidate;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            candidate.description,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          Text(
            '${candidate.dataType}'
            '${candidate.brandOwner == null ? '' : ' • ${candidate.brandOwner}'}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            '${_number(candidate.caloriesPer100g)} کالری در ۱۰۰ گرم | '
            'پروتئین ${_number(candidate.proteinPer100g)} | '
            'کربوهیدرات ${_number(candidate.carbsPer100g)} | '
            'چربی ${_number(candidate.fatPer100g)}',
          ),
          const SizedBox(height: 8),
          FilledButton(onPressed: onSelect, child: const Text('انتخاب')),
        ],
      ),
    );
  }
}

class _ManualMacroField extends StatelessWidget {
  const _ManualMacroField({required this.controller, required this.label});
  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(labelText: '$label برای مقدار مصرف‌شده'),
      ),
    );
  }
}

class _DailySummary extends StatelessWidget {
  const _DailySummary({
    required this.totals,
    required this.lowerCalories,
    required this.upperCalories,
    required this.isTraining,
  });

  final DailyNutritionTotals totals;
  final int lowerCalories;
  final int upperCalories;
  final bool isTraining;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isTraining ? 'هدف روز تمرین' : 'هدف روز استراحت',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'کالری: ${_number(totals.calories)} از '
            '${_integer(lowerCalories)} تا ${_integer(upperCalories)}',
          ),
          Text(
            'پروتئین: ${_number(totals.proteinGrams)} از '
            '${_integer(145)} تا ${_integer(160)} گرم',
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 12,
            runSpacing: 4,
            children: [
              Text('کربوهیدرات: ${_number(totals.carbsGrams)} گرم'),
              Text('چربی: ${_number(totals.fatGrams)} گرم'),
            ],
          ),
          if (totals.calories > upperCalories) ...[
            const SizedBox(height: 8),
            const Text(
              'کالری امروز از هدف تعیین‌شده بیشتر شده است.',
              style: TextStyle(color: AppColors.warning),
            ),
          ],
        ],
      ),
    );
  }
}

class _AnalysisPreview extends StatelessWidget {
  const _AnalysisPreview({
    required this.batch,
    required this.isAdding,
    required this.onAdd,
    required this.onEdit,
    required this.onManual,
    required this.onPortion,
    required this.onRetry,
    required this.onCorrection,
    required this.onCancel,
  });

  final FoodAnalysisBatchResult batch;
  final bool isAdding;
  final VoidCallback onAdd;
  final VoidCallback onEdit;
  final Future<void> Function(UnresolvedFoodItem) onManual;
  final Future<void> Function(UnresolvedFoodItem) onPortion;
  final VoidCallback onRetry;
  final Future<void> Function(UnresolvedFoodItem) onCorrection;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'پیش‌نمایش محاسبه',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 6),
          ...batch.items.indexed.map(
            (indexed) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _AnalysisItem(
                index: indexed.$1 + 1,
                result: indexed.$2,
              ),
            ),
          ),
          if (batch.unresolvedItems.isNotEmpty) ...[
            const SizedBox(height: 6),
            ...batch.unresolvedItems.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.foodName,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        item.reason,
                        style: const TextStyle(color: AppColors.warning),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          if (item.status ==
                                  FoodResolutionStatus.needsPortion &&
                              item.unit == FoodUnit.item.name)
                            OutlinedButton(
                              onPressed:
                                  isAdding ? null : () => onPortion(item),
                              child: const Text('وزن هر عدد'),
                            ),
                          if (item.allowsManualEntry)
                            FilledButton.tonal(
                              key: ValueKey('manual-entry-${item.foodName}'),
                              onPressed: isAdding ? null : () => onManual(item),
                              child: const Text('ورود دستی'),
                            ),
                          if (item.status ==
                              FoodResolutionStatus.translationUnavailable)
                            OutlinedButton(
                              onPressed: isAdding ? null : onRetry,
                              child: const Text('تلاش دوباره'),
                            ),
                          if (item.searchPhrase != null)
                            OutlinedButton(
                              onPressed:
                                  isAdding ? null : () => onCorrection(item),
                              child: const Text('اصلاح عبارت انگلیسی'),
                            ),
                        ],
                      ),
                    ],
                  ),
                )),
          ],
          if (batch.items.isNotEmpty) ...[
            const Divider(),
            Text(
              'جمع: ${_number(batch.totals.calories)} کالری | '
              'پروتئین ${_number(batch.totals.proteinGrams)} | '
              'کربوهیدرات ${_number(batch.totals.carbsGrams)} | '
              'چربی ${_number(batch.totals.fatGrams)} گرم',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
          if (batch.warnings.isNotEmpty) ...[
            const SizedBox(height: 6),
            ...batch.warnings.map(
              (warning) => Text(
                'هشدار: $warning',
                style: const TextStyle(color: AppColors.warning),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              FilledButton(
                onPressed: isAdding || !batch.canConfirm ? null : onAdd,
                child:
                    Text(isAdding ? 'در حال افزودن...' : 'افزودن همه به امروز'),
              ),
              TextButton(
                onPressed: isAdding ? null : onEdit,
                child: const Text('ویرایش متن'),
              ),
              TextButton(onPressed: onCancel, child: const Text('لغو')),
            ],
          ),
        ],
      ),
    );
  }
}

class _AnalysisItem extends StatelessWidget {
  const _AnalysisItem({required this.index, required this.result});

  final int index;
  final FoodAnalysisResult result;

  @override
  Widget build(BuildContext context) {
    final confidence = switch (result.confidence) {
      'high' => 'زیاد',
      'low' => 'کم',
      _ => 'متوسط',
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_integer(index)}. ${result.foodName} • ${result.quantityText}',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        if (result.quantityText.contains('عدد') && result.consumedGrams != null)
          Text(
            '${result.quantityText} — وزن تقریبی کل: '
            '${_number(result.consumedGrams!)} گرم',
          ),
        Text(
          '${_number(result.calories)} کالری | '
          'پروتئین ${_number(result.proteinGrams)} | '
          'کربوهیدرات ${_number(result.carbsGrams)} | '
          'چربی ${_number(result.fatGrams)} گرم',
        ),
        Text(
          'اطمینان: $confidence',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        Text(
          'منبع: ${result.sourceLabel}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        if (result.searchPhrase != null)
          Text(
            'عبارت جست‌وجو: ${result.searchPhrase}',
            textDirection: TextDirection.ltr,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ...result.assumptions.map(
          (assumption) => Text(
            'فرض: $assumption',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ),
        ...result.warnings.map(
          (warning) => Text(
            'هشدار: $warning',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.warning,
                ),
          ),
        ),
      ],
    );
  }
}

class _FoodEntryTile extends StatelessWidget {
  const _FoodEntryTile({required this.entry, required this.onDelete});

  final DailyNutritionEntry entry;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final time = '${entry.createdAt.hour.toString().padLeft(2, '0')}:'
        '${entry.createdAt.minute.toString().padLeft(2, '0')}';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.scaffold,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${entry.foodName} • ${entry.quantityText}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 3),
                Text(
                  '${_number(entry.calories)} کالری | '
                  'پروتئین ${_number(entry.proteinGrams)} | '
                  'کربوهیدرات ${_number(entry.carbsGrams)} | '
                  'چربی ${_number(entry.fatGrams)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  '${entry.isEstimated ? 'تقریبی • ' : ''}'
                  '${AppDateUtils.toPersianDigits(time)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'حذف خوراکی',
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
    );
  }
}

String _number(double value) {
  final text = value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toStringAsFixed(1);
  return AppDateUtils.toPersianDigits(text);
}

String _integer(int value) => AppDateUtils.toPersianDigits(value.toString());
