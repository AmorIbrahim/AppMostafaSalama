import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_colors.dart';
import 'core/localization/app_localizations.dart';
import 'core/localization/app_language_provider.dart';
import 'core/network/api_client.dart';
import 'core/storage/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/orders_provider.dart';
import 'providers/theme_provider.dart';
import 'features/auth/login_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'services/notification_service.dart';
import 'shared/widgets/brand_logo.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system navigation bar & status bar transparent styling
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize secure persistent storage
  final storageService = await StorageService.init();

  // Initialize centralized API client
  final apiClient = ApiClient(storageService: storageService);

  runApp(
    MultiProvider(
      providers: [
        Provider<StorageService>.value(value: storageService),
        Provider<ApiClient>.value(value: apiClient),
        ChangeNotifierProvider<AppLanguageProvider>(
          create: (_) => AppLanguageProvider(storageService: storageService),
        ),
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(storageService: storageService),
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(
            apiClient: apiClient,
            storageService: storageService,
          )..initAuth(),
        ),
        ChangeNotifierProvider<OrdersProvider>(
          create: (_) => OrdersProvider(apiClient: apiClient),
        ),
      ],
      child: const MostafaSalamaDeliveryApp(),
    ),
  );
}

/// Root Application Widget
class MostafaSalamaDeliveryApp extends StatelessWidget {
  const MostafaSalamaDeliveryApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final langProvider = context.watch<AppLanguageProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      navigatorKey: NotificationService.navigatorKey,
      title: 'Mostafa Salama Delivery',
      debugShowCheckedModeBanner: false,
      locale: langProvider.currentLocale,
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: themeProvider.themeMode,
      home: const AuthGate(),
    );
  }
}

/// Authentication State Gateway deciding root route
class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    switch (auth.status) {
      case AuthStatus.uninitialized:
        return const _SplashScreen();
      case AuthStatus.authenticated:
        return const DashboardScreen();
      case AuthStatus.unauthenticated:
      case AuthStatus.mustChangePassword:
        return const LoginScreen();
    }
  }
}

/// Brand Splash Loader during initial auth token verification
class _SplashScreen extends StatelessWidget {
  const _SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BrandLogo(size: 96, showSubtitle: true, isLight: false),
            SizedBox(height: 36),
            CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 2.5,
            ),
          ],
        ),
      ),
    );
  }
}
