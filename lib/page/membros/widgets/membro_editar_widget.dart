// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api, no_logic_in_create_state

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gccontrol/theme/app_theme.dart';

class MembroEditarWidget extends StatefulWidget {
  final String membroId;

  const MembroEditarWidget({super.key, required this.membroId});

  @override
  _MembroEditarWidgetState createState() =>
      _MembroEditarWidgetState(membroId: membroId);
}

class _MembroEditarWidgetState extends State<MembroEditarWidget> {
  final String membroId;

  _MembroEditarWidgetState({required this.membroId});

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _dataNascimentoController =
      TextEditingController();
  final TextEditingController _cepController = TextEditingController();
  final TextEditingController _cidadeController = TextEditingController();
  final TextEditingController _estadoController = TextEditingController();
  final TextEditingController _bairroController = TextEditingController();
  final TextEditingController _enderecoController = TextEditingController();
  final TextEditingController _numeroController = TextEditingController();
  final TextEditingController _complementoController = TextEditingController();
  String? selectedGC;
  int _currentStep = 0; // Adicionando a variável _currentStep

  @override
  void initState() {
    super.initState();
    _preencherDados();
  }

  void _preencherDados() async {
    try {
      // Busca os dados do membro no Firestore
      DocumentSnapshot snapshot =
          await _firestore.collection('membros').doc(membroId).get();
      if (snapshot.exists) {
        // Preenche os controladores com os dados do membro
        setState(() {
          _nomeController.text = snapshot['nome'] ?? '';
          _telefoneController.text = snapshot['telefone'] ?? '';
          _dataNascimentoController.text = snapshot['dataNascimento'] ?? '';
          _cepController.text = snapshot['cep'] ?? '';
          _cidadeController.text = snapshot['cidade'] ?? '';
          _estadoController.text = snapshot['estado'] ?? '';
          _bairroController.text = snapshot['bairro'] ?? '';
          _enderecoController.text = snapshot['endereco'] ?? '';
          _numeroController.text = snapshot['numero'] ?? '';
          _complementoController.text = snapshot['complemento'] ?? '';
          selectedGC =
              snapshot['gcId']; // Preenche o campo de Grupo de Crescimento
        });
      }
    } catch (e) {
      // Em caso de erro ao buscar os dados
      debugPrint('Erro ao buscar os dados: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colors.white,
      body: Stack(
        children: [
          Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.disabled,
            child: Stepper(
              controlsBuilder: (BuildContext context, ControlsDetails details) {
                return Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Campos obrigatórios são marcados com *',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.start,
                      ),
                      Row(
                        children: <Widget>[
                          TextButton(
                            onPressed: details.onStepCancel,
                            child: const Text(
                              'Retornar',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                          TextButton(
                            onPressed: details.onStepContinue,
                            child: Text(
                              'Avançar',
                              style: TextStyle(color: AppTheme.colors.primary),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
              type: StepperType.horizontal,
              currentStep: _currentStep, // Usando a variável _currentStep
              onStepContinue: () {
                setState(() {
                  if (_formKey.currentState!.validate()) {
                    if (_currentStep < 1) {
                      _currentStep += 1;
                    }
                  }
                });
              },
              onStepCancel: () {
                setState(() {
                  if (_currentStep > 0) {
                    _currentStep -= 1;
                  }
                });
              },
              steps: [
                Step(
                  state: StepState.complete,
                  isActive: true,
                  title: const Text('Informações'),
                  content: Column(
                    children: [
                      _buildTextField(
                        controller: _nomeController,
                        labelText: 'Nome*',
                        requiredField: true,
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        controller: _telefoneController,
                        labelText: 'Telefone*',
                        keyboardType: TextInputType.phone,
                        requiredField: true,
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        controller: _dataNascimentoController,
                        labelText: 'Data de Nascimento*',
                        keyboardType: TextInputType.datetime,
                        requiredField: true,
                      ),
                      const SizedBox(height: 10),
                      FutureBuilder<List<Map<String, dynamic>>>(
                        future: _carregarGCs(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }
                          if (snapshot.hasError) {
                            return Text(
                                'Erro ao carregar os dados: ${snapshot.error}');
                          }
                          final gcList = snapshot.data!;
                          return DropdownButtonFormField<String>(
                            items: gcList.map((gc) {
                              return DropdownMenuItem<String>(
                                value: gc['id'],
                                child: Text(gc['nome']),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedGC = value;
                              });
                            },
                            decoration: InputDecoration(
                              labelText: 'Grupo de Crescimento*',
                              filled: true,
                              fillColor: Colors.blueGrey[50],
                              labelStyle: const TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.w600,
                              ),
                              contentPadding: const EdgeInsets.only(left: 30),
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.blueGrey[50]!),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.blueGrey[50]!),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            value: selectedGC,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Selecione um Grupo de Crescimento.';
                              }
                              return null;
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Step(
                  state: StepState.complete,
                  isActive: true,
                  title: const Text('Endereço'),
                  content: Column(
                    children: [
                      _buildTextField(
                        controller: _cepController,
                        labelText: 'CEP',
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: _buildTextField(
                              controller: _cidadeController,
                              labelText: 'Cidade*',
                              requiredField: true,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildTextField(
                              controller: _estadoController,
                              labelText: 'Estado*',
                              requiredField: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        controller: _bairroController,
                        labelText: 'Bairro*',
                        requiredField: true,
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        controller: _enderecoController,
                        labelText: 'Endereço*',
                        requiredField: true,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: _buildTextField(
                              controller: _numeroController,
                              labelText: 'Número',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildTextField(
                              controller: _complementoController,
                              labelText: 'Complemento',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.colors.primary,
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            _salvarDados(); // Chama o método para salvar os dados
          }
        },
        tooltip: 'Salvar',
        child: Icon(Icons.save, color: AppTheme.colors.white),
      ),
    );
  }

  // Método para salvar os dados no Firestore
  Future<void> _salvarDados() async {
    try {
      // Verifica se há um usuário logado
      User? user = _auth.currentUser;
      if (user != null) {
        // Cria um mapa com os dados do formulário
        Map<String, dynamic> data = {
          'nome': _nomeController.text,
          'telefone': _telefoneController.text,
          'dataNascimento': _dataNascimentoController.text,
          'cep': _cepController.text,
          'cidade': _cidadeController.text,
          'estado': _estadoController.text,
          'bairro': _bairroController.text,
          'endereco': _enderecoController.text,
          'numero': _numeroController.text,
          'complemento': _complementoController.text,
          'gcId': selectedGC,
        };

        // Salva os dados no Firestore
        await _firestore.collection('membros').doc(membroId).update(data);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: const Text('Edição do membro concluído com sucesso',
                  style: TextStyle(color: Colors.black)),
              backgroundColor: AppTheme.colors.primary),
        );
      } else {
        // Caso não haja usuário logado
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: const Text('Usuário não autenticado.',
                  style: TextStyle(color: Colors.black)),
              backgroundColor: AppTheme.colors.primary),
        );
      }
    } catch (e) {
      // Em caso de erro ao salvar os dados
      debugPrint('Erro ao salvar os dados: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: const Text('Erro ao salvar os dados.',
                style: TextStyle(color: Colors.black)),
            backgroundColor: AppTheme.colors.primary),
      );
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool requiredField = false,
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
      keyboardType: keyboardType,
      inputFormatters: [
        if (keyboardType == TextInputType.number)
          FilteringTextInputFormatter.digitsOnly,
      ],
      validator: validator ??
          (value) {
            if (requiredField && (value == null || value.isEmpty)) {
              return 'Campo $labelText obrigatório.';
            }
            return null;
          },
    );
  }

  Future<List<Map<String, dynamic>>> _carregarGCs() async {
    final QuerySnapshot querySnapshot =
        await _firestore.collection('gcs').get();
    return querySnapshot.docs
        .map((doc) => {
              'id': doc.id,
              'nome': doc['nome'],
            })
        .toList();
  }
}
