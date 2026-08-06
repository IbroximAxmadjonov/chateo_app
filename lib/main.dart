import 'package:chateo_app/application.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'generated/codegen_loader.g.dart';
import 'service_locator.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize HydratedBloc storage
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory((await getApplicationDocumentsDirectory()).path),
  );

  // Initialize dependency injection
  await di.initializeInjection();

  // Set default language to Russian unless user explicitly changed it
  final prefs = await SharedPreferences.getInstance();
  final isLocaleExplicit = prefs.getBool('locale_is_explicit') ?? false;
  if (!isLocaleExplicit) {
    await prefs.setString('locale', 'ru');
  }

  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ru'), Locale('uz')],
      path: 'assets/translations',
      assetLoader: const CodegenLoader(),
      fallbackLocale: const Locale('ru'),
      startLocale: const Locale('ru'),
      child: Application(),
    ),
  );
}
