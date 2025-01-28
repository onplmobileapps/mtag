import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void showBreakdownDialog({
  required BuildContext context,
  required double amount,
  required double fee,
  required double remaining,
  required String psid,
 required ValueNotifier<Duration>? inVoicetimerNotifier ,
 // Callback for the Generate PSID button
}) {
  showDialog(barrierDismissible: false,
  useRootNavigator: false,
    context: context,
    builder: (BuildContext context) {
      return PopScope(onPopInvokedWithResult: (didPop, result) {
        
      },
      canPop: false,
        child: Dialog(
          surfaceTintColor: Theme.of(context).dialogTheme.surfaceTintColor,
          backgroundColor: Theme.of(context).dialogBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Payment Details',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('M-Tag Balance'),
                        Text(
                          '$amount',
                          style: Theme.of(context).dialogTheme.contentTextStyle,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Bank Charges'),
                        Text(
                          '-$fee',
                          style: Theme.of(context).dialogTheme.contentTextStyle,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Recharge Amount'),
                        Text(
                          '$remaining',
                          style: Theme.of(context).dialogTheme.contentTextStyle?.copyWith(fontWeight: FontWeight.bold,color: Colors.redAccent),
                        ),
                      ],
                    ),
                     const SizedBox(height: 16),
                    Container(padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8),border: Border.all()),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(psid),
                         
                          InkWell( onTap: () {
                              Clipboard.setData(ClipboardData(text: psid));
                            },
                            child: Icon(Icons.copy, )),
                           
                          
                        ],
                      ),
                    ),
                    SizedBox(height: 10,),
                    ValueListenableBuilder(valueListenable: inVoicetimerNotifier!,builder: (context, remainingTime, child) => 
                    Text(
                          '${remainingTime.inMinutes}:${(remainingTime.inSeconds % 60).toString().padLeft(2, '0')}',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(fontSize: 15, color: Colors.red),
                        ),)
                   
                    
                  ],
                ),
              ),
              // Close Button
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.red,
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
