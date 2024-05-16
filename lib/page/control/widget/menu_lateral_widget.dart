import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:gccontrol/theme/app_theme.dart';
import 'package:sidebarx/sidebarx.dart';

class MenuLateral extends StatelessWidget {
  const MenuLateral({
    super.key,
    required SidebarXController controller,
    required this.userProfile,
  }) : _controller = controller;

  final SidebarXController _controller;
  final String userProfile; // Perfil do usuário atual

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: checkUserInIgrejasUsuario(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Retorna um widget de carregamento enquanto a consulta está em andamento
          return const CircularProgressIndicator();
        } else {
          if (snapshot.hasError) {
            // Se ocorrer um erro durante a consulta, exiba uma mensagem de erro
            return Text('Erro: ${snapshot.error}');
          } else {
            // Verifica se o usuário está presente na coleção igrejas_usuario
            final bool userInIgrejasUsuario = snapshot.data ?? false;
            return SidebarX(
              controller: _controller,
              theme: SidebarXTheme(
                decoration: BoxDecoration(
                  color: AppTheme.colors.menulateralColor,
                ),
                //cor do item selecionado
                hoverColor: Colors.transparent,

                //cor do texto
                textStyle: TextStyle(
                  color: AppTheme.colors.enabletextmenulateralColor,
                  fontSize: 16,
                ),

                //cor e tamanho do texto quando selecionado
                selectedTextStyle: TextStyle(
                  color: AppTheme.colors.enabletextmenulateralColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),

                //cor do texto ao passar o mouse
                hoverTextStyle: TextStyle(
                  color: AppTheme.colors.enabletextmenulateralColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),

                //padding do texto
                itemTextPadding: const EdgeInsets.only(left: 30),

                //padding do texto quando selecionado
                selectedItemTextPadding: const EdgeInsets.only(left: 30),

                //cor de fundo do item selecionado
                selectedItemDecoration: BoxDecoration(
                  color: AppTheme.colors.primary,
                ),

                //cor e tamanho do ícone
                iconTheme: IconThemeData(
                  color: AppTheme.colors.textmenulateralColor,
                  size: 25,
                ),

                //cor e tamanho do ícone quando selecionado
                selectedIconTheme: IconThemeData(
                  color: AppTheme.colors.enabletextmenulateralColor,
                  size: 25,
                ),
              ),

              //cor do rodapé
              extendedTheme: SidebarXTheme(
                width: 250,
                textStyle: const TextStyle(
                  fontSize: 16,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.colors.menulateralColor,
                ),
              ),
              footerDivider: Divider(
                color: Colors.black.withOpacity(0.3),
                height: 1,
              ),
              headerBuilder: (context, extended) {
                return const Padding(
                  padding: EdgeInsets.only(top: 20, bottom: 20),
                  // child: Text(
                  //   'GC',
                  //   style: TextStyle(
                  //     fontSize: 18,
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),
                  child: Image(
                    image: AssetImage('assets/images/logo_menu.png'),
                    width: 50,
                  ),
                );
              },
              items: [
                if (userProfile == 'Administrador' ||
                    userProfile == 'Supervisor' ||
                    userProfile == 'Líder' ||
                    userProfile == 'Secretário')
                  SidebarXItem(
                    icon: Icons.home,
                    label: 'Home',
                    onTap: () {
                      debugPrint('Home');
                    },
                  ),
                if (userProfile == 'Administrador')
                  const SidebarXItem(
                    icon: Icons.church,
                    label: 'Igrejas',
                  ),
                if (userInIgrejasUsuario && userProfile == 'Administrador')
                  const SidebarXItem(
                    icon: Icons.groups,
                    label: 'Supervisores',
                  ),
                if (userInIgrejasUsuario &&
                    (userProfile == 'Administrador' ||
                        userProfile == 'Supervisor'))
                  const SidebarXItem(
                    icon: Icons.people,
                    label: 'Líderes',
                  ),
                if (userInIgrejasUsuario &&
                    (userProfile == 'Administrador' ||
                        userProfile == 'Supervisor' ||
                        userProfile == 'Líder'))
                  const SidebarXItem(
                    icon: Icons.person,
                    label: 'Secretários',
                  ),
                if (userInIgrejasUsuario &&
                    (userProfile == 'Administrador' ||
                        userProfile == 'Supervisor' ||
                        userProfile == 'Líder' ||
                        userProfile == 'Secretário'))
                  const SidebarXItem(
                    icon: Icons.book,
                    label: 'Lições',
                  ),
                if (userInIgrejasUsuario &&
                    (userProfile == 'Administrador' ||
                        userProfile == 'Supervisor' ||
                        userProfile == 'Líder'))
                  const SidebarXItem(
                    icon: Icons.bookmark,
                    label: 'GCs',
                  ),
                if (userInIgrejasUsuario &&
                    (userProfile == 'Administrador' ||
                        userProfile == 'Supervisor' ||
                        userProfile == 'Líder' ||
                        userProfile == 'Secretário'))
                  const SidebarXItem(
                    icon: Icons.supervised_user_circle,
                    label: 'Membros',
                  ),
                if (userInIgrejasUsuario &&
                    (userProfile == 'Administrador' ||
                        userProfile == 'Supervisor' ||
                        userProfile == 'Líder' ||
                        userProfile == 'Secretário'))
                  const SidebarXItem(
                    icon: Icons.checklist,
                    label: 'Lista de Presença',
                  ),
                if (userInIgrejasUsuario &&
                    (userProfile == 'Administrador' ||
                        userProfile == 'Supervisor' ||
                        userProfile == 'Líder' ||
                        userProfile == 'Secretário'))
                  const SidebarXItem(
                    icon: Icons.fact_check,
                    label: 'Avaliação de GCs',
                  ),
              ],
            );
          }
        }
      },
    );
  }

  Future<bool> checkUserInIgrejasUsuario() async {
    try {
      // Obtém o ID do usuário atual
      String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        // Verifica se o usuário está na coleção igrejas_usuario
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('igrejas_usuario')
            .doc(userId)
            .get();
        if (kDebugMode) {
          print('Usuário em igrejas_usuario: ${userSnapshot.exists}');
        }
        return userSnapshot.exists;
      }
      return false;
    } catch (e) {
      // Em caso de erro, imprime o erro e retorna false
      if (kDebugMode) {
        print('Erro ao verificar usuário em igrejas_usuario: $e');
      }
      return false;
    }
  }
}

final divider = Divider(
  color: Colors.black.withOpacity(0.3),
  height: 1,
);
