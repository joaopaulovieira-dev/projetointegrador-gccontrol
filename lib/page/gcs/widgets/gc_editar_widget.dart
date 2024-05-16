// ignore_for_file: no_logic_in_create_state, library_private_types_in_public_api, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gccontrol/theme/app_theme.dart';

class GCEditarWidget extends StatefulWidget {
  final String gcId;

  const GCEditarWidget({super.key, required this.gcId});

  @override
  _GCEditarWidgetState createState() => _GCEditarWidgetState(gcId: gcId);
}

class _GCEditarWidgetState extends State<GCEditarWidget> {
  final String gcId;

  _GCEditarWidgetState({required this.gcId});

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _cepController = TextEditingController();
  final TextEditingController _cidadeController = TextEditingController();
  final TextEditingController _bairroController = TextEditingController();
  final TextEditingController _enderecoController = TextEditingController();
  final TextEditingController _numeroController = TextEditingController();
  final TextEditingController _complementoController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _supervisorController = TextEditingController();
  final TextEditingController _liderController = TextEditingController();
  final TextEditingController _viceLiderController = TextEditingController();
  final TextEditingController _secretarioController = TextEditingController();
  final TextEditingController _horarioController = TextEditingController();

  int _currentStep = 0;
  String? selectedPublicoAlvo;
  String? selectedDiaSemana;
  String? selectedEstado;
  String? selectedIgreja;

  @override
  void initState() {
    super.initState();
    _preencherDados();
  }

  void _preencherDados() async {
    try {
      DocumentSnapshot snapshot =
          await _firestore.collection('gcs').doc(gcId).get();
      if (snapshot.exists) {
        setState(() {
          _nomeController.text = snapshot['nome'] ?? '';
          _cepController.text = snapshot['cep'] ?? '';
          _cidadeController.text = snapshot['cidade'] ?? '';
          _bairroController.text = snapshot['bairro'] ?? '';
          _enderecoController.text = snapshot['endereco'] ?? '';
          _numeroController.text = snapshot['numero'] ?? '';
          _complementoController.text = snapshot['complemento'] ?? '';
          _horarioController.text = snapshot['horario'] ?? '';
          _emailController.text = snapshot['email'] ?? '';
          _telefoneController.text = snapshot['telefone'] ?? '';
          _supervisorController.text = snapshot['supervisor'] ?? '';
          _liderController.text = snapshot['lider'] ?? '';
          _viceLiderController.text = snapshot['viceLider'] ?? '';
          _secretarioController.text = snapshot['secretario'] ?? '';
          selectedPublicoAlvo = snapshot['publicoAlvo'];
          selectedDiaSemana = snapshot['diaSemana'];
          selectedEstado = snapshot['estado'];
          selectedIgreja = snapshot['igrejaId'];
        });
      }
    } catch (e) {
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
              currentStep: _currentStep,
              onStepContinue: () {
                setState(() {
                  if (_currentStep < 3) {
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
                            selectedPublicoAlvo = value;
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
                            selectedDiaSemana = value;
                          });
                        },
                        requiredField: true,
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        controller: _horarioController,
                        labelText: 'Horário*',
                        keyboardType: TextInputType.datetime,
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
                                  selectedEstado = value;
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
                        children: <Widget>[
                          Expanded(
                            child: _buildTextField(
                              controller: _numeroController,
                              labelText: 'Número*',
                              keyboardType: TextInputType.number,
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
      validator: (value) {
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
      validator: (value) {
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

          selectedIgreja = igrejaId;
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
                selectedIgreja = igrejaNome;
                return DropdownButtonFormField<String>(
                  items: [
                    DropdownMenuItem<String>(
                      value: igrejaId,
                      child: Text(selectedIgreja ?? 'Carregando...'),
                    ),
                  ],
                  onChanged: (value) {
                    selectedIgreja = value!;
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

  void _salvarDados() async {
    try {
      Map<String, dynamic> data = {
        'nome': _nomeController.text,
        'cep': _cepController.text,
        'cidade': _cidadeController.text,
        'bairro': _bairroController.text,
        'endereco': _enderecoController.text,
        'numero': _numeroController.text,
        'complemento': _complementoController.text,
        'horario': _horarioController.text,
        'email': _emailController.text,
        'telefone': _telefoneController.text,
        'supervisor': _supervisorController.text,
        'lider': _liderController.text,
        'viceLider': _viceLiderController.text,
        'secretario': _secretarioController.text,
        'publicoAlvo': selectedPublicoAlvo,
        'diaSemana': selectedDiaSemana,
        'estado': selectedEstado,
        'igrejaId': selectedIgreja,
        'dataAtualizacao': DateTime.now(),
      };

      await _firestore.collection('gcs').doc(gcId).update(data);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: const Text('Dados atualizados com sucesso',
                style: TextStyle(color: Colors.black)),
            backgroundColor: AppTheme.colors.primary),
      );
    } catch (e) {
      debugPrint('Erro ao salvar os dados: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: const Text('Erro ao salvar os dados.',
                style: TextStyle(color: Colors.black)),
            backgroundColor: AppTheme.colors.primary),
      );
    }
  }
}
