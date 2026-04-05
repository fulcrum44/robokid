import 'package:flutter/material.dart';
import 'package:robokid/widgets/custom_appbar.dart';

class BlocksInvitateScreen extends StatefulWidget {
   
  const BlocksInvitateScreen({super.key});

  @override
  State<BlocksInvitateScreen> createState() => _BlocksInvitateScreenState();
}

class _BlocksInvitateScreenState extends State<BlocksInvitateScreen> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: customappBar(context: context, logo: 'Robokids'),
      body: Center(
         child: Text('Aqui irian cosas en la de invitado'),
      ),
    );
  }
}