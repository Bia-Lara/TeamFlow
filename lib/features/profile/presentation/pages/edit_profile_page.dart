import 'package:flutter/material.dart';
import '../../data/user.entity.dart';
import '../widgets/profile_avatar.dart';

class EditProfilePage extends StatefulWidget {
  final User user;

  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name ?? '');
    _emailController = TextEditingController(text: widget.user.email ?? '');
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty || email.isEmpty) {
      _showSnackBar('Nome e e-mail são obrigatórios');
      return;
    }

    if (password.isNotEmpty && password != confirmPassword) {
      _showSnackBar('As senhas não coincidem');
      return;
    }

    if (password.isNotEmpty && password.length < 6) {
      _showSnackBar('A senha deve ter pelo menos 6 caracteres');
      return;
    }

    final updatedUser = widget.user.copyWith(
      name: name,
      email: email,
      password: password.isNotEmpty ? password : widget.user.password,
    );

    // TODO: integrar com backend — PUT /users/:id
    Navigator.pop(context, updatedUser);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFFF4757),
      ),
    );
  }

  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0F1733),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Excluir conta',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Essa ação é irreversível. Todos os seus dados serão removidos permanentemente. Deseja continuar?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // fecha dialog
              // TODO: integrar com backend — DELETE /users/:id
              Navigator.pop(context, 'deleted');
            },
            child: const Text(
              'Excluir conta',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    VoidCallback? onToggleObscure,
    bool isObscured = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 13),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0F1733),
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            obscureText: isObscured,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: label,
              hintStyle: const TextStyle(color: Colors.white24),
              prefixIcon: Icon(icon, color: Colors.white38),
              suffixIcon: onToggleObscure != null
                  ? IconButton(
                      onPressed: onToggleObscure,
                      icon: Icon(
                        isObscured
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.white38,
                      ),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060B1A),
      body: Column(
        children: [
          // Header gradient
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF3B3B98)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(30),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                const Text(
                  'Editar Perfil',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: _save,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8F7BFF),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Text(
                      'Salvar',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Avatar
                  Center(
                    child: ProfileAvatar(
                      name: _nameController.text.isNotEmpty
                          ? _nameController.text
                          : widget.user.name ?? '',
                      radius: 48,
                      onEditTap: () {
                        // TODO: integrar upload de foto
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Upload de foto em breve'),
                            backgroundColor: Color(0xFF6C63FF),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 30),

                  _buildField(
                    controller: _nameController,
                    label: 'Nome completo',
                    icon: Icons.person_outline,
                  ),

                  const SizedBox(height: 18),

                  _buildField(
                    controller: _emailController,
                    label: 'E-mail',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 18),

                  _buildField(
                    controller: _passwordController,
                    label: 'Nova senha (opcional)',
                    icon: Icons.lock_outline,
                    isObscured: _obscurePassword,
                    onToggleObscure: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),

                  const SizedBox(height: 18),

                  _buildField(
                    controller: _confirmPasswordController,
                    label: 'Confirmar nova senha',
                    icon: Icons.lock_outline,
                    isObscured: _obscureConfirm,
                    onToggleObscure: () {
                      setState(() => _obscureConfirm = !_obscureConfirm);
                    },
                  ),

                  const SizedBox(height: 36),

                  // Delete account
                  SizedBox(
                    width: double.infinity,
                    child: InkWell(
                      onTap: _confirmDeleteAccount,
                      borderRadius: BorderRadius.circular(16),
                      child: Ink(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.redAccent.withOpacity(0.5),
                          ),
                        ),
                        child: const Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.delete_forever,
                                color: Colors.redAccent,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Excluir minha conta',
                                style: TextStyle(
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
