// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gccontrol/theme/app_theme.dart';

class IgrejasListWidget extends StatelessWidget {
  final QuerySnapshot snapshot;
  final String currentUserId;
  final void Function(String) onIgrejaSelected;

  const IgrejasListWidget({
    super.key,
    required this.snapshot,
    required this.currentUserId,
    required this.onIgrejaSelected,
  });

  @override
  Widget build(BuildContext context) {
    final igrejas = snapshot.docs
        .where((doc) => doc['idUsuarioAdministrador'] == currentUserId)
        .toList();

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          children: List.generate(
            igrejas.length,
            (index) {
              final igreja = igrejas[index].data();
              final igrejaId = igrejas[index].id;

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                color: AppTheme.colors.menulateralColor,
                shadowColor: Colors.transparent,
                surfaceTintColor: AppTheme.colors.menulateralColor,
                child: ListTile(
                  title: Text(
                    (igreja as Map<String, dynamic>)['nome'],
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 5),
                      Text('CNPJ: ${igreja['cnpj']}'),
                      Text('Bairro: ${igreja['bairro']}'),
                      Text('Cidade: ${igreja['cidade']}'),
                      Text('Estado: ${igreja['estado']}'),
                      const SizedBox(height: 5),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          onIgrejaSelected(igrejaId);
                        },
                        icon: Icon(Icons.edit, color: AppTheme.colors.primary),
                      ),
                      IconButton(
                        onPressed: () async {
                          if (igrejaId.isNotEmpty) {
                            try {
                              await FirebaseFirestore.instance
                                  .collection('igrejas')
                                  .doc(igrejaId)
                                  .delete();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: const Text(
                                        'Igreja apagada com sucesso.',
                                        style: TextStyle(color: Colors.black)),
                                    backgroundColor: AppTheme.colors.primary),
                              );
                            } catch (error) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Erro ao apagar a igreja: $error',
                                        style: const TextStyle(
                                            color: Colors.black)),
                                    backgroundColor: AppTheme.colors.primary),
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: const Text('ID da igreja inválido.',
                                      style: TextStyle(color: Colors.black)),
                                  backgroundColor: AppTheme.colors.primary),
                            );
                          }
                        },
                        icon: const Icon(Icons.delete, color: Colors.red),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
