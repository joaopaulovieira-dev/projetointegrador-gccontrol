// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gccontrol/theme/app_theme.dart';

class InformacoesPessoaisFormWidget extends StatefulWidget {
  const InformacoesPessoaisFormWidget({super.key});

  @override
  _InformacoesPessoaisFormWidgetState createState() =>
      _InformacoesPessoaisFormWidgetState();
}

class _InformacoesPessoaisFormWidgetState
    extends State<InformacoesPessoaisFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _cepController = TextEditingController();
  final TextEditingController _cidadeController = TextEditingController();
  final TextEditingController _estadoController = TextEditingController();
  final TextEditingController _bairroController = TextEditingController();
  final TextEditingController _enderecoController = TextEditingController();
  final TextEditingController _numeroController = TextEditingController();
  final TextEditingController _complementoController = TextEditingController();
  bool isLoading = false;

  String? _selectedSexo;
  String? _selectedDia;
  String? _selectedMes;
  String? _selectedAno;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(
              height: 30,
            ),
            const Text(
              'E-mail:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${FirebaseAuth.instance.currentUser!.email}',
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            const Text(
              'Dados Pessoais',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            _buildTextField(
              controller: _nomeController,
              labelText: 'Nome Completo',
            ),
            const SizedBox(height: 10),
            _buildTextField(
              controller: _cpfController,
              labelText: 'CPF*',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            _buildDropDownField(
              items: ['Masculino', 'Feminino'],
              labelText: 'Sexo*',
              onChanged: (value) {
                setState(() {
                  _selectedSexo = value;
                });
              },
            ),
            const SizedBox(height: 10),
            Row(
              children: <Widget>[
                Expanded(
                  child: _buildDropDownField(
                    items: _buildNumericItems(1, 31),
                    labelText: 'Dia',
                    onChanged: (value) {
                      setState(() {
                        _selectedDia = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildDropDownField(
                    items: _buildNumericItems(1, 13),
                    labelText: 'Mês',
                    onChanged: (value) {
                      setState(() {
                        _selectedMes = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildDropDownField(
                    items: _buildNumericItems(1950, 2023),
                    labelText: 'Ano',
                    onChanged: (value) {
                      setState(() {
                        _selectedAno = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 30,
            ),
            const Text(
              'Endereço',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 15,
            ),
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
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    controller: _estadoController,
                    labelText: 'Estado*',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildTextField(
              controller: _bairroController,
              labelText: 'Bairro*',
            ),
            const SizedBox(height: 10),
            _buildTextField(
              controller: _enderecoController,
              labelText: 'Endereço*',
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
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _salvarInformacoes();
                  Navigator.pushReplacementNamed(context, '/control');
                }
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: AppTheme.colors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: Center(
                  child: isLoading
                      ? const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : const Text('Cadastrar'),
                ),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }

  //Layout dos campos de texto
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
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
    );
  }

  Widget _buildDropDownField({
    required List<String> items,
    required String labelText,
    required void Function(String?) onChanged,
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
    );
  }

  List<String> _buildNumericItems(int start, int end) {
    List<String> items = [];
    for (int i = start; i <= end; i++) {
      items.add(i.toString());
    }
    return items;
  }

  void _salvarInformacoes() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        isLoading = true;
      });

      try {
        await FirebaseFirestore.instance
            .collection('informacoes_pessoais')
            .doc(user.uid)
            .set({
          'nome': _nomeController.text,
          'cpf': _cpfController.text,
          'sexo': _selectedSexo,
          'data_nascimento': {
            'dia': _selectedDia,
            'mes': _selectedMes,
            'ano': _selectedAno,
          },
          'endereco': {
            'cep': _cepController.text,
            'cidade': _cidadeController.text,
            'estado': _estadoController.text,
            'bairro': _bairroController.text,
            'endereco': _enderecoController.text,
            'numero': _numeroController.text,
            'complemento': _complementoController.text,
          },
          'email': user.email,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: const Text('Informações salvas com sucesso.',
                  style: TextStyle(color: Colors.black)),
              backgroundColor: AppTheme.colors.primary),
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erro ao salvar as informações: $error',
                  style: const TextStyle(color: Colors.black)),
              backgroundColor: AppTheme.colors.primary),
        );
      }

      setState(() {
        isLoading = false;
      });
    }
  }
}
