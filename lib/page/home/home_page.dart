// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:gccontrol/theme/app_theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.context,
  });

  final BuildContext context;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _userLinkedToChurch = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _checkUserLinkedToChurch();
  }

  Future<void> _checkUserLinkedToChurch() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final userDoc = await FirebaseFirestore.instance
        .collection('igrejas_usuario')
        .doc(userId)
        .get();
    setState(() {
      _userLinkedToChurch = userDoc.exists;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _searchChurches(_searchController.text);
  }

  Future<void> _searchChurches(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults.clear();
      });
      return;
    }

    try {
      final churchDocs =
          await FirebaseFirestore.instance.collection('igrejas').get();
      final churchDataList = churchDocs.docs
          .where((doc) => removeDiacritics(doc['nome'].toString().toLowerCase())
              .contains(removeDiacritics(query.toLowerCase())))
          .map((doc) => {'id': doc.id, 'nome': doc['nome']})
          .toList();
      setState(() {
        _searchResults = churchDataList;
      });

      // Mostrando as igrejas retornadas no console
      if (kDebugMode) {
        print('Igrejas retornadas:');
      }
      for (var church in _searchResults) {
        if (kDebugMode) {
          print('ID: ${church['id']}, Nome: ${church['nome']}');
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print('Erro ao pesquisar igrejas: $error');
      }
    }
  }

  String removeDiacritics(String str) {
    return str
        .replaceAll('á', 'a')
        .replaceAll('â', 'a')
        .replaceAll('ã', 'a')
        .replaceAll('à', 'a')
        .replaceAll('é', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ô', 'o')
        .replaceAll('õ', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ç', 'c');
  }

  Future<void> _saveUserChurch(String churchId) async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance
          .collection('igrejas_usuario')
          .doc(userId)
          .set({'igrejaId': churchId});
      ScaffoldMessenger.of(widget.context).showSnackBar(
        SnackBar(
            content: const Text(
                'Igreja selecionada com sucesso, faça o login novamente para atualizar suas permissões.',
                style: TextStyle(color: Colors.black)),
            backgroundColor: AppTheme.colors.primary),
      );

      // Realiza logout e redireciona para a tela de login
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacementNamed(context, '/login');
    } catch (error) {
      if (kDebugMode) {
        print('Erro ao salvar a igreja do usuário: $error');
      }
      ScaffoldMessenger.of(widget.context).showSnackBar(
        SnackBar(
            content: const Text('Erro ao selecionar a igreja',
                style: TextStyle(color: Colors.black)),
            backgroundColor: AppTheme.colors.primary),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home', style: TextStyle(fontSize: 30)),
        backgroundColor: AppTheme.colors.appBar,
      ),
      backgroundColor: AppTheme.colors.white,
      body: Container(
        color: AppTheme.colors.background,
        padding: const EdgeInsets.all(30.0),
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: AppTheme.colors.primary,
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!_userLinkedToChurch) ...[
                    const Text(
                      'Selecionar Igreja',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Para acessar suas permissões dentro do sistema, por favor selecione a igreja à qual você pertence.',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        labelText: 'Pesquisar Igreja',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ] else ...[
                    const SizedBox(height: 20),
                    const Stack(
                      alignment: Alignment.center,
                      children: [
                        Column(
                          children: [
                            Text(
                              'Olá, seja bem-vindo ao GC Control!',
                              style: TextStyle(fontSize: 18),
                            ),
                            SizedBox(height: 20),
                            Image(
                              image: AssetImage('assets/images/img_12.png'),
                              width: 367,
                              height: 341,
                            ),
                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                  Expanded(
                    child: _buildChurchList(context),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildChurchList(BuildContext context) {
    if (!_userLinkedToChurch || _searchController.text.isNotEmpty) {
      return ListView.builder(
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          final churchData = _searchResults[index];
          final churchName = churchData['nome'] as String;

          return ListTile(
            title: Text(churchName),
            onTap: () {
              _saveUserChurch(churchData['id']);
            },
          );
        },
      );
    } else {
      return const SizedBox();
    }
  }
}
