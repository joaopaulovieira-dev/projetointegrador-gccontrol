// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gccontrol/services/auth_service.dart';
import 'package:gccontrol/theme/app_theme.dart';

class InitialLoading extends StatelessWidget {
  final AuthService _authService = AuthService();

  InitialLoading({superKey, Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<User?>(
        future: _authService.getCurrentUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                backgroundColor: AppTheme.colors.primary,
              ),
            );
          }

          final isUserAuthenticated = snapshot.hasData;

          debugPrint('Usuário autenticado: ${snapshot.data?.email}');

          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(
                context, isUserAuthenticated ? '/control' : '/login');
          });

          return Center(
            child: CircularProgressIndicator(
              backgroundColor: AppTheme.colors.primary,
            ),
          );
        },
      ),
    );
  }
}
