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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      surfaceTintColor: Theme.of(context).dialogTheme.surfaceTintColor,
      backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Text(
                "De-Link Vehicle",
                style: Theme.of(context).dialogTheme.titleTextStyle,
              ),
            ),
            SizedBox(height: MediaQuery.sizeOf(context).height / 80),
            Text(
              "Are you sure to delete?",
              style: Theme.of(context).dialogTheme.titleTextStyle,
            ),
            SizedBox(height: MediaQuery.sizeOf(context).height / 80),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColorDark,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Image.asset(
                      'assets/suv.png',
                      width: 30,
                      height: 30,
                      color: Colors.white,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.argument?.registration ?? '',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: "Poppins",
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Text(
                              widget.argument?.tokenno ?? '',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontFamily: "Poppins",
                              ),
                            ),
                            const Spacer(),
                            Text(
                              widget.argument?.balance ?? '',
                              style: const TextStyle(
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
            const SizedBox(height: 5),
            Obx(() {
              return dlinkOptionsController.dlinkOptionsModel.value.data == null
                  ? Container()
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: dlinkOptionsController
                          .dlinkOptionsModel
                          .value
                          .data!
                          .map((reason) {
                            bool isSelected = reasonID.value == '${reason.rID}';
                            return GestureDetector(
                              onTap: () {
                                reasonID.value = '${reason.rID}';
                                reasonIndex.value = reason.rDESC ?? '';
                                isTextFieldVisible =
                                    reason ==
                                    dlinkOptionsController
                                        .dlinkOptionsModel
                                        .value
                                        .data
                                        ?.last;
                                if (mounted) {
                                  setState(() {});
                                }
                              },
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: isSelected
                                      ? Theme.of(context).hintColor
                                      : Colors.transparent,
                                ),
                                child: ListTile(
                                  title: Text(
                                    reason.rDESC ?? '',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.displayMedium,
                                  ),
                                ),
                              ),
                            );
                          })
                          .toList(),
                    );
            }),
            const SizedBox(height: 10),
            if (isTextFieldVisible)
              Flexible(
                child: TextField(
                  maxLines: null,
                  controller: _reasonController,
                  style: Theme.of(context).textTheme.displaySmall,
                  decoration: InputDecoration(
                    labelText: 'Reason',
                    labelStyle: Theme.of(context).textTheme.labelSmall,
                    hintText: 'Please enter reason of De-Linking Vehicle',
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
            const SizedBox(height: 10.0),
            Flexible(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton1(
                    width: 120,
                    onclick: () {
                      Navigator.of(context).pop();
                    },
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    text: "Cancel",
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton1(
                    width: 120,
                    onclick: () {
                      //validation
                      if (reasonID.value.isEmpty) {
                        showCupertinoModalPopup(
                          context: Get.context!,
                          builder: (_) => CupertinoAlertDialog(
                            content: const Text(
                              "Please select a reason to proceed.",
                            ),
                            actions: [
                              CupertinoDialogAction(
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Ok'),
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
                    text: 'De-link',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _reasonController.dispose();
  }
}
