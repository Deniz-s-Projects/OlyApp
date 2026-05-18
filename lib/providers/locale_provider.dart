import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'storage_providers.dart';

const _kLocaleKey = 'language';

/// Current app locale preference. `null` means "follow system" — Flutter
/// then resolves to the best supported locale via
/// `MaterialApp.localeResolutionCallback`.
class LocaleNotifier extends Notifier<Locale?> {
  @override
  Locale? build() {
    final box = ref.watch(settingsStorageProvider);
    final code = box.get(_kLocaleKey) as String?;
    if (code == null || code.isEmpty) return null;
    return Locale(code);
  }

  Future<void> set(Locale? locale) async {
    final box = ref.read(settingsStorageProvider);
    if (locale == null) {
      await box.delete(_kLocaleKey);
    } else {
      await box.put(_kLocaleKey, locale.languageCode);
    }
    state = locale;
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale?>(
  LocaleNotifier.new,
);
