import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gccontrol/initial_loading.dart';
import 'package:gccontrol/page/Supervisores/supervisores_page.dart';
import 'package:gccontrol/page/control/widget/custom_appbar_widget.dart';
import 'package:gccontrol/page/control/widget/menu_lateral_widget.dart';
import 'package:gccontrol/page/control/widget/pagina_selecionada_widget.dart';
import 'package:gccontrol/page/avaliacao_gc/avaliacao_gc_page.dart';
import 'package:gccontrol/page/gcs/gcs_page.dart';
import 'package:gccontrol/page/home/home_page.dart';
import 'package:gccontrol/page/igrejas/igrejas_page.dart';
import 'package:gccontrol/page/informacoes_pessoais/informacoes_pessoais_page.dart';
import 'package:gccontrol/page/licoes/licoes_page.dart';
import 'package:gccontrol/page/lideres/lideres_page.dart';
import 'package:gccontrol/page/lista_presenca/lista_presen%C3%A7a_page.dart.dart';
import 'package:gccontrol/page/login/login_page.dart';
import 'package:gccontrol/page/membros/membros_page.dart';
import 'package:gccontrol/page/secretarios/secretarios_page.dart';
import 'package:gccontrol/page/selecionar_perfil/selecionar_perfil_page.dart';
import 'package:gccontrol/page/verificar_perfil/verificar_perfil_page.dart';
import 'package:gccontrol/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sidebarx/sidebarx.dart';

class Control extends StatefulWidget {
  const Control({super.key, required this.userProfile});

  final String userProfile;

  @override
  State<Control> createState() => _ControlState();
}

class _ControlState extends State<Control> {
  final _controller = SidebarXController(selectedIndex: 0, extended: true);

  final _key = GlobalKey<ScaffoldState>();

  late Future<String> _userProfileFuture;

  @override
  void initState() {
    super.initState();
    _userProfileFuture = getUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _userProfileFuture,
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
              color: AppTheme.colors.white,
              alignment: Alignment.center,
              child: const CircularProgressIndicator());
        } else {
          if (snapshot.hasError) {
            return Text('Erro: ${snapshot.error}');
          } else {
            return _buildControlWidget(snapshot.data ?? '');
          }
        }
      },
    );
  }

  Widget _buildControlWidget(String userProfile) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme,
        ),
        colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppTheme.colors.primary,
            ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      title: 'GC Control',
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => HomePage(context: context),
        '/informacoes_pessoais': (context) => const InformacoesPessoaisPage(),
        '/control': (context) => Control(userProfile: userProfile),
        '/selecionar_perfil': (context) => const SelecionarPerfilPage(),
        '/verificar_perfil': (context) => const VerificarPerfilPage(),
        '/initial_loading': (context) => InitialLoading(),
        '/igrejas': (context) => const IgrejasPage(),
        '/gcs': (context) => const GCsPage(),
        '/membros': (context) => const MembrosPage(),
        '/lista_presenca': (context) => const ListaPresencaPage(),
        '/licoes': (context) => const LicoesPage(),
        '/avaliacao_gc': (context) => const AvaliacaoGcPage(),
        '/supervisores': (context) => const SupervisoresPage(),
        '/lideres': (context) => const LideresPage(),
        '/secretarios': (context) => const SecretariosPage(),
      },
      home: Scaffold(
        key: _key,
        appBar: isSmallScreen
            ? AppBar(
                backgroundColor: AppTheme.colors.menulateralColor,
                title: const Text('GC Control'),
                leading: IconButton(
                  onPressed: () {
                    if (!Platform.isAndroid && !Platform.isIOS) {
                      _controller.setExtended(true);
                    }
                    _key.currentState?.openDrawer();
                  },
                  icon: const Icon(Icons.menu),
                ),
              )
            : null,
        drawer: MenuLateral(
          controller: _controller,
          userProfile: userProfile,
        ),
        body: Row(
          children: [
            if (!isSmallScreen)
              MenuLateral(
                controller: _controller,
                userProfile: userProfile,
              ),
            Expanded(
              child: Scaffold(
                appBar: const CustomAppBarWidget(),
                body: Container(
                  color: AppTheme.colors.background,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 50, right: 50),
                    child: Container(
                      color: AppTheme.colors.background,
                      child: Center(
                        child: PaginaSelecionadaWidget(
                          controller: _controller,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
}
