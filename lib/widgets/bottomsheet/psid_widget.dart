  // ignore_for_file: must_be_immutable

  import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
class BuildPSIDField extends StatelessWidget {
  final ValueListenable<bool> showPSIDField;
void Function()? onCopyPSID;
final TextEditingController ?psidController;
 BuildPSIDField({super.key,required this.showPSIDField,this.onCopyPSID,this.psidController});

  @override
  Widget build(BuildContext context) {
   
 

    return ValueListenableBuilder<bool>(
      valueListenable: showPSIDField,
      builder: (context, isVisible, child) {
        if (!isVisible) return Container();
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: psidController,
                readOnly: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.copy,),
                    onPressed: onCopyPSID,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "*This PSID is valid for 10 minutes only.",
                style: TextStyle(color: Colors.redAccent, fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }}