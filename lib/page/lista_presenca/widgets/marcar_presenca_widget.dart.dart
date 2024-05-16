// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gccontrol/theme/app_theme.dart';

class MarcarPresencaWidget extends StatefulWidget {
  final String gcId;

  const MarcarPresencaWidget({super.key, required this.gcId});

  @override
  _MarcarPresencaWidgetState createState() => _MarcarPresencaWidgetState();
}

class _MarcarPresencaWidgetState extends State<MarcarPresencaWidget> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Map<String, bool> selectedButtons = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colors.white,
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('membros')
            .where('gcId', isEqualTo: widget.gcId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Erro: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Nenhum membro encontrado.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var member = snapshot.data!.docs[index];
                return Card(
                  elevation: 3,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  color: AppTheme.colors.menulateralColor,
                  shadowColor: Colors.transparent,
                  surfaceTintColor: AppTheme.colors.menulateralColor,
                  child: ListTile(
                    title: Text(member['nome']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildButton(member.id, 'Presença'),
                        const SizedBox(width: 8),
                        _buildButton(member.id, 'Falta'),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildButton(String memberId, String text) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          selectedButtons[memberId] = text == 'Presença';
        });
        text == 'Presença'
            ? _marcarPresenca(context, memberId)
            : _marcarFalta(context, memberId);
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            if (selectedButtons.containsKey(memberId) &&
                selectedButtons[memberId] == (text == 'Presença')) {
              return text == 'Presença'
                  ? Colors.green.withOpacity(0.8)
                  : Colors.red.withOpacity(0.8);
            }
            return text == 'Presença' ? Colors.green : Colors.red;
          },
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: selectedButtons.containsKey(memberId) &&
                  selectedButtons[memberId] == (text == 'Presença')
              ? Colors.white.withOpacity(0.8)
              : Colors.white,
        ),
      ),
    );
  }

  void _marcarPresenca(BuildContext context, String memberId) async {
    try {
      String userId = _auth.currentUser!.uid;
      DateTime now = DateTime.now();

      await _firestore.collection('lista_presenca').add({
        'membroId': memberId,
        'data': now.toIso8601String(),
        'hora': '${now.hour}:${now.minute}',
        'userId': userId,
        'presenca': true, // Adiciona um campo para indicar presença
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: const Text('Presença marcada com sucesso.',
                style: TextStyle(color: Colors.black)),
            backgroundColor: AppTheme.colors.primary),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: const Text('Erro ao marcar presença.',
                style: TextStyle(color: Colors.black)),
            backgroundColor: AppTheme.colors.primary),
      );
    }
  }

  void _marcarFalta(BuildContext context, String memberId) async {
    try {
      String userId = _auth.currentUser!.uid;
      DateTime now = DateTime.now();

      await _firestore.collection('lista_presenca').add({
        'membroId': memberId,
        'data': now.toIso8601String(),
        'hora': '${now.hour}:${now.minute}',
        'userId': userId,
        'presenca': false, // Adiciona um campo para indicar falta
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: const Text('Falta marcada com sucesso.',
                style: TextStyle(color: Colors.black)),
            backgroundColor: AppTheme.colors.primary),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: const Text('Erro ao marcar falta.',
                style: TextStyle(color: Colors.black)),
            backgroundColor: AppTheme.colors.primary),
      );
    }
  }
}
