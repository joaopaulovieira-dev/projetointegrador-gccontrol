import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gccontrol/page/Supervisores/supervisores_page.dart';
import 'package:gccontrol/page/avaliacao_gc/avaliacao_gc_page.dart';
import 'package:gccontrol/page/gcs/gcs_page.dart';
import 'package:gccontrol/page/home/home_page.dart';
import 'package:gccontrol/page/igrejas/igrejas_page.dart';
import 'package:gccontrol/page/licoes/licoes_page.dart';
import 'package:gccontrol/page/lideres/lideres_page.dart';
import 'package:gccontrol/page/lista_presenca/lista_presen%C3%A7a_page.dart.dart';

import 'package:gccontrol/page/membros/membros_page.dart';
import 'package:gccontrol/page/secretarios/secretarios_page.dart';
import 'package:sidebarx/sidebarx.dart';

class PaginaSelecionadaWidget extends StatelessWidget {
  const PaginaSelecionadaWidget({
    super.key,
    required this.controller,
  });

  final SidebarXController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return FutureBuilder<String>(
          future: getUserProfile(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else {
              if (snapshot.hasError) {
                return Text('Erro: ${snapshot.error}');
              } else {
                final userProfile = snapshot.data!;
                return _getPageByIndex(
                    userProfile, controller.selectedIndex, context);
              }
            }
          },
        );
      },
    );
  }

  Future<String> getUserProfile() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userProfileSnapshot = await FirebaseFirestore.instance
          .collection('perfil_usuario')
          .doc(user.uid)
          .get();
      if (userProfileSnapshot.exists) {
        Map<String, dynamic> userProfileData =
            userProfileSnapshot.data() as Map<String, dynamic>;
        return userProfileData['perfil'] ?? '';
      } else {
        return ''; // Retorna vazio se o perfil do usuário não for encontrado
      }
    } else {
      return ''; // Retorna vazio se o usuário não estiver autenticado
    }
  }

  Widget _getPageByIndex(String userProfile, int index, BuildContext context) {
    switch (userProfile) {
      case 'Administrador':
        return _getPageByIndexAdministrador(index, context);
      case 'Supervisor':
        return _getPageByIndexSupervisor(index, context);
      case 'Líder':
        return _getPageByIndexLider(index, context);
      case 'Secretário':
        return _getPageByIndexSecretario(index, context);
      default:
        return HomePage(context: context);
    }
  }

  Widget _getPageByIndexAdministrador(int index, BuildContext context) {
    switch (index) {
      case 0:
        return HomePage(context: context); //Home
      case 1:
        return const IgrejasPage(); //Igrejas
      case 2:
        return const SupervisoresPage(); //Supervisores
      case 3:
        return const LideresPage(); //Líderes
      case 4:
        return const SecretariosPage(); //Secretários
      case 5:
        return const LicoesPage(); //Lições
      case 6:
        return const GCsPage(); //GCs
      case 7:
        return const MembrosPage(); //Membros
      case 8:
        return const ListaPresencaPage(); //Lista de Presença
      case 9:
        return const AvaliacaoGcPage(); //Avaliação de GC
      default:
        return HomePage(context: context);
    }
  }

  Widget _getPageByIndexSupervisor(int index, BuildContext context) {
    switch (index) {
      case 0:
        return HomePage(context: context); //Home
      case 1:
        return const LideresPage(); //Líderes
      case 2:
        return const SecretariosPage(); //Secretários
      case 3:
        return const LicoesPage(); //Lições
      case 4:
        return const GCsPage(); //GCs

      case 5:
        return const MembrosPage(); //Membros
      case 6:
        return const ListaPresencaPage(); //Lista de Presença
      case 7:
        return const AvaliacaoGcPage(); //Avaliação de GC
      default:
        return HomePage(context: context);
    }
  }

  Widget _getPageByIndexLider(int index, BuildContext context) {
    switch (index) {
      case 0:
        return HomePage(context: context); //Home
      case 1:
        return const SecretariosPage(); //Secretários
      case 2:
        return const LicoesPage(); //Lições
      case 3:
        return const GCsPage(); //GCs
      case 4:
        return const MembrosPage(); //Membros
      case 5:
        return const ListaPresencaPage(); //Lista de Presença
      case 6:
        return const AvaliacaoGcPage(); //Avaliação de GC
      default:
        return HomePage(context: context);
    }
  }

  Widget _getPageByIndexSecretario(int index, BuildContext context) {
    switch (index) {
      case 0:
        return HomePage(context: context); //Home
      case 1:
        return const LicoesPage(); //Lições
      case 2:
        return const MembrosPage(); //Membros
      case 3:
        return const ListaPresencaPage(); //Lista de Presença
      case 4:
        return const AvaliacaoGcPage(); //Avaliação de GC
      default:
        return HomePage(context: context);
    }
  }
}
