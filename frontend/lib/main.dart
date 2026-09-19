import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'l10n/app_localizations.dart';
import 'screens/auth/auth_gate.dart';
import 'services/language_service.dart';
import 'utils/app_theme.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Language Preference from local storage
  await languageService.initialize();

  // Supabase Initialization
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    // ignore: deprecated_member_use
    anonKey: AppConstants.supabaseAnonKey,
  );

  runApp(const FarmToMarketApp());
}

class FarmToMarketApp extends StatelessWidget {
  const FarmToMarketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: languageService,
      builder: (context, _) {
        return MaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          locale: languageService.currentLocale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const AuthGate(),
        );
      },
    );
  }
}
