import 'package:flutter/material.dart';
import 'package:robokid/widgets/custom_appbar.dart';

class BlocksUserScreen extends StatefulWidget {
   
  const BlocksUserScreen({super.key});

  @override
  State<BlocksUserScreen> createState() => _BlocksUserScreenState();
}

class _BlocksUserScreenState extends State<BlocksUserScreen> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: customappBar(context: context, logo: 'Robokids'),
      body: Center(
         child: Text('Aqui irian cosas'),
      ),
    );
  }
}