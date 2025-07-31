import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'screens/home_screen.dart';
import 'services/localization_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Инициализация сервиса локализации
  final localizationService = LocalizationService();
  await localizationService.initialize();
  
  runApp(LiveSkinApp(localizationService: localizationService));
}

class LiveSkinApp extends StatelessWidget {
  final LocalizationService localizationService;
  
  const LiveSkinApp({super.key, required this.localizationService});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: localizationService,
      builder: (context, child) {
        return MaterialApp(
          title: 'Live Skin',
          locale: localizationService.currentLocale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: ThemeData(
            primarySwatch: Colors.deepPurple,
            brightness: Brightness.dark,
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.dark,
            ),
          ),
          home: HomeScreen(localizationService: localizationService),
        );
      },
    );
  }
} 