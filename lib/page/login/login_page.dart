// ignore_for_file: library_prefixes, library_private_types_in_public_api, use_build_context_synchronously, unused_field

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gccontrol/page/login/widget/body_widget.dart';
import 'package:gccontrol/page/login/widget/form_cadastro_widget.dart';
import 'package:gccontrol/page/login/widget/form_login_widget.dart';
import 'package:gccontrol/page/login/widget/form_reset_senha_widget.dart';
import 'package:gccontrol/page/login/widget/menu_widget.dart';
import 'package:gccontrol/theme/app_theme.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoginFormActive = true;
  bool _isRecuperacaoSenhaFormActive = false; // Adicione este booleano
  bool _isCadastrarFormActive = false; // Adicione este booleano
  bool _isLoading = false;
  String _activeMenuItem = 'Entrar'; // Inicializar com o item 'Entrar'

  void _toggleForm() {
    setState(() {
      _isLoginFormActive = !_isLoginFormActive;
      _isRecuperacaoSenhaFormActive = false;
      _isCadastrarFormActive = false;
    });
  }

  void _setActiveMenuItem(String item) {
    setState(() {
      _activeMenuItem = item;
      if (item == 'Recuperar Senha') {
        _isRecuperacaoSenhaFormActive = true;
        _isLoginFormActive = false;
        _isCadastrarFormActive = false;
      } else if (item == 'Cadastrar') {
        _isCadastrarFormActive = true;
        _isLoginFormActive = false;
        _isRecuperacaoSenhaFormActive = false;
      } else {
        _isLoginFormActive = true;
        _isRecuperacaoSenhaFormActive = false;
        _isCadastrarFormActive = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colors.background,
      body: ListView(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width / 8,
        ),
        children: [
          //Menu de navegação
          Menu(
            activeItem: _activeMenuItem,
            onItemPressed: (item) {
              if (item == 'Entrar' && !_isLoginFormActive) {
                _toggleForm();
              } else if (item == 'Cadastrar' && _isLoginFormActive) {
                _toggleForm();
              }
              _setActiveMenuItem(item); // Atualizar o item de menu ativo
            },
          ),

          //Formulario de login, cadastro e reset de senha
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const BodyWidget(),
              SizedBox(
                width: 350,
                child: _isRecuperacaoSenhaFormActive
                    ? FormResetSenhaWidget(
                        emailController: _emailController,
                        isLoading: _isLoading,
                        loginComGoogle: _loginComGoogle,
                        resetPassword: _resetPassword,
                      )
                    : _isLoginFormActive
                        ? FormLoginWidget(
                            emailController: _emailController,
                            passwordController: _passwordController,
                            isLoading: _isLoading,
                            login: _login,
                            loginComGoogle: _loginComGoogle,
                            context: context,
                            toggleForm: _toggleForm,
                            setActiveMenuItem: _setActiveMenuItem,
                          )
                        : FormCadastroWidget(
                            emailController: _emailController,
                            passwordController: _passwordController,
                            isLoading: _isLoading,
                            cadastrar: _cadastrar,
                            cadastrarComGoogle: _cadastrarComGoogle,
                            context: context,
                          ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      // Exibir mensagem de erro caso os campos de email ou senha estejam vazios
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: const Text('Por favor, preencha todos os campos.',
                style: TextStyle(color: Colors.black)),
            backgroundColor: AppTheme.colors.primary),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Fazer login com Firebase Auth
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Navegar para a próxima tela após o login bem-sucedido
      Navigator.pushReplacementNamed(
          context, '/verificar_perfil'); // Tela de Home
    } on FirebaseAuthException catch (e) {
      // Lidar com exceções de FirebaseAuth, como usuário não encontrado, senha incorreta, etc.
      String errorMessage = _mapFirebaseAuthErrorCode(e.code);

      // Exibir mensagem de erro
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(errorMessage, style: const TextStyle(color: Colors.black)),
            backgroundColor: AppTheme.colors.primary),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loginComGoogle(BuildContext context) async {
    try {
      // Inicie o processo de autenticação com o Google
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithPopup(googleProvider);

      // Verifique se o usuário está logado com sucesso
      if (userCredential.user != null) {
        // Navegar para a próxima tela após o login bem-sucedido
        Navigator.pushReplacementNamed(
            context, '/verificar_perfil'); // Tela de Home
      } else {
        // Se não foi possível obter informações do usuário, exiba uma mensagem de erro
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: const Text('Erro ao fazer login com o Google.',
                  style: TextStyle(color: Colors.black)),
              backgroundColor: AppTheme.colors.primary),
        );
      }
    } catch (e) {
      // Em caso de erro durante o processo de autenticação com o Google, exiba uma mensagem de erro
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erro ao fazer login com o Google: $e',
                style: const TextStyle(color: Colors.black)),
            backgroundColor: AppTheme.colors.primary),
      );
    }
  }

  Future<void> _cadastrar() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      // Exibir mensagem de erro caso os campos de email ou senha estejam vazios
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: const Text('Por favor, preencha todos os campos.',
                style: TextStyle(color: Colors.black)),
            backgroundColor: AppTheme.colors.primary),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Cadastrar usuário com Firebase Auth
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: const Text('Usuário cadastrado com sucesso!',
                style: TextStyle(color: Colors.black)),
            backgroundColor: AppTheme.colors.primary),
      );

      // Atualizar o menu ativo para 'Entrar'
      _setActiveMenuItem('Entrar');
      // Atualizar o estado para exibir o formulário de login
      _isLoginFormActive = true;
      // Limpar os campos de e-mail e senha
      _emailController.clear();
      _passwordController.clear();
    } on FirebaseAuthException catch (e) {
      // Lidar com exceções de FirebaseAuth, como email já cadastrado, etc.
      String errorMessage = _mapFirebaseAuthErrorCode(e.code);

      // Exibir mensagem de erro
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(errorMessage, style: const TextStyle(color: Colors.black)),
            backgroundColor: AppTheme.colors.primary),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _cadastrarComGoogle(BuildContext context) async {
    try {
      // Inicie o processo de autenticação com o Google
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithPopup(googleProvider);

      // Verifique se o usuário já está cadastrado
      if (userCredential.additionalUserInfo!.isNewUser) {
        // Se o usuário for novo, realize o cadastro com os dados disponíveis
        // Você pode personalizar essa lógica de acordo com suas necessidades
        // Aqui, por exemplo, apenas exibimos uma mensagem informando que o usuário foi cadastrado
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: const Text('Usuário cadastrado com sucesso!',
                  style: TextStyle(color: Colors.black)),
              backgroundColor: AppTheme.colors.primary),
        );
        // Atualizar o menu ativo para 'Entrar'
        _setActiveMenuItem('Entrar');
        // Atualizar o estado para exibir o formulário de login
        _isLoginFormActive = true;
        // Limpar os campos de e-mail e senha
        _emailController.clear();
        _passwordController.clear();
      } else {
        // Se o usuário já existir, faça algo diferente
        // Por exemplo, faça o login diretamente ou exiba uma mensagem informando que o usuário já está cadastrado
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: const Text('Usuário já cadastrado!',
                  style: TextStyle(color: Colors.black)),
              backgroundColor: AppTheme.colors.primary),
        );
        // Atualizar o menu ativo para 'Entrar'
        _setActiveMenuItem('Entrar');
        // Atualizar o estado para exibir o formulário de login
        _isLoginFormActive = true;
        // Limpar os campos de e-mail e senha
        _emailController.clear();
        _passwordController.clear();
      }
    } catch (e) {
      // Em caso de erro durante o processo de autenticação com o Google, exiba uma mensagem de erro
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erro ao cadastrar com o Google: $e',
                style: const TextStyle(color: Colors.black)),
            backgroundColor: AppTheme.colors.primary),
      );
    }
  }

  String _mapFirebaseAuthErrorCode(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Usuário não encontrado.';
      case 'wrong-password':
        return 'Senha incorreta.';
      case 'invalid-email':
        return 'E-mail inválido.';
      case 'user-disabled':
        return 'Usuário desabilitado.';
      case 'operation-not-allowed':
        return 'Operação não permitida.';
      case 'network-request-failed':
        return 'Falha na conexão. Verifique sua conexão com a internet.';

      default:
        return 'Ocorreu um erro durante o login. Por favor, tente novamente mais tarde.';
    }
  }

// Função de reset de senha
  void _resetPassword() {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: const Text('Por favor, insira seu e-mail.',
                style: TextStyle(color: Colors.black)),
            backgroundColor: AppTheme.colors.primary),
      );
      return;
    }

    FirebaseAuth.instance
        .sendPasswordResetEmail(
      email: _emailController.text,
    )
        .then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: const Text(
                'Um e-mail foi enviado para redefinir sua senha.',
                style: TextStyle(color: Colors.black)),
            backgroundColor: AppTheme.colors.primary),
      );
    }).catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erro ao enviar e-mail de redefinição de senha: $e',
                style: const TextStyle(color: Colors.black)),
            backgroundColor: AppTheme.colors.primary),
      );
    });
  }
}
