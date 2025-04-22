import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../api/auth_controller.dart';
import '../../base/app_data.dart';

void showChangePinDialog(
  BuildContext context, {
  required Function(String oldPin, String newPin) onSubmit,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => ChangePinDialog(onSubmit: onSubmit),
  );
}

class ChangePinDialog extends StatefulWidget {
  final Function(String oldPin, String newPin) onSubmit;

  const ChangePinDialog({
    super.key,
    required this.onSubmit,
  });

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

  bool _isPinsMatching() {
    return _newPinController.text == _reenterPinController.text;
  }

  bool _obscureOldPin = true;
  bool _obscureNewPin = true;
  bool _obscureReenterPin = true;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(backgroundColor: Theme.of(context).dialogTheme.backgroundColor,surfaceTintColor: Theme.of(context).dialogTheme.surfaceTintColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Change PIN',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 20),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _oldPinController,
                          focusNode: _oldPinFocusNode,
                          keyboardType: TextInputType.number,
                          obscureText: _obscureOldPin,
                          maxLength: 4,
                          decoration: InputDecoration(
                            counterText: "",
                            labelText: 'Old PIN',
                            labelStyle: Theme.of(context)
                                .inputDecorationTheme
                                .labelStyle, // Dynamic label
                            border: Theme.of(context)
                                .inputDecorationTheme
                                .border, // Dynamic border
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureOldPin
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                size: 20,
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary, // Adjust based on theme
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureOldPin = !_obscureOldPin;
                                });
                              },
                            ),
                          ),
                          validator: (value) => value == null || value.isEmpty||value.length<4
                              ? 'Please enter your old PIN'
                              : null,
                        ),
                        SizedBox(height: 12),
                        TextFormField(
  controller: _newPinController,
  focusNode: _newPinFocusNode,
  keyboardType: TextInputType.number,
  obscureText: _obscureNewPin,
  maxLength: 4,
  decoration: InputDecoration(
                            counterText: "",
                            labelText: 'New Pin',
                            labelStyle: Theme.of(context)
                                .inputDecorationTheme
                                .labelStyle, // Dynamic label
                            border: Theme.of(context)
                                .inputDecorationTheme
                                .border, // Dynamic border
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureNewPin
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                size: 20,
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary, // Adjust based on theme
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureNewPin = !_obscureNewPin;
                                });
                              },
                            ),
                          ),
  validator: (value) =>
      value == null || value.isEmpty || value.length < 4
          ? 'Please enter a new PIN'
          : null,
  onFieldSubmitted: (_) {
    FocusScope.of(context).requestFocus(_reenterPinFocusNode);
  },
),

                        SizedBox(height: 12),
                        TextFormField(
  controller: _reenterPinController,
  focusNode: _reenterPinFocusNode,
  keyboardType: TextInputType.number,
  obscureText: _obscureReenterPin,
  maxLength: 4,
  decoration: InputDecoration(
                            counterText: "",
                            labelText: 'Re-Enter New PIN',
                            labelStyle: Theme.of(context)
                                .inputDecorationTheme
                                .labelStyle, // Dynamic label
                            border: Theme.of(context)
                                .inputDecorationTheme
                                .border, // Dynamic border
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureReenterPin
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                size: 20,
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary, // Adjust based on theme
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureReenterPin = !_obscureReenterPin;
                                });
                              },
                            ),
                          ),
  validator: (value) {
    if (value == null || value.isEmpty || value.length < 4) {
      return 'Please re-enter your new PIN';
    } else if (!_isPinsMatching()) {
      return "New Pin & Re-Enter Pin doesn't match";
    }
    return null;
  },
  textInputAction: TextInputAction.done,
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
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
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
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    child: Text(
                      'Submit'.toUpperCase(),
                      style: TextStyle(fontSize: 14),
                    ),
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
    child: Padding(
      padding: const EdgeInsets.all(8.0),
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
