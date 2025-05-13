import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:frontend_fo_application_streaming/core/constants/colors.dart';
import 'package:frontend_fo_application_streaming/data/providers/auth_provider.dart';
import 'package:frontend_fo_application_streaming/presentation/screens/home/home_page.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _userNameController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _selectedAvatar;

  final List<String> _avatars = [
    'https://api.dicebear.com/9.x/micah/svg?seed=Adrian',
    'https://api.dicebear.com/9.x/micah/svg?seed=Jocelyn',
    'https://api.dicebear.com/9.x/notionists-neutral/svg?seed=Jocelyn',
    'https://api.dicebear.com/9.x/bottts-neutral/svg?seed=Charlie',
    'https://api.dicebear.com/9.x/pixel-art-neutral/svg?seed=Max',
    'https://api.dicebear.com/9.x/identicon/svg?seed=Sammy',
  ];

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _userNameController.dispose();
    super.dispose();
  }

  void _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedAvatar == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select an avatar")),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    await authProvider.register(
      _userNameController.text,
      _emailController.text,
      _passwordController.text,
      _selectedAvatar,
    );

    if (authProvider.error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.error!)),
      );
    } else if (authProvider.isAuthenticated && mounted) {
      // Navigation vers la page d'accueil si l'authentification est réussie
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                const Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Register to get started',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),

                // Avatar Selection
                _buildAvatarSelection(),
                const SizedBox(height: 32),

                // Username Field
                TextFormField(
                  controller: _userNameController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Username',
                    labelStyle: const TextStyle(color: AppColors.textSecondary),
                    prefixIcon: const Icon(
                      Icons.person_outline,
                      color: AppColors.accent,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.accent),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                    ),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter a username'
                      : null,
                ),
                const SizedBox(height: 24),

                // Email Field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: const TextStyle(color: AppColors.textSecondary),
                    prefixIcon: const Icon(
                      Icons.email_outlined,
                      color: AppColors.accent,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.accent),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email';
                    }
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: const TextStyle(color: AppColors.textSecondary),
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: AppColors.accent,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.accent,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.accent),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Confirm Password Field
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    labelStyle: const TextStyle(color: AppColors.textSecondary),
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: AppColors.accent,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.accent,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.accent),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Register Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: authProvider.isLoading ? null : _register,
                    child: authProvider.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'REGISTER',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),

                // Login Navigation
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account?",
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choose Your Avatar',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _avatars.length,
            itemBuilder: (context, index) {
              final avatarUrl = _avatars[index];
              final isSelected = _selectedAvatar == avatarUrl;

              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedAvatar = avatarUrl),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            isSelected ? AppColors.primary : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 32,
                        child: ClipOval(
                          child: SvgPicture.network(
                            avatarUrl,
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                            placeholderBuilder: (context) =>
                                const CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
