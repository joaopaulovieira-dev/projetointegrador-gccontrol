// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:gccontrol/theme/app_theme.dart';

class SecretariosPage extends StatefulWidget {
  const SecretariosPage({super.key});

  @override
  _SecretariosPageState createState() => _SecretariosPageState();
}

class _SecretariosPageState extends State<SecretariosPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Secretários', style: TextStyle(fontSize: 30)),
        elevation: 0,
        shadowColor: Colors.transparent,
        backgroundColor: AppTheme.colors.appBar,
        surfaceTintColor: AppTheme.colors.appBar,
      ),
      backgroundColor: AppTheme.colors.white,
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Secretários',
            )
          ],
        ),
      ),
    );
  }
}
