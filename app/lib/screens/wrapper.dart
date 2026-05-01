import 'package:flutter/material.dart';
import 'package:robokid/screens/screens.dart';
import 'package:robokid/services/services.dart';

class Wrapper extends StatelessWidget {
   
  const Wrapper({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: StreamBuilder(stream: FirebaseServices.auth.authStateChanges(), builder:(context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator()
          );
        } else if (snapshot.hasError) {
            return Center(
              child: Text("Error")
            );
        } else {
          if (snapshot.data == null) {
            return LoginScreen();
          } else {
            return NavegationScreen();
          }
        }
      },),
    );
  }
}