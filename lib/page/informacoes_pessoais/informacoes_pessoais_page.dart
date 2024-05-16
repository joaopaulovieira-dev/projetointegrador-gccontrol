// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:gccontrol/page/informacoes_pessoais/widget/form_informacoes_pessoais_widget.dart';
import 'package:gccontrol/share/widget/menu_widget.dart';
import 'package:gccontrol/theme/app_theme.dart';

class InformacoesPessoaisPage extends StatefulWidget {
  const InformacoesPessoaisPage({super.key});

  @override
  _InformacoesPessoaisPageState createState() =>
      _InformacoesPessoaisPageState();
}

class _InformacoesPessoaisPageState extends State<InformacoesPessoaisPage> {
  bool isLoading = false;
  String _activeMenuItem = 'Entrar';

  void _setActiveMenuItem(String item) {
    setState(() {
      _activeMenuItem = item;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colors.background,
      body: ListView(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width / 8,
        ),
        children: [
          Menu(
            activeItem: _activeMenuItem,
            onItemPressed: (item) {
              _setActiveMenuItem(item); // Atualizar o item de menu ativo
            },
          ),
          const SizedBox(
            height: 10,
          ),
          const Text('Complete seu cadastro!',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              )),
          const Text(
            'Para prosseguir, precisamos de algumas informações suas.',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          Row(
            children: [
              const InformacoesPessoaisFormWidget(),
              const SizedBox(
                width: 200,
              ),
              Image.asset(
                'images/img_09.png',
              ),
            ],
          )
        ],
      ),
    );
  }
}
