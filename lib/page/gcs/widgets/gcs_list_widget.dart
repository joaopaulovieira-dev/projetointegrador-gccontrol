// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gccontrol/theme/app_theme.dart';

class GCsListWidget extends StatelessWidget {
  final QuerySnapshot snapshot;
  final void Function(String) onGCSelected;

  const GCsListWidget({
    super.key,
    required this.snapshot,
    required this.onGCSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          children: List.generate(
            snapshot.docs.length,
            (index) {
              final gc = snapshot.docs[index].data();
              final gcId = snapshot.docs[index].id;

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                color: AppTheme.colors.menulateralColor,
                shadowColor: Colors.transparent,
                surfaceTintColor: AppTheme.colors.menulateralColor,
                child: ListTile(
                  title: Text(
                    (gc as Map<String, dynamic>)['nome'],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 5),
                      Text('Rua: ${gc['endereco']}'),
                      Text('Bairro: ${gc['bairro']}'),
                      Text('Cidade: ${gc['cidade']}'),
                      Text('Publico Alvo: ${gc['publicoAlvo']}'),
                      Text('Horário: ${gc['horario']}'),
                      const SizedBox(height: 5),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          onGCSelected(gcId);
                        },
                        icon: Icon(Icons.edit, color: AppTheme.colors.primary),
                      ),
                      IconButton(
                        onPressed: () async {
                          if (gcId.isNotEmpty) {
                            try {
                              await FirebaseFirestore.instance
                                  .collection('gcs')
                                  .doc(gcId)
                                  .delete();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: const Text(
                                        'GC apagado com sucesso.',
                                        style: TextStyle(color: Colors.black)),
                                    backgroundColor: AppTheme.colors.primary),
                              );
                            } catch (error) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Erro ao apagar o GC: $error',
                                        style: const TextStyle(
                                            color: Colors.black)),
                                    backgroundColor: AppTheme.colors.primary),
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: const Text('ID do GC inválido.',
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
