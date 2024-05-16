// ignore_for_file: library_private_types_in_public_api, no_logic_in_create_state, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:gccontrol/theme/app_theme.dart';

class IgrejaEditarWidget extends StatefulWidget {
  final String igrejaId;

  const IgrejaEditarWidget({super.key, required this.igrejaId});

  @override
  _IgrejaEditarWidgetState createState() =>
      _IgrejaEditarWidgetState(igrejaId: igrejaId);
}

class _IgrejaEditarWidgetState extends State<IgrejaEditarWidget> {
  final String igrejaId;

  _IgrejaEditarWidgetState({required this.igrejaId});

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _cnpjController = TextEditingController();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _cepController = TextEditingController();
  final TextEditingController _cidadeController = TextEditingController();
  final TextEditingController _bairroController = TextEditingController();
  final TextEditingController _enderecoController = TextEditingController();
  final TextEditingController _numeroController = TextEditingController();
  final TextEditingController _complementoController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _siteController = TextEditingController();

  int _currentStep = 0;
  String? selectedTipoIgreja;
  String? selectedQuantidadeMembros;
  String? selectedEstado;

  @override
  void initState() {
    super.initState();
    _preencherDados();
  }

  void _preencherDados() async {
    try {
      // Busca os dados da igreja no Firestore
      DocumentSnapshot snapshot =
          await _firestore.collection('igrejas').doc(igrejaId).get();
      if (snapshot.exists) {
        // Preenche os controladores com os dados da igreja
        setState(() {
          _cnpjController.text = snapshot['cnpj'] ?? '';
          _nomeController.text = snapshot['nome'] ?? '';
          _cepController.text = snapshot['cep'] ?? '';
          _cidadeController.text = snapshot['cidade'] ?? '';
          _bairroController.text = snapshot['bairro'] ?? '';
          _enderecoController.text = snapshot['endereco'] ?? '';
          _numeroController.text = snapshot['numero'] ?? '';
          _complementoController.text = snapshot['complemento'] ?? '';
          _emailController.text = snapshot['email'] ?? '';
          _telefoneController.text = snapshot['telefone'] ?? '';
          _siteController.text = snapshot['site'] ?? '';
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
                        controller: _cnpjController,
                        labelText: 'CNPJ',
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        controller: _nomeController,
                        labelText: 'Nome*',
                        requiredField: true,
                      ),
                      const SizedBox(height: 10),
                      _buildDropDownField(
                        items: ['Matriz', 'Filial'],
                        labelText: 'Tipo de Igreja*',
                        onChanged: (value) {
                          setState(() {
                            selectedTipoIgreja = value;
                          });
                        },
                        requiredField: true,
                      ),
                      const SizedBox(height: 10),
                      _buildDropDownField(
                        items: [
                          '01-50',
                          '50-100',
                          '100-200',
                          '200-500',
                          '500-1000',
                          '1000-5000',
                          '5000-10000',
                          '+10000'
                        ],
                        labelText: 'Quantidade de Membros',
                        onChanged: (value) {
                          setState(() {
                            selectedQuantidadeMembros = value;
                          });
                        },
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
                Step(
                  state:
                      _currentStep > 2 ? StepState.complete : StepState.indexed,
                  isActive: _currentStep >= 2,
                  title: const Text('Contato'),
                  content: Column(
                    children: [
                      _buildTextField(
                        controller: _telefoneController,
                        labelText: 'Telefone*',
                        requiredField: true,
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        controller: _emailController,
                        labelText: 'E-mail',
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        controller: _siteController,
                        labelText: 'Site',
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
          'cnpj': _cnpjController.text,
          'nome': _nomeController.text,
          'tipoIgreja': selectedTipoIgreja,
          'quantidadeMembros': selectedQuantidadeMembros,
          'cep': _cepController.text,
          'cidade': _cidadeController.text,
          'estado': selectedEstado,
          'bairro': _bairroController.text,
          'endereco': _enderecoController.text,
          'numero': _numeroController.text,
          'complemento': _complementoController.text,
          'telefone': _telefoneController.text,
          'email': _emailController.text,
          'site': _siteController.text,
          'idUsuarioAdministrador': user.uid, // ID do usuário logado
          'dataRegistro': DateTime.now(), // Data e hora do registro
        };

        // Salva os dados no Firestore
        await _firestore.collection('igrejas').doc(igrejaId).update(data);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: const Text('Edição da igreja concluída com sucesso',
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

  //Layout dos campos de texto
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
          FilteringTextInputFormatter
              .digitsOnly, // Somente números se for numérico
      ],
      validator: validator ?? // Use o validator fornecido ou um padrão
          (value) {
            if (requiredField && (value == null || value.isEmpty)) {
              return 'Campo $labelText obrigatório.'; // Mensagem de erro
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
      validator: validator ?? // Use o validator fornecido ou um padrão
          (value) {
            if (requiredField && (value == null || value.isEmpty)) {
              return 'Campo $labelText obrigatório.'; // Mensagem de erro
            }

            return null;
          },
    );
  }
}
