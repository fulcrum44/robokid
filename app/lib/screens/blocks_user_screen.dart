import 'package:flutter/material.dart';
import 'package:robokid/widgets/custom_appbar.dart';

class BlockScreen extends StatefulWidget {
   
  const BlockScreen({super.key});

  @override
  State<BlockScreen> createState() => _BlockScreenState();
}

class _BlockScreenState extends State<BlockScreen> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: CustomAppBar(logo: 'Robokids'),
      body: Center(
         child: Text('Aqui irian cosas'),
      ),
    );
  }
}