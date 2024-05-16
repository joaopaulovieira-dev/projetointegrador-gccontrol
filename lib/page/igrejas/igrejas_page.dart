// ignore_for_file: library_private_types_in_public_api, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gccontrol/page/igrejas/widgets/igreja_editar_widget.dart';
import 'package:gccontrol/page/igrejas/widgets/igreja_form_widget.dart'; // Importe o widget do formulário de cadastro
import 'package:gccontrol/page/igrejas/widgets/igrejas_list_widget.dart';
import 'package:gccontrol/theme/app_theme.dart';

class IgrejasPage extends StatefulWidget {
  const IgrejasPage({Key? key});

  @override
  _IgrejasPageState createState() => _IgrejasPageState();
}

class _IgrejasPageState extends State<IgrejasPage> {
  final _firestore = FirebaseFirestore.instance;
  bool _showForm = false;
  bool _isEditing =
      false; // Variável para controlar se estamos editando ou criando uma nova igreja
  late String _selectedIgrejaId; // ID da igreja selecionada

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Igrejas', style: TextStyle(fontSize: 30)),
        elevation: 0,
        shadowColor: Colors.transparent,
        backgroundColor: AppTheme.colors.appBar,
        surfaceTintColor: AppTheme.colors.appBar,
        // Adicionando botão de retorno quando o formulário estiver sendo exibido
        leading: _showForm
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _showForm = false;
                  });
                },
              )
            : null,
      ),
      backgroundColor: AppTheme.colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Cadastre sua igreja para poder gerenciar os grupos de células e membros.',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: _showForm
                ? _isEditing
                    ? IgrejaEditarWidget(igrejaId: _selectedIgrejaId)
                    : const IgrejaFormWidget() // Aqui exibimos o formulário de cadastro se _showForm for verdadeiro
                : StreamBuilder<QuerySnapshot>(
                    stream: _firestore.collection('igrejas').snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return IgrejasListWidget(
                          snapshot: snapshot.data!,
                          onIgrejaSelected: (igrejaId) {
                            setState(() {
                              _showForm = true;
                              _isEditing =
                                  true; // Indicar que estamos editando, não criando uma nova igreja
                              _selectedIgrejaId =
                                  igrejaId; // Definir o ID da igreja selecionada
                            });
                          },
                          currentUserId: FirebaseAuth.instance.currentUser!.uid,
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text(
                              'Erro ao carregar igrejas: ${snapshot.error}'),
                        );
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: !_showForm
          ? FloatingActionButton(
              onPressed: () {
                setState(() {
                  _showForm = true;
                  _isEditing =
                      false; // Indicar que estamos criando uma nova igreja, não editando
                });
              },
              tooltip: 'Cadastrar Nova Igreja',
              backgroundColor: AppTheme.colors.primary,
              child: Icon(Icons.add, color: AppTheme.colors.white),
            )
          : null, // Ocultando o botão flutuante quando o formulário estiver sendo exibido
    );
  }
}
