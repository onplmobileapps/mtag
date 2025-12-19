import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mtag_flutterapp/widgets/dialog/cupertino_dialog.dart';
import '../../api/auth_controller.dart';
import '../../base/app_data.dart';



void showChangePinDialog(
  BuildContext context, {
  required Function(String oldPin, String newPin) onSubmit,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const ChangePinDialog(),
  );
}

class ChangePinDialog extends StatefulWidget {
  const ChangePinDialog({super.key});

  @override
  State<ChangePinDialog> createState() => _ChangePinDialogState();
}

class _ChangePinDialogState extends State<ChangePinDialog> {
  final _oldPinController = TextEditingController();
  final _newPinController = TextEditingController();
  final _reenterPinController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final _oldPinFocusNode = FocusNode();
  final _newPinFocusNode = FocusNode();
  final _reenterPinFocusNode = FocusNode();

  bool _obscureOldPin = true;
  bool _obscureNewPin = true;
  bool _obscureReenterPin = true;
  bool _isSubmitting = false;

  bool _isPinsMatching() {
    return _newPinController.text == _reenterPinController.text;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_isSubmitting) return;
    
    setState(() => _isSubmitting = true);
    
    try {
      // Call the parent submit callback
      final onSubmit = ModalRoute.of(context)!.settings.arguments as Function(String, String)?;
      if (onSubmit != null) {
        onSubmit(_oldPinController.text, _newPinController.text);
      }

      // Call your API
      final authController = Get.find<AuthController>();
    var resposne=  await authController.createPIN(
        cnic: AppData.getPinData()?['cnic'],
        mobileNum: AppData.getPinData()?['mobile'],
        isResetPin: 1,
        isCreatePin: 0,
        isForgetPin: 0,
        pin: _oldPinController.text,
        newPin: _newPinController.text,
      );
showPopDialog(resposne['Message'], Get.back);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return PopScope(
      canPop: !_isSubmitting,
      child: Dialog(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: colorScheme.surfaceTint,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset('assets/padlock.png', height: 50),
                    const SizedBox(height: 12),
                    Text('Change PIN', 
                      style: theme.textTheme.headlineSmall
                    ),
                    const SizedBox(height: 20),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildPinField(
                            context: context,
                            controller: _oldPinController,
                            focusNode: _oldPinFocusNode,
                            obscureText: _obscureOldPin,
                            labelText: 'Old PIN',
                            onToggleVisibility: () => setState(() => _obscureOldPin = !_obscureOldPin),
                            validator: (value) => value == null || value.length != 4
                                ? 'Enter 4-digit PIN'
                                : null,
                          ),
                          const SizedBox(height: 8),
                          _buildPinField(
                            context: context,
                            controller: _newPinController,
                            focusNode: _newPinFocusNode,
                            obscureText: _obscureNewPin,
                            labelText: 'New PIN',
                            onToggleVisibility: () => setState(() => _obscureNewPin = !_obscureNewPin),
                            validator: (value) => value == null || value.length != 4
                                ? 'Enter 4-digit PIN'
                                : null,
                            onFieldSubmitted: (_) => _reenterPinFocusNode.requestFocus(),
                          ),
                          const SizedBox(height: 8),
                          _buildPinField(
                            context: context,
                            controller: _reenterPinController,
                            focusNode: _reenterPinFocusNode,
                            obscureText: _obscureReenterPin,
                            labelText: 'Re-Enter New PIN',
                            onToggleVisibility: () => setState(() => _obscureReenterPin = !_obscureReenterPin),
                            validator: (value) {
                              if (value == null || value.length != 4) {
                                return 'Enter 4-digit PIN';
                              }
                              if (!_isPinsMatching()) {
                                return "PINs don't match";
                              }
                              return null;
                            },
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _submitForm(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 36, // Reduced height
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(
                                'SUBMIT',
                               
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                  icon: CircleAvatar(radius: 16,
                    backgroundColor: colorScheme.surface,
                    child: Icon(Icons.close, size: 20,color: colorScheme.primary, )),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  splashRadius: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPinField({
    required BuildContext context,
    required TextEditingController controller,
    required FocusNode focusNode,
    required bool obscureText,
    required String labelText,
    required VoidCallback onToggleVisibility,
    required String? Function(String?) validator,
    TextInputAction textInputAction = TextInputAction.next,
    void Function(String)? onFieldSubmitted,
  }) {
    final theme = Theme.of(context);
    
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: TextInputType.number,
      obscureText: obscureText,
      maxLength: 4,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      style: theme.textTheme.bodyMedium?.copyWith(
        fontSize: 14, // Smaller font size
      ),
      decoration: InputDecoration(
        counterText: "",
        labelText: labelText,
        labelStyle: theme.textTheme.bodyMedium?.copyWith(
          fontSize: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 0, // Reduced vertical padding
        ),
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 4),
          child: IconButton(
            onPressed: onToggleVisibility,
            icon: Icon(
              obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              size: 18, // Smaller icon
              color: theme.colorScheme.onSurface.withValues(alpha:0.6),
            ),
            splashRadius: 16,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,maxHeight: 32,maxWidth: 32
            ),
          ),
        ),
      ),
      validator: validator,
    );
  }

  @override
  void dispose() {
    _oldPinController.dispose();
    _newPinController.dispose();
    _reenterPinController.dispose();
    _oldPinFocusNode.dispose();
    _newPinFocusNode.dispose();
    _reenterPinFocusNode.dispose();
    super.dispose();
  }
}

