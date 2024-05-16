// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importar o FirebaseAuth
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gccontrol/theme/app_theme.dart';

class VerificarPerfilPage extends StatefulWidget {
  const VerificarPerfilPage({super.key});

  @override
  _VerificarPerfilPageState createState() => _VerificarPerfilPageState();
}

class _VerificarPerfilPageState extends State<VerificarPerfilPage> {
  @override
  void initState() {
    super.initState();
    // Verificar se o usuário tem um perfil cadastrado
    _checkProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(
          color: AppTheme.colors.primary,
        ), // Mostrar indicador de carregamento enquanto verifica o perfil
      ),
    );
  }

  void _checkProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final profileDoc = await FirebaseFirestore.instance
          .collection('perfil_usuario')
          .doc(user.uid)
          .get();
      final personalInfoDoc = await FirebaseFirestore.instance
          .collection('informacoes_pessoais')
          .doc(user.uid)
          .get();

      final hasProfile = profileDoc.exists;
      final hasPersonalInfo = personalInfoDoc.exists;

      if (hasProfile && hasPersonalInfo) {
        // Se tanto o perfil quanto as informações pessoais estiverem preenchidos,
        // redirecionar para '/control'
        Navigator.pushReplacementNamed(context, '/control');
      } else if (hasProfile && !hasPersonalInfo) {
        // Se o perfil está preenchido mas as informações pessoais não estão,
        // redirecionar para a tela de informações pessoais
        Navigator.pushReplacementNamed(context, '/informacoes_pessoais');
      } else {
        // Se o perfil não está preenchido, redirecionar para a tela de seleção de perfil
        Navigator.pushReplacementNamed(context, '/selecionar_perfil');
      }
    }
  }
}
