import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gccontrol/theme/app_theme.dart';

class BodyWidget extends StatelessWidget {
  const BodyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
            //Conteudo do lado esquerdo 1/3
            width: 360,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Bem-vindo ao',
                  style: TextStyle(
                    fontSize: 45,
                    fontWeight: FontWeight.bold,
                  )),
              Text('GC Control',
                  style: TextStyle(
                    fontSize: 45,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.colors.primary,
                  )),
              const SizedBox(
                height: 30,
              ),
              const Text(
                "Impulsione seu Grupo de Crescimento",
                style: TextStyle(
                    color: Colors.black54, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(children: [
                const Text(
                  "com gestão e",
                  style: TextStyle(
                      color: Colors.black54, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 5),
                GestureDetector(
                    onTap: () {
                      if (kDebugMode) {
                        debugPrint(
                            'Botão "resultados brilhantes!" pressionado.');
                      }
                    },
                    child: Text(
                      "resultados brilhantes!",
                      style: TextStyle(
                          color: AppTheme.colors.primary,
                          fontWeight: FontWeight.bold),
                    ))
              ]),
              const SizedBox(height: 15),
              Image.asset(
                'assets/images/img_10.png',
                width: 260,
              )
            ])),

        //Conteudo do meio 2/3
        Image.asset(
          'assets/images/img_06.png',
          width: 230,
        ),
      ],
    );
  }
}
