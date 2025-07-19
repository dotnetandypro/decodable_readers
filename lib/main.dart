import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'providers/story_provider.dart';
import 'theme/app_theme.dart';
import 'services/settings_service.dart';
import 'services/progress_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize settings service
  await SettingsService.instance.loadSettings();

  // Initialize progress service
  await ProgressService.instance.initialize();

  runApp(const DecodableReaderApp());
}

class DecodableReaderApp extends StatelessWidget {
  const DecodableReaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Set preferred orientations
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => StoryProvider())],
      child: MaterialApp(
        title: 'Decodable Reader',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const HomeScreen(),
        builder: (context, child) {
          // Disable system text scaling to ensure consistent font sizes
          // across all devices (iPhone, iPad, etc.)
          return MediaQuery.withClampedTextScaling(
            minScaleFactor: 1.0,
            maxScaleFactor: 1.0,
            child: child!,
          );
        },
      ),
    );
  }
}
