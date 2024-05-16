// ignore_for_file: library_private_types_in_public_api, file_names, avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:html' as html;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gccontrol/theme/app_theme.dart';

class LicoesPage extends StatefulWidget {
  const LicoesPage({super.key});

  @override
  _LicoesPageState createState() => _LicoesPageState();
}

class _LicoesPageState extends State<LicoesPage> {
  final _storage = FirebaseStorage.instance;
  final _firestore = FirebaseFirestore.instance;
  String? _errorMessage;
  int _selectedWeek = 1; // Definir valor inicial para a semana
  bool _loading = false;
  bool _isAdminOrSupervisor =
      false; // Variável para verificar se o usuário é administrador ou supervisor

  @override
  void initState() {
    super.initState();
    _updateSelectedWeekDates();
    _checkAdminOrSupervisor(); // Verificar se o usuário é administrador ou supervisor ao inicializar a página
  }

  void _updateSelectedWeekDates() {}

  Future<void> _checkAdminOrSupervisor() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userProfileSnapshot = await FirebaseFirestore.instance
            .collection('perfil_usuario')
            .doc(user.uid)
            .get();
        if (userProfileSnapshot.exists) {
          Map<String, dynamic> userProfileData =
              userProfileSnapshot.data() as Map<String, dynamic>;
          String profile = userProfileData['perfil'] ?? '';
          if (profile == 'Administrador' || profile == 'Supervisor') {
            setState(() {
              _isAdminOrSupervisor = true;
            });
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao verificar perfil do usuário: $e');
      }
    }
  }

  Future<void> _uploadConfirmationDialog(
      String fileName, List<int> bytes) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Upload'),
        content: _loading
            ? const CircularProgressIndicator()
            : Text(
                'Você deseja fazer o upload do arquivo para a semana $_selectedWeek?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _uploadFile(fileName, bytes);
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadFile(String fileName, List<int> bytes) async {
    try {
      setState(() {
        _loading = true;
      });

      final ref = _storage.ref().child('licoes/$fileName');
      final uploadTask = ref.putData(Uint8List.fromList(bytes));
      final snapshot = await uploadTask;
      final url = await snapshot.ref.getDownloadURL();

      // Salvar informações no Firestore
      await _firestore.collection('licoes').add({
        'url': url,
        'fileName': fileName,
        'week': _selectedWeek,
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() {
        _errorMessage = null;
        _loading = false;
      });
      _showSnackBar('Arquivo enviado com sucesso!');
    } on FirebaseException catch (e) {
      setState(() {
        _errorMessage = e.message;
        _loading = false;
      });
      _showSnackBar('Erro ao enviar arquivo: ${e.message}');
    }
  }

  Future<void> _deleteLicao(String fileName, String docId) async {
    try {
      // Deletar do Firestore
      await _firestore.collection('licoes').doc(docId).delete();

      // Deletar do Storage
      final ref = _storage.ref().child('licoes/$fileName');
      await ref.delete();

      _showSnackBar('Lição deletada com sucesso!');
    } on FirebaseException catch (e) {
      _showSnackBar('Erro ao deletar lição: ${e.message}');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  DateTime _getStartDateOfWeek(int week) {
    final now = DateTime.now();
    final firstDayOfYear = DateTime(now.year, 1, 1);
    final days = firstDayOfYear.weekday;
    return firstDayOfYear.add(Duration(days: (week - 1) * 7 - days + 1));
  }

  DateTime _getEndDateOfWeek(int week) {
    final startDate = _getStartDateOfWeek(week);
    return startDate.add(const Duration(days: 6));
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')} de ${_getMonthName(date.month)}';
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1:
        return 'Janeiro';
      case 2:
        return 'Fevereiro';
      case 3:
        return 'Março';
      case 4:
        return 'Abril';
      case 5:
        return 'Maio';
      case 6:
        return 'Junho';
      case 7:
        return 'Julho';
      case 8:
        return 'Agosto';
      case 9:
        return 'Setembro';
      case 10:
        return 'Outubro';
      case 11:
        return 'Novembro';
      case 12:
        return 'Dezembro';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lições', style: TextStyle(fontSize: 30)),
        elevation: 0,
        shadowColor: Colors.transparent,
        backgroundColor: AppTheme.colors.appBar,
        surfaceTintColor: AppTheme.colors.appBar,
      ),
      backgroundColor: AppTheme.colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Adicione as lições para cada semana ou faça o download das lições já cadastradas.',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
          if (_errorMessage != null)
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('licoes').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final documents = snapshot.data!.docs;
                  if (documents.isNotEmpty) {
                    return ListView.builder(
                      itemCount: documents.length,
                      itemBuilder: (context, index) {
                        final doc = documents[index];
                        final url = doc['url'];
                        final fileName = doc['fileName'];
                        final docId = doc.id;
                        final week = doc['week'];
                        final startDate = _getStartDateOfWeek(week);
                        final endDate = _getEndDateOfWeek(week);

                        return Card(
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          color: Colors.white,
                          child: ListTile(
                            title: Text(
                              fileName,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 5),
                                Text(
                                  'Semana: $week (${_formatDate(startDate)} a ${_formatDate(endDate)})',
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    html.AnchorElement(href: url)
                                      ..setAttribute('download', fileName)
                                      ..click();
                                  },
                                  icon: Icon(
                                    Icons.download,
                                    color: AppTheme.colors.primary,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Confirmar Exclusão'),
                                        content: const Text(
                                            'Tem certeza de que deseja excluir esta lição?'),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('Cancelar'),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              Navigator.of(context).pop();
                                              await _deleteLicao(
                                                  fileName, docId);
                                            },
                                            child: const Text('Confirmar'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    return const Center(
                        child: Text('Não existem arquivos importados.'));
                  }
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _isAdminOrSupervisor
          ? FloatingActionButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Selecionar Semana'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButton<int>(
                          value: _selectedWeek,
                          onChanged: (value) {
                            setState(() {
                              _selectedWeek = value!;
                              _updateSelectedWeekDates();
                            });
                          },
                          items: List.generate(52, (index) => index + 1)
                              .map((week) => DropdownMenuItem<int>(
                                    value: week,
                                    child: Text(
                                        'Semana $week (${_formatDate(_getStartDateOfWeek(week))} a ${_formatDate(_getEndDateOfWeek(week))})'),
                                  ))
                              .toList(),
                        ),
                      ],
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () {
                          html.InputElement input =
                              html.InputElement(type: 'file')..click();
                          input.onChange.listen((event) async {
                            final file = input.files!.first;
                            final reader = html.FileReader();
                            reader.readAsArrayBuffer(file);
                            reader.onLoadEnd.listen((event) async {
                              final bytes = reader.result as Uint8List;
                              Navigator.of(context).pop();
                              await _uploadConfirmationDialog(file.name, bytes);
                            });
                          });
                        },
                        child: const Text('Confirmar'),
                      ),
                    ],
                  ),
                );
              },
              tooltip: 'Fazer Upload',
              backgroundColor: AppTheme.colors.primary,
              child: Icon(Icons.upload, color: AppTheme.colors.white),
            )
          : null,
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: LicoesPage(),
  ));
}
