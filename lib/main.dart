import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisobla/core/ads/ads_helper.dart';
import 'package:hisobla/core/services/notification_service.dart';
import 'package:hisobla/features/presentation/blocs/hisobla_bloc/hisobla_event.dart';
import 'package:hisobla/features/presentation/pages/analysis_page.dart';
import 'package:hisobla/features/presentation/pages/splash_page.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/di/injection.dart';
import 'features/presentation/blocs/hisobla_bloc/hisobla_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  // Dependencies setup
  await setupDependencies();

  // Google Mobile Ads
  await AdsManager().initialize();

  await initializeDateFormatting('uz', null);

  // Notification service
  await NotificationService().initialize();
  await NotificationService().scheduleDailyAnalysis();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();

    // Notification bosilganda page ochish
    NotificationService.onNotificationTap = (String payload) {
      if (payload == 'daily_analysis') {
        navigatorKey.currentState?.pushNamed('/analysis');
      }
    };
  }

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
        routes: {'/analysis': (context) => const AnalysisPage()},
      ),
    );
  }
}
