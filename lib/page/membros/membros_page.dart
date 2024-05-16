// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gccontrol/page/membros/widgets/membro_editar_widget.dart';
import 'package:gccontrol/page/membros/widgets/membro_form_widget.dart';
import 'package:gccontrol/page/membros/widgets/membros_list_widget.dart';
import 'package:gccontrol/theme/app_theme.dart';

class MembrosPage extends StatefulWidget {
  const MembrosPage({super.key});

  @override
  _MembrosPageState createState() => _MembrosPageState();
}

class _MembrosPageState extends State<MembrosPage> {
  final _firestore = FirebaseFirestore.instance;
  bool _showForm = false;
  bool _isEditing =
      false; // Variável para controlar se estamos editando ou criando uma nova igreja
  late String _selectedMembroId; // ID da igreja selecionada

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Membros', style: TextStyle(fontSize: 30)),
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
              'Cadastre os membros do seu GC para poder gerenciar as presenças e atividades.',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: _showForm
                ? _isEditing
                    ? MembroEditarWidget(membroId: _selectedMembroId)
                    : const MembroFormWidget() // Aqui exibimos o formulário de cadastro se _showForm for verdadeiro
                : StreamBuilder<QuerySnapshot>(
                    stream: _firestore.collection('membros').snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return MembrosListWidget(
                          snapshot: snapshot.data!,
                          onMembroSelected: (membroId) {
                            setState(() {
                              _showForm = true;
                              _isEditing =
                                  true; // Indicar que estamos editando, não criando uma nova igreja
                              _selectedMembroId =
                                  membroId; // Definir o ID da igreja selecionada
                            });
                          },
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text(
                              'Erro ao carregar membros: ${snapshot.error}'),
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
              tooltip: 'Cadastrar Novo Membro',
              backgroundColor: AppTheme.colors.primary,
              child: Icon(Icons.add, color: AppTheme.colors.white),
            )
          : null, // Ocultando o botão flutuante quando o formulário estiver sendo exibido
    );
  }
}
