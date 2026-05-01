import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:robokid/providers/auth_provider.dart';
import 'package:robokid/routes/app_routes.dart';
import 'package:robokid/config/firebase_options.dart';
import 'package:robokid/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform);

  final prefs = await SharedPreferences.getInstance();
  final String savedTheme = prefs.getString('theme') ?? 'system';

  ThemeMode initialMode;
  if (savedTheme == 'light') initialMode = ThemeMode.light;
  else if (savedTheme == 'dark') initialMode = ThemeMode.dark;
  else initialMode = ThemeMode.system;
  
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MyApp(
        initialTheme: initialMode
      )
    )
    
  );
}

class MyApp extends StatelessWidget {

  final ThemeMode initialTheme;

  const MyApp({super.key, required this.initialTheme});

  static final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);

  @override
  Widget build(BuildContext context) {

    themeNotifier.value = initialTheme;

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          // Etiqueta debug
          debugShowCheckedModeBanner: false,
          // Título
          title: 'RoboKids',
          // Rutas
          initialRoute: AppRoutes.initialRoute,
          routes: AppRoutes.routes,
          onGenerateRoute: AppRoutes.onGenerateRoute,
           // Tema claro/oscuro
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentMode,

          // Builder para cambiar el color de la barra de navegación del sistema (me apetecia vale?)
          builder: (context, child) {
            final theme = Theme.of(context);
            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle(
                systemNavigationBarColor: theme.scaffoldBackgroundColor,
                systemNavigationBarIconBrightness:
                    theme.brightness == Brightness.light
                    ? Brightness.dark
                    : Brightness.light,
              ),
              child: child!,
            );
          },
        );
      },
    );
  }
}