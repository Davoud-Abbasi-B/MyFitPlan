import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AsyncSnapshotView<T> extends StatelessWidget {
  const AsyncSnapshotView({
    super.key,
    required this.value,
    required this.builder,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) builder;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: builder,
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'بارگذاری اطلاعات انجام نشد.\n$error',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
