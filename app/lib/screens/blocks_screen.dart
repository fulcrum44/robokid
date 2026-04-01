import 'package:flutter/material.dart';
import 'package:robokid/widgets/custom_appbar.dart';

class BlocksScreen extends StatefulWidget {
   
  const BlocksScreen({super.key});

  @override
  State<BlocksScreen> createState() => _BlocksScreenState();
}

class _BlocksScreenState extends State<BlocksScreen> {
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