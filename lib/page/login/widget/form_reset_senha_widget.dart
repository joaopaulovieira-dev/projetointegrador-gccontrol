import 'package:flutter/material.dart';
import 'package:gccontrol/theme/app_theme.dart';

class FormResetSenhaWidget extends StatelessWidget {
  final TextEditingController emailController;
  final bool isLoading;
  final VoidCallback resetPassword;
  final void Function(BuildContext) loginComGoogle;

  const FormResetSenhaWidget({
    super.key,
    required this.emailController,
    required this.isLoading,
    required this.resetPassword,
    required this.loginComGoogle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Resetar Senha',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 30),
        TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'E-mail',
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
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: isLoading ? null : resetPassword,
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
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : const Text("Enviar E-mail de Recuperação"),
            ),
          ),
        ),
        const SizedBox(height: 40)
      ],
    );
  }
}
