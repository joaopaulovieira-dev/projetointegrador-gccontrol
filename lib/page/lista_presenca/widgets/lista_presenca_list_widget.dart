// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gccontrol/theme/app_theme.dart';

class ListaPresencaListWidget extends StatelessWidget {
  final QuerySnapshot snapshot;
  final void Function(String) onGCSelected;

  const ListaPresencaListWidget({
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
                      ElevatedButton(
                        onPressed: () {
                          onGCSelected(gcId);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.colors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Marcar Presença',
                          style: TextStyle(color: Colors.white),
                        ),
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
