import 'package:flutter/material.dart';

PreferredSizeWidget customappBar({
  required BuildContext context,
  String? logo,
  bool showTitle = true,
  bool automaticallyImplyLeading = false,
  List<Widget>? actions, 
}) {
  return AppBar(
    automaticallyImplyLeading: automaticallyImplyLeading,
    centerTitle: true,
    scrolledUnderElevation: 0,
    title: showTitle? Image.asset(checkLogo(context, logo), height: 50): null,
    actions: actions,
  );
}

String checkLogo(BuildContext context, String? logo) {
  final isLight = Theme.of(context).brightness == Brightness.light;

  switch (logo) {
    case 'Robokids':
      return isLight
          ? 'assets/batmanClaro.jpeg'
          : 'assets/batmanOscuro.jpeg' ;
    default:
      return 'Batman';
  }
}

