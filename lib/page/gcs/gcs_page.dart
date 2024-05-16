// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gccontrol/page/gcs/widgets/gc_editar_widget.dart';
import 'package:gccontrol/page/gcs/widgets/gcs_form_widget.dart';

import 'package:gccontrol/page/gcs/widgets/gcs_list_widget.dart';
import 'package:gccontrol/theme/app_theme.dart';

class GCsPage extends StatefulWidget {
  const GCsPage({super.key});

  @override
  _GCsPageState createState() => _GCsPageState();
}

class _GCsPageState extends State<GCsPage> {
  final _firestore = FirebaseFirestore.instance;
  bool _showForm = false;
  bool _isEditing =
      false; // Variável para controlar se estamos editando ou criando um novo GC
  late String _selectedGCId; // ID do GC selecionado

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GCs', style: TextStyle(fontSize: 30)),
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
              'Cadastre os GCs de sua igreja e tenha um controle mais eficiente das atividades.',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: _showForm
                ? _isEditing
                    ? GCEditarWidget(gcId: _selectedGCId)
                    : const GCFormWidget() // Exibe o formulário de cadastro se _showForm for verdadeiro
                : StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('gcs')
                        .snapshots(), // Obtém os dados dos GCs
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return GCsListWidget(
                          snapshot: snapshot.data!,
                          onGCSelected: (gcId) {
                            setState(() {
                              _showForm = true;
                              _isEditing =
                                  true; // Indica que estamos editando, não criando um novo GC
                              _selectedGCId = gcId; // Define o ID do GC
                            });
                          },
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child:
                              Text('Erro ao carregar GCs: ${snapshot.error}'),
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
                      false; // Indica que estamos criando um novo GC, não editando
                });
              },
              tooltip: 'Cadastrar Novo GC',
              backgroundColor: AppTheme.colors.primary,
              child: Icon(Icons.add, color: AppTheme.colors.white),
            )
          : null, // Oculta o botão flutuante quando o formulário está sendo exibido
    );
  }
}
