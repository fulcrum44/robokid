import 'package:flutter/material.dart';
import 'package:robokid/screens/screens.dart';


class AppRoutes {
  // Ruta inicial
  static const initialRoute = 'login';

  // Mapa de rutas
  static final menuOptions = <MenuOption>[
    MenuOption(
      route: 'login',
      name: 'LoginScreen',
      screen: const LoginScreen(),
    ),
    MenuOption(
      route: 'registerUser',
      name: 'RegisterUser',
      screen: const RegisterScreen(),
    ),
    MenuOption(
      route: 'blocksScreenUser',
      name: 'BlocksScreenUser',
      screen: const BlocksUserScreen(),
    ),
     MenuOption(
      route: 'blocksScreenInvitate',
      name: 'blocksScreenInvitate',
      screen: const BlocksInvitateScreen(),
    ),
  ];

  // Método para mapear la lista de rutas
  static Map<String, Widget Function(BuildContext)> getAppRoutes() {
    Map<String, Widget Function(BuildContext)> appRoutes = {};

    for (final option in menuOptions) {
      appRoutes.addAll({option.route: (BuildContext context) => option.screen});
    }

    return appRoutes;
  }
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) => LoginScreen(),
    ); //con esto si llamo a una pagina qie no existe
    //te lleva a la de login
  } 
}
class MenuOption {
  final String route;
  final String name;
  final Widget screen;

  MenuOption({
    required this.route, 
    required this.name, 
    required this.screen
  });
}