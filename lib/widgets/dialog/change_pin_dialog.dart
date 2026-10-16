import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mtag_flutterapp/theme/app_theme.dart';
import 'package:mtag_flutterapp/widgets/elevated_button.dart';
import '../../api/auth_controller.dart';
import '../../base/app_data.dart';



void showChangePinDialog(
  BuildContext context, {
  required Function(String oldPin, String newPin) onSubmit,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) =>  ChangePinDialog(onSubmit: onSubmit,),
  );
}

class ChangePinDialog extends StatefulWidget {
  final Function(String oldPin, String newPin) onSubmit;

  const ChangePinDialog({super.key, required this.onSubmit});

  @override
  State<ChangePinDialog> createState() => _ChangePinDialogState();
}

class _ChangePinDialogState extends State<ChangePinDialog> {
  late final TextEditingController _oldPinController;
  late final TextEditingController _newPinController;
  late final TextEditingController _reenterPinController;
  final _formKey = GlobalKey<FormState>();

  late final FocusNode _oldPinFocusNode;
  late final FocusNode _newPinFocusNode;
  late final FocusNode _reenterPinFocusNode;

  @override
  void initState() {
    super.initState();
    _oldPinController = TextEditingController();
    _newPinController = TextEditingController();
    _reenterPinController = TextEditingController();
    _oldPinFocusNode = FocusNode();
    _newPinFocusNode = FocusNode();
    _reenterPinFocusNode = FocusNode();
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

  bool _isPinsMatching() {
    return _newPinController.text == _reenterPinController.text;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: colorScheme.surfaceContainerLowest,
        surfaceTintColor: colorScheme.surfaceTint,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient:
                    Theme.of(context).extension<AppGradients>()!.background,
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/padlock.png', height: 65, width: 65),
                  Text(
                    'Change PIN',
                    style: TextTheme.of(context).bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        PinTextField(
                          hintText: 'Old PIN',
                          controller: _oldPinController,
                          focusNode: _oldPinFocusNode,
                          floatingLabelNever: true,
                          validator:
                              (value) =>
                                  value == null ||
                                          value.isEmpty ||
                                          value.length < 4
                                      ? 'Please enter your old PIN'
                                      : null,
                        ),
                        const SizedBox(height: 12),
                        PinTextField(
                          hintText: 'New Pin',
                          controller: _newPinController,
                          focusNode: _newPinFocusNode,
                          validator:
                              (value) =>
                                  value == null ||
                                          value.isEmpty ||
                                          value.length < 4
                                      ? 'Please enter a new PIN'
                                      : null,
                          onFieldSubmitted: (_) {
                            FocusScope.of(
                              context,
                            ).requestFocus(_reenterPinFocusNode);
                          },
                        ),
                        const SizedBox(height: 12),
                        PinTextField(
                          hintText: 'Re-Enter New PIN',
                          controller: _reenterPinController,
                          focusNode: _reenterPinFocusNode,
                          textInputAction: TextInputAction.done,
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                value.length < 4) {
                              return 'Please re-enter your new PIN';
                            } else if (!_isPinsMatching()) {
                              return "New Pin & Re-Enter Pin doesn't match";
                            }
                            return null;
                          },
                          onFieldSubmitted: (_) {
                            if (_formKey.currentState!.validate()) {
                              widget.onSubmit(
                                _oldPinController.text,
                                _newPinController.text,
                              );
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton1(
                    onclick: () async {
                      if (_formKey.currentState!.validate()) {
                        widget.onSubmit(
                          _oldPinController.text,
                          _newPinController.text,
                        );

                        await Get.find<AuthController>().createPIN(
                          cnic: AppData.getPinData()?['cnic'],
                          mobileNum: AppData.getPinData()?['mobile'],
                          isResetPin: 1,
                          isCreatePin: 0,
                          isForgetPin: 0,
                          pin: _oldPinController.text.toString(),
                          newPin: _newPinController.text.toString(),
                        );
                      }
                    },
                    text: 'Submit',
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(20),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.red,
                    radius: 16,
                    child: Icon(Icons.close, color: Colors.white, size: 18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PinTextField extends StatefulWidget {
  final String? labelText;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String? Function(String?)? validator;
  final void Function(String)? onFieldSubmitted;
  final TextInputAction textInputAction;
  final bool floatingLabelNever;
  final String? hintText;

  const PinTextField({
    super.key,
    this.labelText,
    required this.controller,
    required this.focusNode,
    this.hintText,
    this.validator,
    this.onFieldSubmitted,
    this.textInputAction = TextInputAction.next,
    this.floatingLabelNever = false,
  });


  @override
  State<PinTextField> createState() => _PinTextFieldState();
}

class _PinTextFieldState extends State<PinTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      keyboardType: TextInputType.number,
      obscureText: _obscureText,
      maxLength: 4,
      decoration: InputDecoration(
        contentPadding: .only(left: 10, right: 8),
        floatingLabelBehavior: FloatingLabelBehavior.never,
        counterText: "",
        labelText: widget.labelText,
        hintText: widget.hintText,
        labelStyle: theme.inputDecorationTheme.labelStyle,
        border: theme.inputDecorationTheme.border,
        suffixIcon: InkWell(
          child: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
            size: 20,
          ),
          onTap: () {
            if (mounted) {
              setState(() {
                _obscureText = !_obscureText;
              });
            }
          },
        ),
      ),
      validator: widget.validator,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onFieldSubmitted,
    );
  }
}

