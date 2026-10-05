import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_button.dart';

class AuthSheet extends StatefulWidget {
  final VoidCallback onAuthenticated;

  const AuthSheet({
    super.key,
    required this.onAuthenticated,
  });

  static Future<void> show(BuildContext context, {required VoidCallback onAuthenticated}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AuthSheet(onAuthenticated: onAuthenticated),
    );
  }

  @override
  State<AuthSheet> createState() => _AuthSheetState();
}

class _AuthSheetState extends State<AuthSheet> {
  bool _isLoginTab = true;

  final _nameController = TextEditingController(text: 'Alexandre Laurent');
  final _emailController = TextEditingController(text: 'alexandre@example.com');
  final _phoneController = TextEditingController(text: '+1 (613) 555-0142');
  final _passwordController = TextEditingController(text: 'password123');

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    final auth = context.read<AuthProvider>();
    if (_isLoginTab) {
      await auth.login(_emailController.text, _passwordController.text);
    } else {
      await auth.signup(
        _nameController.text,
        _emailController.text,
        _phoneController.text,
        _passwordController.text,
      );
    }

    if (mounted) {
      Navigator.of(context).pop();
      widget.onAuthenticated();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 20, 24, bottomInset + 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Title
          Text(
            _isLoginTab ? 'Welcome Back' : 'Create an Account',
            style: AppTypography.displaySmall.copyWith(fontSize: 24),
          ),
          const SizedBox(height: 6),
          Text(
            'Sign in or sign up to finalize your order with OB Hospitality.',
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: 20),

          // Tabs: Login vs Sign Up
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _isLoginTab = true),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _isLoginTab ? AppColors.surface : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: _isLoginTab
                            ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : [],
                      ),
                      child: Text(
                        'LOG IN',
                        style: AppTypography.labelMedium.copyWith(
                          fontWeight: _isLoginTab ? FontWeight.w700 : FontWeight.w500,
                          color: _isLoginTab ? AppColors.textPrimary : AppColors.textTertiary,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _isLoginTab = false),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: !_isLoginTab ? AppColors.surface : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: !_isLoginTab
                            ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : [],
                      ),
                      child: Text(
                        'SIGN UP',
                        style: AppTypography.labelMedium.copyWith(
                          fontWeight: !_isLoginTab ? FontWeight.w700 : FontWeight.w500,
                          color: !_isLoginTab ? AppColors.textPrimary : AppColors.textTertiary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Form fields
          if (!_isLoginTab) ...[
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                labelStyle: AppTypography.bodySmall,
                filled: true,
                fillColor: AppColors.surfaceVariant,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),
          ],

          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email Address',
              labelStyle: AppTypography.bodySmall,
              filled: true,
              fillColor: AppColors.surfaceVariant,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 12),

          if (!_isLoginTab) ...[
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                labelStyle: AppTypography.bodySmall,
                filled: true,
                fillColor: AppColors.surfaceVariant,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),
          ],

          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Password',
              labelStyle: AppTypography.bodySmall,
              filled: true,
              fillColor: AppColors.surfaceVariant,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 24),

          // Submit button
          Consumer<AuthProvider>(
            builder: (_, auth, __) => AppButton(
              label: _isLoginTab ? 'LOG IN & CONTINUE' : 'CREATE ACCOUNT & CONTINUE',
              isLoading: auth.isLoading,
              onPressed: _handleSubmit,
            ),
          ),
          const SizedBox(height: 12),

          // One-tap guest toggle for testing
          Center(
            child: TextButton.icon(
              onPressed: () {
                _emailController.text = 'guest@obhospitality.com';
                _handleSubmit();
              },
              icon: const Icon(Icons.flash_on_rounded, size: 16, color: AppColors.ochre),
              label: Text(
                'Quick Demo Sign-In (1-Tap)',
                style: AppTypography.labelMedium.copyWith(color: AppColors.ochre),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
