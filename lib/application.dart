import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'core/domain/routing/router.dart';
import 'core/utils/bloc/theme/theme_bloc.dart';
import 'core/utils/providers.dart';
import 'core/utils/themes/app_themes.dart';

class Application extends StatelessWidget {
  const Application({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: providers,
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          return ScreenUtilInit(
            designSize: const Size(375, 812),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (context, child) {
              return MaterialApp.router(
                /// Ui
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                // themeMode: state.themeMode,

                /// Navigation
                routerConfig: router,

                /// Localization on easy_localization
                locale: context.locale,
                localizationsDelegates: context.localizationDelegates,
                supportedLocales: context.supportedLocales,

                /// Finish?
                debugShowCheckedModeBanner: false,
              );
            },
          );
        },
      ),
    );
  }
}
