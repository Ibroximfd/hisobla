import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisobla/core/ads/ads_helper.dart';
import 'package:hisobla/features/presentation/blocs/hisobla_bloc/hisobla_event.dart';
import 'package:hisobla/features/presentation/pages/settings_page.dart';
import 'package:hisobla/features/presentation/pages/splash_page.dart';
import 'core/di/injection.dart';
import 'features/presentation/blocs/hisobla_bloc/hisobla_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Status bar shaffof
      statusBarIconBrightness: Brightness.light, // Iconlar oq (chunki fon ko'k)
      statusBarBrightness: Brightness.dark, // iOS uchun
    ),
  );

  // SharedPreferences bilan DI setup
  await setupDependencies();

  // Google Mobile Ads initialization
  await AdsManager().initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<BudgetBloc>()..add(LoadBudgetEvent()),
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Hisobla',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        ),
        home: const SplashPage(),
      ),
    );
  }
}
