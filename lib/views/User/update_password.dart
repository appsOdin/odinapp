import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:odinapp/Utlis/Constants.dart';
import 'package:odinapp/Utlis/CustomAlert.dart';
import 'package:odinapp/Utlis/CustomFieldValidator.dart';
import 'package:odinapp/services/user_service.dart';
import '../../theme/app_theme.dart';

class UpdatePasswordPage extends StatefulWidget {
  const UpdatePasswordPage({super.key});

  @override
  State<UpdatePasswordPage> createState() => _UpdatePasswordPageState();
}

class _UpdatePasswordPageState extends State<UpdatePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  final _currentPasswordFocus = FocusNode();
  final _newPasswordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _loading = false;

  @override
  void dispose() {
    _currentPasswordCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    _currentPasswordFocus.dispose();
    _newPasswordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  InputDecoration _buildInputDecoration({
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return InputDecoration(
      labelText: label,
      fillColor: const Color.fromARGB(255, 255, 255, 255),
      filled: true,
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(15)),
        borderSide: BorderSide(color: AppTheme.primaryColor, width: 1),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(15)),
        borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
      ),
      suffixIcon: IconButton(
        onPressed: onToggle,
        icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
        color: AppTheme.primaryColor,
      ),
    );
  }

  bool _isSuccessResponse(Map<String, dynamic> result) {
    final code = result['code']?.toString();
    return code == Constants.successCode;
  }

  void _goHome() {
    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
  }

  Future<void> _savePassword() async {
    if (_loading) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _loading = true;
    });

    final valid = await CustomFieldValidator.validateFields(
      context: context,
      fields: [
        FieldValidationDescriptor(
          controller: _currentPasswordCtrl,
          minLength: 4,
          fieldName: 'Contraseña actual',
        ),
        FieldValidationDescriptor(
          controller: _newPasswordCtrl,
          minLength: 4,
          fieldName: 'Nueva contraseña',
        ),
        FieldValidationDescriptor(
          controller: _confirmPasswordCtrl,
          minLength: 4,
          fieldName: 'Confirmar contraseña',
        ),
      ],
    );

    if (!valid) {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
      return;
    }

    if (_newPasswordCtrl.text.trim() != _confirmPasswordCtrl.text.trim()) {
      await CustomAlert.showAlert(
        context,
        'Datos incompletos',
        'Las contraseñas no coinciden',
      );
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('api_token');

      if (token == null || token.isEmpty) {
        await CustomAlert.showAlert(context, 'Error', 'No hay sesión activa');
        if (mounted) {
          setState(() {
            _loading = false;
          });
        }
        return;
      }

      final result = await UserService.updatePassword(
        token: token,
        oldPassword: _currentPasswordCtrl.text.trim(),
        newPassword: _newPasswordCtrl.text.trim(),
      );

      if (_isSuccessResponse(result)) {
        await CustomAlert.showAlert(
          context,
          '¡Éxito!',
          'Contraseña actualizada correctamente',
        );
        if (mounted) {
          _goHome();
        }
        return;
      }

      await CustomAlert.showAlert(
        context,
        'Error',
        result['message']?.toString() ?? Constants.errorMessage,
      );
    } catch (_) {
      await CustomAlert.showAlert(context, 'Error', Constants.errorMessage);
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cambiar contraseña'),
        backgroundColor: AppTheme.primaryColor,
      ),
      backgroundColor: const Color(0xfff7f7f7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xfff7f7f7),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 8),
                      TextField(
                        controller: _currentPasswordCtrl,
                        focusNode: _currentPasswordFocus,
                        inputFormatters: [LengthLimitingTextInputFormatter(20)],
                        obscureText: _obscureCurrentPassword,
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) => _newPasswordFocus.requestFocus(),
                        decoration: _buildInputDecoration(
                          label: 'Contraseña actual',
                          obscure: _obscureCurrentPassword,
                          onToggle: () {
                            setState(() {
                              _obscureCurrentPassword =
                                  !_obscureCurrentPassword;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _newPasswordCtrl,
                        focusNode: _newPasswordFocus,
                        inputFormatters: [LengthLimitingTextInputFormatter(20)],
                        obscureText: _obscureNewPassword,
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) =>
                            _confirmPasswordFocus.requestFocus(),
                        decoration: _buildInputDecoration(
                          label: 'Nueva contraseña',
                          obscure: _obscureNewPassword,
                          onToggle: () {
                            setState(() {
                              _obscureNewPassword = !_obscureNewPassword;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _confirmPasswordCtrl,
                        focusNode: _confirmPasswordFocus,
                        inputFormatters: [LengthLimitingTextInputFormatter(20)],
                        obscureText: _obscureConfirmPassword,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _savePassword(),
                        decoration: _buildInputDecoration(
                          label: 'Confirmar contraseña',
                          obscure: _obscureConfirmPassword,
                          onToggle: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _loading ? null : _goHome,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.primaryColor,
                                side: const BorderSide(
                                  color: AppTheme.primaryColor,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: const Text('Cancelar'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _loading ? null : _savePassword,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              child: _loading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : const Text('Guardar'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
