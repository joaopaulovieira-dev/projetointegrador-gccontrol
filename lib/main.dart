import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gccontrol/app_widget.dart';
import 'package:gccontrol/firebase_options.dart';

/// O ponto de entrada do aplicativo.
/// Esta função inicializa o framework Flutter e o Firebase, e em seguida executa o aplicativo.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const AppWidget());
}
