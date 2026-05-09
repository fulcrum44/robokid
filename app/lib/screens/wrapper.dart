import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:robokid/providers/providers.dart';
import 'package:robokid/screens/screens.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.isLoading) {
      return Scaffold(body: CircularProgressIndicator());
    }

    return auth.user == null ? LoginScreen() : NavigationScreen();
  }
}
