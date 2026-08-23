import 'package:chateo_app/core/utils/bloc/theme/theme_bloc.dart';
import 'package:chateo_app/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppearancePage extends StatelessWidget {
  const AppearancePage({super.key});

  void _saveLocale(String locale) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('locale', locale);
    prefs.setBool('locale_is_explicit', true);
  }

  @override
  Widget build(BuildContext context) {
    // Registers this widget as a dependent of EasyLocalization so it rebuilds on locale change.
    EasyLocalization.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.more_appearance.tr()),
        centerTitle: true,
      ),
      body: BlocBuilder<ThemeBloc, ThemeMode>(
        builder: (context, state) {
          // Read locale so this builder re-runs when the locale changes.
          final _ = context.locale;
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              spacing: 20.h,
              children: [
                RadioGroup<ThemeMode>(
                  groupValue: state,
                  onChanged: (value) {
                    if (value == null) return;
                    context.read<ThemeBloc>().add(
                      ThemeModeChanged(themeMode: value),
                    );
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 8.h,
                    children: [
                      RadioListTile<ThemeMode>(
                        value: ThemeMode.system,
                        title: Text('Системный режим'),
                      ),
                      RadioListTile<ThemeMode>(
                        value: ThemeMode.light,
                        title: Text('Светлый режим'),
                      ),
                      RadioListTile<ThemeMode>(
                        value: ThemeMode.dark,
                        title: Text('Темный режим'),
                      ),
                    ],
                  ),
                ),
                RadioGroup<Locale>(
                  groupValue: context.locale,
                  onChanged: (value) {
                    if (value == null) return;
                    _saveLocale(value.languageCode);
                    context.setLocale(value);
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 8.h,
                    children: [
                      RadioListTile<Locale>(
                        value: Locale('ru'),
                        title: Text('Русский'),
                      ),
                      RadioListTile<Locale>(
                        value: Locale('uz'),
                        title: Text("O'zbekcha"),
                      ),
                      RadioListTile<Locale>(
                        value: Locale('en'),
                        title: Text('English'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
