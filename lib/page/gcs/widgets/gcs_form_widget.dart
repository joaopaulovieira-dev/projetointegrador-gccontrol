// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:gccontrol/theme/app_theme.dart';

class GCFormWidget extends StatefulWidget {
  const GCFormWidget({super.key});

  @override
  _GCFormWidgetState createState() => _GCFormWidgetState();
}

class _GCFormWidgetState extends State<GCFormWidget> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _cepController = TextEditingController();
  final TextEditingController _cidadeController = TextEditingController();
  final TextEditingController _estadoController = TextEditingController();
  final TextEditingController _bairroController = TextEditingController();
  final TextEditingController _enderecoController = TextEditingController();
  final TextEditingController _numeroController = TextEditingController();
  final TextEditingController _complementoController = TextEditingController();
  final TextEditingController _horarioController = TextEditingController();
  final TextEditingController _supervisorController = TextEditingController();
  final TextEditingController _liderController = TextEditingController();
  final TextEditingController _viceLiderController = TextEditingController();
  final TextEditingController _secretarioController = TextEditingController();

  String? _selectedPublicoAlvo;
  String? _selectedDiaSemana;
  String? _selectedIgrejaId;
  String? _selectedIgrejaNome;
// Added variable to control loaded churches

  Future<void> _salvarDados() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        Map<String, dynamic> data = {
          'nome': _nomeController.text,
          'cep': _cepController.text,
          'cidade': _cidadeController.text,
          'estado': _estadoController.text,
          'bairro': _bairroController.text,
          'endereco': _enderecoController.text,
          'numero': _numeroController.text,
          'complemento': _complementoController.text,
          'horario': _horarioController.text,
          'supervisor': _supervisorController.text,
          'lider': _liderController.text,
          'viceLider': _viceLiderController.text,
          'secretario': _secretarioController.text,
          'igrejaId': _selectedIgrejaId, // Salvar o ID da igreja
          'igrejaNome':
              _selectedIgrejaNome, // Manter o nome da igreja para exibição
          'publicoAlvo': _selectedPublicoAlvo,
          'diaSemana': _selectedDiaSemana,
          'dataRegistro': DateTime.now(),
          'idUsuario': user.uid,
        };

        await _firestore.collection('gcs').add(data);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cadastro do GC concluído com sucesso'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Usuário não autenticado.'),
          ),
        );
      }
    } catch (e) {
      debugPrint('Erro ao salvar os dados: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao salvar os dados.'),
        ),
      );
    }
  }

  int _currentStep = 0;

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
              currentStep: _currentStep,
              onStepContinue: () {
                setState(() {
                  if (_currentStep < 2) {
                    _currentStep += 1;
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
                  state:
                      _currentStep > 0 ? StepState.complete : StepState.indexed,
                  isActive: _currentStep >= 0,
                  title: const Text('Informações'),
                  content: Column(
                    children: [
                      _buildTextField(
                        controller: _nomeController,
                        labelText: 'Nome*',
                        requiredField: true,
                      ),
                      const SizedBox(height: 10),
                      _buildDropDownField(
                        items: [
                          'Crianças',
                          'Adolescentes',
                          'Jovens',
                          'Adultos',
                          'Idosos',
                          'Homens',
                          'Mulheres',
                          'Casais',
                          'Famílias',
                          'Mistas',
                        ],
                        labelText: 'Público Alvo*',
                        onChanged: (value) {
                          setState(() {
                            _selectedPublicoAlvo = value;
                          });
                        },
                        requiredField: true,
                      ),
                      const SizedBox(height: 10),
                      _buildDropDownField(
                        items: [
                          'Segunda',
                          'Terça',
                          'Quarta',
                          'Quinta',
                          'Sexta',
                          'Sábado',
                          'Domingo'
                        ],
                        labelText: 'Dia da Semana*',
                        onChanged: (value) {
                          setState(() {
                            _selectedDiaSemana = value;
                          });
                        },
                        requiredField: true,
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        controller: _horarioController,
                        labelText: 'Horário*',
                        keyboardType: TextInputType.datetime,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Campo Horário obrigatório.';
                          }
                          return null;
                        },
                        requiredField: true,
                      ),
                    ],
                  ),
                ),
                Step(
                  state:
                      _currentStep > 1 ? StepState.complete : StepState.indexed,
                  isActive: _currentStep >= 1,
                  title: const Text('Endereço'),
                  content: Column(
                    children: [
                      _buildTextField(
                        controller: _cepController,
                        labelText: 'CEP*',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Campo CEP obrigatório.';
                          }
                          return null;
                        },
                        requiredField: true,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _cidadeController,
                              labelText: 'Cidade*',
                              requiredField: true,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildDropDownField(
                              items: [
                                'SP',
                                'RJ',
                                'MG',
                                'ES',
                                'RS',
                                'SC',
                                'PR',
                                'MS',
                                'MT',
                                'GO',
                                'DF',
                                'TO',
                                'RO',
                                'AC',
                                'AM',
                                'RR',
                                'PA',
                                'AP',
                                'MA',
                                'PI',
                                'CE',
                                'RN',
                                'PB',
                                'PE',
                                'AL',
                                'SE',
                                'BA'
                              ],
                              labelText: 'Estado*',
                              onChanged: (value) {
                                setState(() {
                                  _estadoController.text = value!;
                                });
                              },
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
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _numeroController,
                              labelText: 'Número*',
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Campo Número obrigatório.';
                                }
                                return null;
                              },
                              requiredField: true,
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
                Step(
                  state:
                      _currentStep > 2 ? StepState.complete : StepState.indexed,
                  isActive: _currentStep >= 2,
                  title: const Text('Gerenciadores'),
                  content: Column(
                    children: [
                      _buildTextField(
                        controller: _supervisorController,
                        labelText: 'Supervisor*',
                        requiredField: true,
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        controller: _liderController,
                        labelText: 'Líder*',
                        requiredField: true,
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        controller: _viceLiderController,
                        labelText: 'Vice-líder*',
                        requiredField: true,
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        controller: _secretarioController,
                        labelText: 'Secretário*',
                        requiredField: true,
                      ),
                      const SizedBox(height: 10),
                      _buildDropDownFieldFromFirestore(
                        labelText: 'Igreja*',
                        requiredField: true,
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
            _salvarDados();
            _nomeController.clear();
            _cepController.clear();
            _cidadeController.clear();
            _estadoController.clear();
            _bairroController.clear();
            _enderecoController.clear();
            _numeroController.clear();
            _complementoController.clear();
            _horarioController.clear();
            _supervisorController.clear();
            _liderController.clear();
            _viceLiderController.clear();
            _secretarioController.clear();
            _selectedPublicoAlvo = null;
            _selectedDiaSemana = null;
            _selectedIgrejaId = null;
            _selectedIgrejaNome = null;
// Reset loaded churches state
          }
        },
        tooltip: 'Salvar',
        child: Icon(Icons.save, color: AppTheme.colors.white),
      ),
    );
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

  Widget _buildDropDownField({
    required List<String> items,
    required String labelText,
    required void Function(String?) onChanged,
    String? Function(String?)? validator,
    bool requiredField = false,
  }) {
    return DropdownButtonFormField<String>(
      items: items.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
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
      validator: validator ??
          (value) {
            if (requiredField && (value == null || value.isEmpty)) {
              return 'Campo $labelText obrigatório.';
            }
            return null;
          },
    );
  }

  Widget _buildDropDownFieldFromFirestore({
    required String labelText,
    required bool requiredField,
  }) {
    return FutureBuilder<DocumentSnapshot>(
      future: _firestore
          .collection('igrejas_usuario')
          .doc(_auth.currentUser!.uid)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Erro: ${snapshot.error}');
        } else if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Text('Nenhum documento encontrado para o usuário.');
        } else {
          final igrejaId = snapshot.data!['igrejaId'];
          if (igrejaId == null) {
            return const Text('Nenhum id de igreja encontrado para o usuário.');
          }

          _selectedIgrejaId = igrejaId;
          final igrejaFuture =
              _firestore.collection('igrejas').doc(igrejaId).get();
          return FutureBuilder<DocumentSnapshot>(
            future: igrejaFuture,
            builder: (context, igrejaSnapshot) {
              if (!igrejaSnapshot.hasData || !igrejaSnapshot.data!.exists) {
                return const Text('Nenhuma igreja encontrada.');
              } else {
                final igrejaData =
                    igrejaSnapshot.data!.data() as Map<String, dynamic>;
                final igrejaNome = igrejaData['nome'];
                _selectedIgrejaNome = igrejaNome;
                return DropdownButtonFormField<String>(
                  items: [
                    DropdownMenuItem<String>(
                      value: igrejaId,
                      child: Text(_selectedIgrejaNome ?? 'Carregando...'),
                    ),
                  ],
                  onChanged: (value) {
                    _selectedIgrejaId = value!;
                  },
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
                  validator: (value) {
                    if (requiredField && (value == null || value.isEmpty)) {
                      return 'Campo $labelText obrigatório.';
                    }
                    return null;
                  },
                );
              }
            },
          );
        }
      },
    );
  }
}
