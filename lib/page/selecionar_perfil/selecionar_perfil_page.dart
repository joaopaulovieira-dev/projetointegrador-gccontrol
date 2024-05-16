// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importar o FirebaseAuth
import 'package:gccontrol/share/widget/menu_widget.dart';
import 'package:gccontrol/theme/app_theme.dart';

class SelecionarPerfilPage extends StatefulWidget {
  const SelecionarPerfilPage({super.key});

  @override
  State<SelecionarPerfilPage> createState() => _SelecionarPerfilPageState();
}

class _SelecionarPerfilPageState extends State<SelecionarPerfilPage> {
  String _activeMenuItem = 'Entrar';
  int _selectedProfileIndex = -1; // Índice do perfil selecionado
  bool isLoading = false;
  User? _user; // Usuário atualmente logado

  final List<Map<String, dynamic>> _profiles = [
    {
      'title': 'Administrador',
      'description': 'Administre todos os aspectos do GC da sua igreja',
      'image':
          'assets/images/administrador_igreja.png', // Substitua pelo caminho da sua imagem
    },
    {
      'title': 'Supervisor',
      'description': 'Acompanhe de perto os GCs que integram sua hierarquia',
      'image':
          'assets/images/supervisor.png', // Substitua pelo caminho da sua imagem
    },
    {
      'title': 'Líder',
      'description': 'Instrua, oriente e motive os membros do seu GC',
      'image':
          'assets/images/lider.png', // Substitua pelo caminho da sua imagem
    },
    {
      'title': 'Secretário',
      'description':
          'Registre e forneça feedback sobre as informações do seu GC',
      'image':
          'assets/images/secretario.png', // Substitua pelo caminho da sua imagem
    },
  ];

  void _setActiveMenuItem(String item) {
    setState(() {
      _activeMenuItem = item;
    });
  }

  @override
  void initState() {
    super.initState();
    // Verificar se há um usuário logado
    _user = FirebaseAuth.instance.currentUser;
    // Se o usuário for nulo, redirecionar para a tela de login
    if (_user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/login');
      });
    }
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
            height: 20,
          ),
          const Text('Selecione o seu perfil',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              )),
          const Text(
            'Selecione o perfil que mais se encaixa com o seu papel na igreja dentro do GC.',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(
            height: 50,
          ),
          SizedBox(
            height: 300, // Altura do slide

            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _profiles.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedProfileIndex =
                          index; // Atualizar o perfil selecionado
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    width: 220, // Largura do item do slide
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: _selectedProfileIndex == index
                          ? AppTheme
                              .colors.primary // Cor de fundo quando selecionado
                          : Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset:
                              const Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          _profiles[index]['image'],
                          width: 150, // Largura da imagem
                          height: 150, // Altura da imagem
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          _profiles[index]['title'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _selectedProfileIndex == index
                                ? Colors
                                    .white // Cor do título quando selecionado
                                : Colors.black,
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          _profiles[index]['description'],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _selectedProfileIndex == index
                                ? Colors
                                    .white // Cor da descrição quando selecionado
                                : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 70),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 300, // Largura do botão
                child: ElevatedButton(
                  onPressed: () {
                    // Implemente a ação do botão
                    _saveUserProfile(_selectedProfileIndex);
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: AppTheme.colors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: SizedBox(
                    height: 50,
                    child: Center(
                      child: isLoading
                          ? const CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            )
                          : const Text('Cadastrar'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _saveUserProfile(int selectedIndex) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        isLoading = true;
      });

      try {
        await FirebaseFirestore.instance
            .collection('perfil_usuario')
            .doc(user.uid)
            .set({
          'perfil': _profiles[selectedIndex]['title'],
          // Adicione aqui outros campos relevantes do perfil, se necessário
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: const Text('Perfil salvo com sucesso.',
                  style: TextStyle(color: Colors.black)),
              backgroundColor: AppTheme.colors.primary),
        );

// Redirecionar para a página de informações pessoais após salvar o perfil
        Navigator.pushReplacementNamed(context, '/informacoes_pessoais');
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erro ao salvar o perfil: $error',
                  style: const TextStyle(color: Colors.black)),
              backgroundColor: AppTheme.colors.primary),
        );
      }

      setState(() {
        isLoading = false;
      });
    }
  }
}
