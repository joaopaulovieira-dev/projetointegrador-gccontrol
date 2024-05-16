// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:gccontrol/theme/app_theme.dart';

class LideresPage extends StatefulWidget {
  const LideresPage({super.key});

  @override
  _LideresPageState createState() => _LideresPageState();
}

class _LideresPageState extends State<LideresPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Líderes', style: TextStyle(fontSize: 30)),
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
              'Líderes',
            )
          ],
        ),
      ),
    );
  }
}
