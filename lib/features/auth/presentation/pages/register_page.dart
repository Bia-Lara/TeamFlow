import 'package:flutter/material.dart';
import '../widgets/auth_field.dart';
import '../widgets/auth_button.dart';
import '../../../../core/layout/main_page.dart';
import '../../../profile/data/user.entity.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? const Color(0xFFFF4757) : const Color(0xFF6C63FF),
      ),
    );
  }

  void _register() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showSnackBar('Preencha todos os campos');
      return;
    }

    if (password.length < 6) {
      _showSnackBar('A senha deve ter pelo menos 6 caracteres');
      return;
    }

    if (password != confirmPassword) {
      _showSnackBar('As senhas não coincidem');
      return;
    }

    setState(() => _isLoading = true);

    // TODO: integrar com backend — POST /auth/register
    // Simulando delay de rede
    await Future.delayed(const Duration(seconds: 1));

    // Mock: cria o objeto User (pronto para enviar ao backend)
    final newUser = User(
      name: name,
      email: email,
      password: password,
      groupIds: [],
    );

    // Log para debug — remover quando integrar com backend
    debugPrint('Usuário criado: ${newUser.toJson()}');

    if (!mounted) return;

    _showSnackBar('Conta criada com sucesso', isError: false);

    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060B1A),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 10, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Voltar',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    const Text(
                      'Criar conta',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      'Preencha seus dados para começar',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Avatar placeholder
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 44,
                            backgroundColor:
                                const Color(0xFF6C63FF).withOpacity(0.2),
                            child: const Icon(
                              Icons.person_outline,
                              color: Color(0xFF6C63FF),
                              size: 44,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Color(0xFF6C63FF),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    AuthField(
                      controller: _nameController,
                      label: 'Nome completo',
                      hint: 'Seu nome',
                      icon: Icons.person_outline,
                    ),

                    const SizedBox(height: 18),

                    AuthField(
                      controller: _emailController,
                      label: 'E-mail',
                      hint: 'seu@email.com',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),

                    const SizedBox(height: 18),

                    AuthField(
                      controller: _passwordController,
                      label: 'Senha',
                      hint: '••••••••',
                      icon: Icons.lock_outline,
                      isObscured: _obscurePassword,
                      onToggleObscure: () {
                        setState(
                            () => _obscurePassword = !_obscurePassword);
                      },
                    ),

                    const SizedBox(height: 18),

                    AuthField(
                      controller: _confirmPasswordController,
                      label: 'Confirmar senha',
                      hint: '••••••••',
                      icon: Icons.lock_outline,
                      isObscured: _obscureConfirm,
                      onToggleObscure: () {
                        setState(
                            () => _obscureConfirm = !_obscureConfirm);
                      },
                    ),

                    const SizedBox(height: 30),

                    AuthButton(
                      label: 'Cadastrar',
                      onTap: _register,
                      isLoading: _isLoading,
                    ),

                    const SizedBox(height: 24),

                    // Login link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Já tem conta? ',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 14,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Text(
                            'Entrar',
                            style: TextStyle(
                              color: Color(0xFF6C63FF),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
