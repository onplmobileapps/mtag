  // ignore_for_file: must_be_immutable

  import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
class BuildPSIDField extends StatefulWidget {
  final ValueListenable<bool> showPSIDField;
void Function()? onCopyPSID;
final TextEditingController ?psidController;
 BuildPSIDField({super.key,required this.showPSIDField,this.onCopyPSID,this.psidController});

  @override
  State<BuildPSIDField> createState() => _BuildPSIDFieldState();
}

class _BuildPSIDFieldState extends State<BuildPSIDField> {
  @override
  Widget build(BuildContext context) {
   log(widget.psidController?.text??'');
 

    return ValueListenableBuilder<bool>(
      valueListenable: widget.showPSIDField,
      builder: (context, isVisible, child) {
        if (!isVisible) return Container();
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: widget.psidController,
                readOnly: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.copy,),
                    onPressed: widget.onCopyPSID,
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