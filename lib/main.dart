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

  // System UI setup - async emas
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  // FAQAT zarur bo'lgan initialization
  await setupDependencies();

  // Locale initialization - tez
  await initializeDateFormatting('uz', null);

  runApp(const MyApp());

  // Background initialization - app ochilgandan keyin
  _initializeBackgroundServices();
}

// Bu funksiya app ochilgandan KEYIN ishga tushadi
Future<void> _initializeBackgroundServices() async {
  // AdMob - background
  AdsManager().initialize().catchError((e) {
    debugPrint('❌ AdMob initialization error: $e');
  });

  // Notification - background
  NotificationService()
      .initialize()
      .then((_) {
        NotificationService().scheduleDailyAnalysis();
      })
      .catchError((e) {
        debugPrint('❌ Notification initialization error: $e');
      });
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
        // Main page'dan Analysis page'ga o'tish
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (_) => const AnalysisPage()),
        );
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
        // Routes ni olib tashlash - Navigator.push ishlatamiz
      ),
    );
  }
}
