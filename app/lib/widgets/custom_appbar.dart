import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showTitle;
  final bool automaticallyImplyLeading;

  const CustomAppBar({
    super.key,
    this.showTitle = true,
    this.automaticallyImplyLeading = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: automaticallyImplyLeading,
      centerTitle: true,
      scrolledUnderElevation: 0,
      title: showTitle ? Image.asset('assets/ROBOKIDS2.png', height: 130) : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
