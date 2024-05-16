// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gccontrol/theme/app_theme.dart';

class AvaliacaoGcFormWidget extends StatefulWidget {
  const AvaliacaoGcFormWidget({super.key});

  @override
  _AvaliacaoGcFormWidgetState createState() => _AvaliacaoGcFormWidgetState();
}

class _AvaliacaoGcFormWidgetState extends State<AvaliacaoGcFormWidget> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
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
  String? _avaliacaoGc;

  final List<Map<String, dynamic>> _gcData = []; // Armazena nome e ID do GC

  String? _avaliacaoAvaliacaoGc;

  late ValueNotifier<String?> _selectedGCNotifier;

  @override
  void initState() {
    super.initState();
    _selectedGCNotifier = ValueNotifier<String?>(null);
    // Carrega os nomes e IDs dos GCs do Firestore
    _loadGcs();
  }

  @override
  void dispose() {
    _selectedGCNotifier.dispose();
    super.dispose();
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
                  value: _selectedGCNotifier.value,
                  items: _gcData.map((gc) {
                    return DropdownMenuItem<String>(
                      value: gc['id'],
                      child: Text(gc['nome']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    _selectedGCNotifier.value = value;
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
                _buildDropDownField(
                  labelText: 'Avaliação do GC',
                  items: ['Ruim', 'Bom', 'Excelente'],
                  onChanged: (value) {
                    setState(() {
                      _avaliacaoAvaliacaoGc = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, selecione uma avaliação';
                    }
                    return null;
                  },
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
            _submitForm();
            _pontosPositivosController.clear();
            _pontosMelhoriaController.clear();
            _sugestoesController.clear();
            _impactoPessoalController.clear();
            _observacaoController.clear();
            setState(() {
              _avaliacaoGc = null;
            });
          }
        },
        tooltip: 'Registrar Avaliação',
        child: Icon(Icons.save, color: AppTheme.colors.white),
      ),
    );
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

  Widget _buildDropDownField({
    required String labelText,
    required List<String> items,
    required void Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      value: _avaliacaoGc,
      items: items.map((String value) {
        return DropdownMenuItem<String>(
          value: value.toLowerCase(),
          child: Text(value),
        );
      }).toList(),
      onChanged: onChanged,
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
      validator: validator,
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Get current user
      User? user = _auth.currentUser;

      if (user != null) {
        // Prepare data
        Map<String, dynamic> data = {
          'pontosPositivos': _pontosPositivosController.text,
          'pontosMelhoria': _pontosMelhoriaController.text,
          'sugestoes': _sugestoesController.text,
          'impactoPessoal': _impactoPessoalController.text,
          'observacao': _observacaoController.text,
          'avaliacaoGc': _avaliacaoAvaliacaoGc,
          'userId': user.uid,
          'timestamp': DateTime.now(),
          'gcId': _selectedGCNotifier.value, // ID do GC selecionado
        };

        try {
          // Save data to Firestore
          await _firestore.collection('avaliacoes_gc').add(data);

          // Clear form
          _formKey.currentState!.reset();

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Avaliação salva com sucesso',
                style: TextStyle(color: Colors.black),
              ),
              backgroundColor: AppTheme.colors.primary,
            ),
          );
        } catch (e) {
          if (kDebugMode) {
            print('Erro ao salvar a avaliação: $e');
          }

          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Erro ao salvar a avaliação',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: AppTheme.colors.primary,
            ),
          );
        }
      } else {
        // Show error message if user is not authenticated
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Usuário não autenticado',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: AppTheme.colors.primary,
          ),
        );
      }
    }
  }
}
