import 'package:flutter/material.dart';
import 'package:robokid/screens/screens.dart';

class AppRoutes {
  // Ruta inicial
  static const initialRoute = 'wrapper';

  static Map<String, Widget Function(BuildContext)> routes = {
    'wrapper': (BuildContext context) => const Wrapper(),
    'navigation': (BuildContext context) => const NavigationScreen(),
    'login': (BuildContext context) => const LoginScreen(),
    'signup': (BuildContext context) => const RegisterScreen(),
    'blocksScreen': (BuildContext context) => const BlockScreen(),
    'record': (BuildContext context) => const RecordScreen(),
    'config': (BuildContext context) => const ConfigScreen(),
  };

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) => Wrapper(),
    ); //con esto si llamo a una pagina qie no existe
    //te lleva a la de login
  }
}
