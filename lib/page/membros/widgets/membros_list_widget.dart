// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gccontrol/theme/app_theme.dart';

class MembrosListWidget extends StatelessWidget {
  final QuerySnapshot snapshot;
  final void Function(String) onMembroSelected;

  const MembrosListWidget({
    super.key,
    required this.snapshot,
    required this.onMembroSelected,
  });

  @override
  Widget build(BuildContext context) {
    final membros = snapshot.docs;

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          children: List.generate(
            membros.length,
            (index) {
              final membro = membros[index].data();
              final membroId = membros[index].id;

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('gcs')
                    .doc((membro as Map<String, dynamic>)['gcId'])
                    .get(),
                builder: (context, gcSnapshot) {
                  if (gcSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (gcSnapshot.hasError) {
                    return Text(
                        'Erro ao carregar o nome do GC: ${gcSnapshot.error}');
                  }

                  final gcData = gcSnapshot.data!.data();
                  final gcNome = (gcData! as Map<String, dynamic>)['nome'];

                  return Card(
                    elevation: 3,
                    margin:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    color: AppTheme.colors.menulateralColor,
                    shadowColor: Colors.transparent,
                    surfaceTintColor: AppTheme.colors.menulateralColor,
                    child: ListTile(
                      title: Text(
                        (membro)['nome'],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 5),
                          Text('Nome: ${membro['nome']}'),
                          Text('Telefone: ${membro['telefone']}'),
                          Text('Endereço: ${membro['endereco']}'),
                          Text('Bairro: ${membro['bairro']}'),
                          Text('Cidade: ${membro['cidade']}'),
                          Text('GC: $gcNome'),
                          const SizedBox(height: 5),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {
                              onMembroSelected(membroId);
                            },
                            icon: Icon(Icons.edit,
                                color: AppTheme.colors.primary),
                          ),
                          IconButton(
                            onPressed: () async {
                              if (membroId.isNotEmpty) {
                                try {
                                  await FirebaseFirestore.instance
                                      .collection('membros')
                                      .doc(membroId)
                                      .delete();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: const Text(
                                            'Membro apagado com sucesso.',
                                            style:
                                                TextStyle(color: Colors.black)),
                                        backgroundColor:
                                            AppTheme.colors.primary),
                                  );
                                } catch (error) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Erro ao apagar o membro: $error',
                                            style: const TextStyle(
                                                color: Colors.black)),
                                        backgroundColor:
                                            AppTheme.colors.primary),
                                  );
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: const Text(
                                          'ID do membro inválido.',
                                          style:
                                              TextStyle(color: Colors.black)),
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
              );
            },
          ),
        ),
      ),
    );
  }
}
