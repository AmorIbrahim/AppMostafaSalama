import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_text_field.dart';

/// Modal dialog for changing driver password (first-time login requirement or profile setting)
class ChangePasswordDialog extends StatefulWidget {
  final bool isMandatoryFirstLogin;

  const ChangePasswordDialog({
    Key? key,
    this.isMandatoryFirstLogin = false,
  }) : super(key: key);

  static Future<bool?> show(
    BuildContext context, {
    bool isMandatoryFirstLogin = false,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: !isMandatoryFirstLogin,
      builder: (ctx) => PopScope(
        canPop: !isMandatoryFirstLogin,
        child: ChangePasswordDialog(isMandatoryFirstLogin: isMandatoryFirstLogin),
      ),
    );
  }

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.changePassword(
      currentPassword: widget.isMandatoryFirstLogin ? null : _currentPasswordController.text,
      newPassword: _newPasswordController.text,
      newPasswordConfirmation: _confirmPasswordController.text,
    );

    if (mounted) {
      if (success) {
        final loc = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.translate('passwordUpdated')),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(auth.errorMessage ?? 'Failed to update password.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();

    return Dialog(
      backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.lock_reset_rounded, color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.isMandatoryFirstLogin
                          ? loc.translate('mustChangePasswordTitle')
                          : loc.translate('changePassword'),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (widget.isMandatoryFirstLogin)
                Text(
                  loc.translate('mustChangePasswordMsg'),
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                  ),
                ),
              const SizedBox(height: 20),

              if (!widget.isMandatoryFirstLogin) ...[
                AppTextField(
                  controller: _currentPasswordController,
                  label: loc.translate('currentPassword'),
                  obscureText: _obscureCurrent,
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: IconButton(
                    icon: Icon(_obscureCurrent ? Icons.visibility_off : Icons.visibility, size: 18),
                    onPressed: () => setState(() => _obscureCurrent = !_obscureCurrent),
                  ),
                  validator: (v) => (v == null || v.isEmpty) ? loc.translate('passwordTooShort') : null,
                ),
                const SizedBox(height: 14),
              ],

              AppTextField(
                controller: _newPasswordController,
                label: loc.translate('newPassword'),
                obscureText: _obscureNew,
                prefixIcon: Icons.lock_rounded,
                suffixIcon: IconButton(
                  icon: Icon(_obscureNew ? Icons.visibility_off : Icons.visibility, size: 18),
                  onPressed: () => setState(() => _obscureNew = !_obscureNew),
                ),
                validator: (v) {
                  if (v == null || v.length < 6) {
                    return loc.translate('passwordTooShort');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              AppTextField(
                controller: _confirmPasswordController,
                label: loc.translate('confirmNewPassword'),
                obscureText: _obscureConfirm,
                prefixIcon: Icons.lock_rounded,
                suffixIcon: IconButton(
                  icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility, size: 18),
                  onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                ),
                validator: (v) {
                  if (v != _newPasswordController.text) {
                    return loc.translate('passwordsDoNotMatch');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  if (!widget.isMandatoryFirstLogin) ...[
                    Expanded(
                      child: TextButton(
                        onPressed: auth.isLoading ? null : () => Navigator.of(context).pop(false),
                        child: Text(
                          loc.translate('cancel'),
                          style: TextStyle(
                            color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    flex: 2,
                    child: AppButton(
                      text: loc.translate('updatePassword'),
                      isLoading: auth.isLoading,
                      onPressed: _submit,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
