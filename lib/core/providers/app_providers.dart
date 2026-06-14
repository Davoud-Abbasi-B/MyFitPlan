import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/app_snapshot.dart';
import '../../data/local/local_storage_service.dart';

final localStorageServiceProvider = Provider<LocalStorageService>(
  (ref) => LocalStorageService.instance,
);

final appSnapshotProvider = FutureProvider<AppSnapshot>((ref) async {
  final storage = ref.watch(localStorageServiceProvider);
  return storage.loadSnapshot();
});
