import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mtag_flutterapp/theme/app_theme.dart';
import '../../controller/home_controller.dart';
import '../../pages/dashboard/model/dashboard_model.dart';
import '../dashboard_widget.dart';
import '../elevated_button.dart';

class ChassisNumberDialog extends StatelessWidget {
  final String registration;
  final String mobileNumber;
  final String tokenNo;
  final String balance;
  final String cnicNumber;
  final String? chassissNo;

  ChassisNumberDialog({
    super.key,
    required this.registration,
    required this.tokenNo,
    required this.balance,
    required this.cnicNumber,
    required this.mobileNumber,
    this.chassissNo,
  });

  final TextEditingController _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();
    final mtag = homeController.dashboradData.value.activeMtags?.firstWhere(
          (element) => element.tokenno == tokenNo,
      orElse: () => ActiveMtags(),
    );
    final vehicleImagePath = getVehicleImage(mtag?.vehicletype ?? 'Car');

    return PopScope(
      canPop: true,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: Theme.of(context).extension<AppGradients>()?.background,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Styled Header Section
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    decoration: BoxDecoration(
                      gradient: Theme.of(context).extension<AppGradients>()?.background,
                    ),
                    child: Row(
                      children: [
                        if (vehicleImagePath.isNotEmpty)
                          Hero(
                            tag: 'vehicle_$tokenNo',
                            child: Image.asset(
                              vehicleImagePath,
                              height: 80,
                              fit: BoxFit.contain,
                            ),
                          ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                registration.toUpperCase(),
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.8,
                                  fontFamily: 'biotifbold',
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  Text(
                                    "M-TAG ID: $tokenNo",
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
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
                  Positioned(
                    top: 6,
                    right: 6,
                    child: IconButton(
                      onPressed: Get.back,
                      icon: const Icon(Icons.close_rounded, size: 18),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.red.shade500,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(28, 28),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      Text(
                        "CHASSIS NUMBER",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _controller..text = chassissNo ?? '',
                        maxLength: 17,
                        textCapitalization: TextCapitalization.characters,
                        style: const TextStyle(
                          letterSpacing: 2.5,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          hintText: "Enter Chassis Number",
                          hintStyle: TextStyle(
                            letterSpacing: 0,
                            color: Colors.grey.shade400,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                          counterText: "",
                          filled: true,
                          fillColor: ColorScheme.of(context).surfaceContainerLow.withValues(alpha: 0.5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: Colors.red.shade400, width: 1),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: Colors.red.shade400, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                          UpperCaseTextFormatter(),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required field';
                          }
                          if (value.length < 10) {
                            return 'Minimum 10 characters required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),
                      ElevatedButton1(
                        width: double.infinity,
                        onclick: () async {
                          final text = _controller.text.trim();
                          if (_formKey.currentState?.validate() ?? false) {
                            Get.back();
                            await Get.find<HomeController>().updateChassisCall(
                              cnicNumber: cnicNumber,
                              mobileNumber: mobileNumber,
                              mtagID: tokenNo,
                              chassisNumber: text,
                            );
                          }
                        },
                        text: "UPDATE",
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
