import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'data/local/local_storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await LocalStorageService.instance.initialize();
  await LocalStorageService.instance.seedDefaultsIfNeeded();

  runApp(const ProviderScope(child: MyFitPlanApp()));
}
