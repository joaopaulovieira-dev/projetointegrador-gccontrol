import 'package:flutter/material.dart';
import 'package:gccontrol/initial_loading.dart';
import 'package:gccontrol/page/Supervisores/supervisores_page.dart';
import 'package:gccontrol/page/control/control_page.dart';
import 'package:gccontrol/page/avaliacao_gc/avaliacao_gc_page.dart';
import 'package:gccontrol/page/gcs/gcs_page.dart';
import 'package:gccontrol/page/igrejas/igrejas_page.dart';
import 'package:gccontrol/page/informacoes_pessoais/informacoes_pessoais_page.dart';
import 'package:gccontrol/page/licoes/licoes_page.dart';
import 'package:gccontrol/page/lideres/lideres_page.dart';
import 'package:gccontrol/page/lista_presenca/lista_presen%C3%A7a_page.dart.dart';
import 'package:gccontrol/page/membros/membros_page.dart';
import 'package:gccontrol/page/secretarios/secretarios_page.dart';
import 'package:gccontrol/page/selecionar_perfil/selecionar_perfil_page.dart';
import 'package:gccontrol/page/verificar_perfil/verificar_perfil_page.dart';
import 'package:gccontrol/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

import 'page/home/home_page.dart';
import 'page/login/login_page.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme,
        ),
        colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppTheme.colors.primary,
            ),
        visualDensity: VisualDensity
            .adaptivePlatformDensity, //Adaptação de densidade de tela
      ),
      title: 'GC Control',
      initialRoute: '/initial_loading',
      routes: {
        '/login': (context) => const LoginPage(), //Tela de Login
        '/home': (context) => HomePage(context: context), //Tela de Home
        '/informacoes_pessoais': (context) =>
            const InformacoesPessoaisPage(), //Tela de Informações Pessoais
        '/control': (context) => const Control(
              userProfile: '',
            ), //Tela de Base
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
      debugShowCheckedModeBanner: false,
    );
  }
}
