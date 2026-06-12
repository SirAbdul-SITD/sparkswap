// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'game/game_state.dart';
import 'utils/audio_manager.dart';
import 'utils/preferences.dart';
import 'screens/home_screen.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF140D06),
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  await Preferences.instance.init();
  await AudioManager.instance.init();
  runApp(const SparkSwapApp());
}

class SparkSwapApp extends StatelessWidget {
  const SparkSwapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameState(),
      child: MaterialApp(
        title: 'SparkSwap',
        debugShowCheckedModeBanner: false,
        navigatorObservers: [routeObserver],
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: const Color(0xFF140D06),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFFFB74D),
            surface: Color(0xFF221608),
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
