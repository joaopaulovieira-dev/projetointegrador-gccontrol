// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gccontrol/theme/app_theme.dart';

class AvaliacaoGcListWidget extends StatelessWidget {
  final QuerySnapshot snapshot;
  final List<Map<String, dynamic>> gcData; // Dados dos Grupos de Crescimento
  final void Function(String) onAvaliacaoGcSelected;

  const AvaliacaoGcListWidget({
    super.key,
    required this.snapshot,
    required this.gcData,
    required this.onAvaliacaoGcSelected,
  });

  Future<String?> getGcName(String gcId) async {
    final gcDoc =
        await FirebaseFirestore.instance.collection('gcs').doc(gcId).get();
    return gcDoc.exists ? (gcDoc.data() as Map<String, dynamic>)['nome'] : null;
  }

  @override
  Widget build(BuildContext context) {
    final avaliacoes = snapshot.docs;

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          children: List.generate(
            avaliacoes.length,
            (index) {
              final avaliacao = avaliacoes[index].data();
              final gcId =
                  (avaliacao as Map<String, dynamic>)['gcId'] as String?;

              return FutureBuilder<String?>(
                future: gcId != null ? getGcName(gcId) : null,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator(); // ou outro indicador de progresso
                  } else if (snapshot.hasError) {
                    return Text('Erro: ${snapshot.error}');
                  } else {
                    final gcName = snapshot.data;
                    return gcName != null
                        ? Card(
                            elevation: 3,
                            margin: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            color: AppTheme.colors.menulateralColor,
                            shadowColor: Colors.transparent,
                            surfaceTintColor: AppTheme.colors.menulateralColor,
                            child: ListTile(
                              title: Text(
                                gcName,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 5),
                                  Text(
                                      'Pontos Positivos: ${(avaliacao['pontosPositivos'] ?? '')}'),
                                  Text(
                                      'Pontos de Melhoria: ${(avaliacao['pontosMelhoria'] ?? '')}'),
                                  Text(
                                      'Sugestões: ${(avaliacao['sugestoes'] ?? '')}'),
                                  Text(
                                      'Impacto Pessoal: ${(avaliacao['impactoPessoal'] ?? '')}'),
                                  Text(
                                      'Observação: ${(avaliacao['observacao'] ?? '')}'),
                                  const SizedBox(height: 5),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      onAvaliacaoGcSelected(
                                          avaliacoes[index].id);
                                    },
                                    icon: Icon(Icons.edit,
                                        color: AppTheme.colors.primary),
                                  ),
                                  IconButton(
                                    onPressed: () async {
                                      if (gcId != null) {
                                        try {
                                          await FirebaseFirestore.instance
                                              .collection('avaliacoes_gc')
                                              .doc(avaliacoes[index].id)
                                              .delete();
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: const Text(
                                                'Avaliação apagada com sucesso.',
                                                style: TextStyle(
                                                    color: Colors.black),
                                              ),
                                              backgroundColor:
                                                  AppTheme.colors.primary,
                                            ),
                                          );
                                        } catch (error) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Erro ao apagar a avaliação: $error',
                                                style: const TextStyle(
                                                    color: Colors.black),
                                              ),
                                              backgroundColor:
                                                  AppTheme.colors.primary,
                                            ),
                                          );
                                        }
                                      }
                                    },
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : const SizedBox();
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
