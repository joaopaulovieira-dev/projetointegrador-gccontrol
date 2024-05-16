// ignore_for_file: use_build_context_synchronously, must_be_immutable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:gccontrol/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomAppBarWidget extends StatefulWidget implements PreferredSizeWidget {
  const CustomAppBarWidget({super.key});

  @override
  Size get preferredSize =>
      const Size.fromHeight(70.0); // Ajuste a altura conforme necessário

  @override
  State<CustomAppBarWidget> createState() => _CustomAppBarWidgetState();
}

class _CustomAppBarWidgetState extends State<CustomAppBarWidget> {
  late String _initials;

  bool _isLoading = true; // Definido como true inicialmente

  @override
  void initState() {
    super.initState();
    _calculateInitials();
  }

  void _calculateInitials() async {
    setState(() {
      _isLoading = true; // Define como true durante o carregamento
    });

    try {
      final snapshot = await getUserPersonalInfo();
      if (snapshot.exists) {
        final fullName = snapshot.data()?['nome'] ?? '';
        final names = fullName.split(' ');
        final initials = names.length >= 2
            ? '${names.first[0]}${names.last[0]}'
            : names.first[0];
        setState(() {
          _initials = initials.toUpperCase();
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao obter informações pessoais: $e');
      }
    } finally {
      setState(() {
        _isLoading = false; // Define como false após o carregamento
      });
    }
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserPersonalInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return await FirebaseFirestore.instance
          .collection('informacoes_pessoais')
          .doc(user.uid)
          .get();
    }
    throw 'Usuário não está autenticado.';
  }

  String getUserFullName() {
    // Substitua por lógica real para obter o nome do usuário logado
    return "João Paulo Vieira Pereira";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        shadowColor: Colors.transparent,
        toolbarHeight: 110,
        backgroundColor: AppTheme.colors.appBar,
        surfaceTintColor: AppTheme.colors.appBar,

        //Botões
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 50.0),
            child: Row(
              children: <Widget>[
                TextButton(
                  onPressed: () {
                    // Ação ao clicar em "Confira as novidades"
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.colors.novidadesColor,
                    textStyle: TextStyle(
                      decoration: TextDecoration.underline, // Texto sublinhado
                      fontSize: 16,
                      fontFamily: GoogleFonts.poppins().fontFamily,
                    ),
                  ),
                  child: const Text(
                    'Confira as novidades',
                  ),
                ),
                const SizedBox(
                  width: 30,
                ),
                const SizedBox(
                  height: 25,
                  child: VerticalDivider(
                    color: Colors.black,
                    thickness: 1,
                    width: 10,
                  ),
                ),
                const SizedBox(
                  width: 30,
                ),
                TextButton(
                  onPressed: () {
                    // Ação ao clicar em "Central de Ajuda"
                  },
                  child: const Text(
                    'Central de Ajuda',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 30,
                ),
                //Notificações
                const CustomPopup(
                  backgroundColor: Colors.white,
                  content: SizedBox(
                    width: 200,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text(
                            'Notificações',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 25, vertical: 8),
                          child: ListTile(
                            title: Text(
                                'Você não possuí nenhuma notificação no momento.'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  child: Icon(
                    Icons.notifications_active_outlined,
                    size: 25,
                  ),
                ),
                const SizedBox(
                  width: 25,
                ),

                CustomPopup(
                  backgroundColor: Colors.white,
                  content: SizedBox(
                    width: 300,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text(
                            'Perfil',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            title: Text('Olá, seja bem-vindo!'),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: ListTile(
                            title: const Text(
                              'Fazer logout',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onTap: () async {
                              try {
                                await FirebaseAuth.instance.signOut();
                                Navigator.pushReplacementNamed(
                                    context, '/login');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: const Text(
                                          'Logoff bem-sucedido!',
                                          style:
                                              TextStyle(color: Colors.black)),
                                      backgroundColor: AppTheme.colors.primary),
                                );
                              } catch (e) {
                                if (kDebugMode) {
                                  print('Erro ao fazer logout: $e');
                                }
                                // Se houver um erro ao fazer logout, você pode exibir uma mensagem de erro ao usuário
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: const Text(
                                          'Erro ao fazer logout. Tente novamente mais tarde.',
                                          style:
                                              TextStyle(color: Colors.black)),
                                      backgroundColor: AppTheme.colors.primary),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: AppTheme.colors.primary,
                            strokeWidth: 3,
                          ),
                        ) // Mostra o indicador de carregamento
                      : _initials.isNotEmpty
                          ? CircleAvatar(
                              maxRadius: 15,
                              backgroundColor: Colors.transparent,
                              child: Text(
                                _initials,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.account_circle_outlined,
                              size: 25,
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
