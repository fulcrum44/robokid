import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? logo;
  final bool showTitle;
  final bool automaticallyImplyLeading;

  const CustomAppBar({
    super.key,
    this.logo,
    this.showTitle = true,
    this.automaticallyImplyLeading = false,
  });

  String _checkLogo(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    switch (logo) {
      case 'Robokids':
        return isLight ? 'assets/batmanClaro.jpeg' : 'assets/batmanOscuro.jpeg';
      default:
        return 'Batman';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: automaticallyImplyLeading,
      centerTitle: true,
      scrolledUnderElevation: 0,
      title: showTitle ? Image.asset(_checkLogo(context), height: 50) : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
