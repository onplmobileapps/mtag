import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/widgets/elevated_button.dart';
import '../../pages/dashboard/model/dashboard_model.dart' as m;
import '../../pages/mtag/controller/delink_controller.dart';

// ignore: must_be_immutable
class DelinkVehicleDialog extends StatefulWidget {
  final m.ActiveMtags? argument;

  const DelinkVehicleDialog({super.key, required this.argument});

  @override
  State<DelinkVehicleDialog> createState() => _DelinkVehicleDialogState();
}

class _DelinkVehicleDialogState extends State<DelinkVehicleDialog> {
  final dlinkOptionsController = Get.find<DelinkController>();
  final reasonID = RxString("");
  final reasonIndex = RxString("");
  bool isTextFieldVisible = false;
  final _reasonController = TextEditingController();

  // Hardcoded reasons
  final List<Map<String, String>> reasons = [
    {"R_DESC": "I do not own this vehicle", "R_ID": "1"},
    {"R_DESC": "I sold this vehicle", "R_ID": "2"},
    {"R_DESC": "Other", "R_ID": "3"},
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      backgroundColor:
          Theme.of(context).dialogTheme.backgroundColor ?? Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: 400,
        ),
        child: KeyboardAvoidingView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    "De-Link Vehicle",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).primaryColorLight,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    "Are you sure you want to De-Link this vehicle?",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      color: Theme.of(context).primaryColorLight,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Vehicle card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(26),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.white.withAlpha(51),
                        child: Image.asset(
                          'assets/suv.png',
                          width: 24,
                          height: 24,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.argument?.registration ?? '',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                fontFamily: "Poppins",
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  widget.argument?.tokenno ?? '',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontFamily: "Poppins",
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  widget.argument?.balance ?? '',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    fontFamily: "Poppins",
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Reasons
                Text(
                  "Select Reason",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColorLight,
                  ),
                ),
                const SizedBox(height: 8),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: reasons.map((reason) {
                    final isSelected = reasonID.value == reason["R_ID"];
                    return ChoiceChip(
                      label: Text(
                        reason["R_DESC"] ?? '',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: isSelected
                              ? Colors.white
                              : Colors.black.withOpacity(0.7),
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: Theme.of(context).colorScheme.primary,
                      backgroundColor: Colors.grey[200],
                      onSelected: (_) {
                        setState(() {
                          reasonID.value = reason["R_ID"] ?? '';
                          reasonIndex.value = reason["R_DESC"] ?? '';
                          isTextFieldVisible = reason["R_ID"] == "3";

                          // Focus on text field when "Other" is selected
                          if (isTextFieldVisible) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              FocusScope.of(context).requestFocus(FocusNode());
                              // Small delay to ensure UI is built
                              Future.delayed(
                                const Duration(milliseconds: 100),
                                () {
                                  FocusScope.of(
                                    context,
                                  ).requestFocus(FocusNode());
                                },
                              );
                            });
                          }
                        });
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 12),

                // Other Reason TextField
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: TextField(
                    maxLines: 3,
                    controller: _reasonController,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      color: Theme.of(context).primaryColorLight,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Other Reason',
                      hintText: 'Please enter reason for de-linking',
                      labelStyle: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).primaryColorLight,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                  crossFadeState: isTextFieldVisible
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 300),
                ),

                const SizedBox(height: 20),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton1(
                      width: MediaQuery.of(context).size.width * 0.35,
                      onclick: () {
                        Navigator.of(context).pop();
                      },
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.black87,
                      text: "Cancel",
                    ),
                    ElevatedButton1(
                      width: MediaQuery.of(context).size.width * 0.35,
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.black87,
                      onclick: () {
                        if (reasonID.value.isEmpty) {
                          showCupertinoModalPopup(
                            context: context,
                            builder: (_) => CupertinoAlertDialog(
                              content: const Text(
                                "Please select a reason to proceed.",
                                style: TextStyle(fontSize: 14),
                              ),
                              actions: [
                                CupertinoDialogAction(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text(
                                    'OK',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else {
                          Navigator.of(context).pop();
                          dlinkOptionsController.deLinkVehicle(
                            mtagID: widget.argument?.tokenno ?? '',
                            rDesc:
                                "${reasonIndex.value}--${_reasonController.text}",
                            rID: reasonID.value,
                          );
                        }
                      },
                      text: 'De-Link',
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

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }
}

// Custom KeyboardAvoidingView widget
class KeyboardAvoidingView extends StatelessWidget {
  final Widget child;

  const KeyboardAvoidingView({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: child,
        );
      },
    );
  }
}
