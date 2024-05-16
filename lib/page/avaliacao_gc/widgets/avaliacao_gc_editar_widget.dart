// ignore_for_file: library_private_types_in_public_api, no_logic_in_create_state, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gccontrol/theme/app_theme.dart';

class AvaliacaoGcEditarWidget extends StatefulWidget {
  final String avaliacaoId;

  const AvaliacaoGcEditarWidget({super.key, required this.avaliacaoId});

  @override
  _AvaliacaoGcEditarWidgetState createState() =>
      _AvaliacaoGcEditarWidgetState(avaliacaoId: avaliacaoId);
}

class _AvaliacaoGcEditarWidgetState extends State<AvaliacaoGcEditarWidget> {
  final String avaliacaoId;

  _AvaliacaoGcEditarWidgetState({required this.avaliacaoId});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _pontosPositivosController =
      TextEditingController();
  final TextEditingController _pontosMelhoriaController =
      TextEditingController();
  final TextEditingController _sugestoesController = TextEditingController();
  final TextEditingController _impactoPessoalController =
      TextEditingController();
  final TextEditingController _observacaoController = TextEditingController();

  String? _selectedGC;
  String? _selectedAvaliacaoGc;

  final List<Map<String, dynamic>> _gcData = []; // Armazena nome e ID do GC

  @override
  void initState() {
    super.initState();
    _preencherDados();
    _loadGcs();
  }

  void _preencherDados() async {
    try {
      // Busca os dados da avaliação no Firestore
      DocumentSnapshot snapshot =
          await _firestore.collection('avaliacoes_gc').doc(avaliacaoId).get();
      if (snapshot.exists) {
        // Preenche os controladores com os dados da avaliação
        setState(() {
          _pontosPositivosController.text = snapshot['pontosPositivos'] ?? '';
          _pontosMelhoriaController.text = snapshot['pontosMelhoria'] ?? '';
          _sugestoesController.text = snapshot['sugestoes'] ?? '';
          _impactoPessoalController.text = snapshot['impactoPessoal'] ?? '';
          _observacaoController.text = snapshot['observacao'] ?? '';
          _selectedGC = snapshot['gcId'];
          _selectedAvaliacaoGc = snapshot['avaliacaoGc'];
        });
      }
    } catch (e) {
      // Em caso de erro ao buscar os dados
      debugPrint('Erro ao buscar os dados: $e');
    }
  }

  Future<void> _loadGcs() async {
    QuerySnapshot gcSnapshot = await _firestore.collection('gcs').get();
    for (var doc in gcSnapshot.docs) {
      _gcData.add({
        'id': doc.id,
        'nome': doc['nome'],
      });
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedGC,
                  items: _gcData.map((gc) {
                    return DropdownMenuItem<String>(
                      value: gc['id'],
                      child: Text(gc['nome']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedGC = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'GC*',
                    filled: true,
                    fillColor: Colors.blueGrey[50],
                    labelStyle: const TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w600,
                    ),
                    contentPadding: const EdgeInsets.only(left: 30),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blueGrey[50]!),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blueGrey[50]!),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Selecione um Grupo de Crescimento.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  controller: _pontosPositivosController,
                  labelText: 'Pontos Positivos',
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  controller: _pontosMelhoriaController,
                  labelText: 'Pontos de Melhoria',
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  controller: _sugestoesController,
                  labelText: 'Sugestões para Próximas Reuniões',
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  controller: _impactoPessoalController,
                  labelText: 'Impacto Pessoal',
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  controller: _observacaoController,
                  labelText: 'Observação',
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.colors.primary,
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            _salvarDados();
          }
        },
        tooltip: 'Salvar',
        child: Icon(Icons.save, color: AppTheme.colors.white),
      ),
    );
  }

  Future<void> _salvarDados() async {
    try {
      Map<String, dynamic> data = {
        'pontosPositivos': _pontosPositivosController.text,
        'pontosMelhoria': _pontosMelhoriaController.text,
        'sugestoes': _sugestoesController.text,
        'impactoPessoal': _impactoPessoalController.text,
        'observacao': _observacaoController.text,
        'gcId': _selectedGC,
        'avaliacaoGc': _selectedAvaliacaoGc,
      };

      await _firestore
          .collection('avaliacoes_gc')
          .doc(avaliacaoId)
          .update(data);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Edição da avaliação concluída com sucesso',
              style: TextStyle(color: Colors.black)),
          backgroundColor: AppTheme.colors.primary,
        ),
      );
    } catch (e) {
      debugPrint('Erro ao salvar os dados: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Erro ao salvar os dados.',
              style: TextStyle(color: Colors.black)),
          backgroundColor: AppTheme.colors.primary,
        ),
      );
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        filled: true,
        fillColor: Colors.blueGrey[50],
        labelStyle: const TextStyle(
          color: Colors.black54,
          fontWeight: FontWeight.w600,
        ),
        contentPadding: const EdgeInsets.only(left: 30),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blueGrey[50]!),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blueGrey[50]!),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
