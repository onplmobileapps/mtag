import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mtag_flutterapp/constants/input_formater.dart';
import 'package:mtag_flutterapp/pages/faqs/controller/delete_account_controller.dart';
import 'package:mtag_flutterapp/widgets/elevated_button.dart';
import 'package:mtag_flutterapp/widgets/textform_widget.dart';

class FaqsScreen extends StatelessWidget {
  FaqsScreen({super.key});
  final _scrollController = ScrollController();
  final _reasontextController = TextEditingController();
  final delAccController = Get.find<DeleteAccountController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FAQ\'s')),
      body: Container(
        decoration: BoxDecoration(color: Theme.of(context).primaryColor),
        child: Container(
          height: MediaQuery.sizeOf(context).height,
          width: MediaQuery.sizeOf(context).width,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    controller: _scrollController,
                    padding: const EdgeInsets.only(left: 16, right: 16, top: 0, bottom: 0),
                    itemCount: faqs['faqs']?.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          dividerColor: Colors.transparent,
                        ),
                        child: ExpansionTile(
                          onExpansionChanged: (value) {
                            if (index == int.parse('${faqs['faqs']?.length}') - (1) && value == true) {
                              _scrollController.animateTo(800,
                                  duration: const Duration(seconds: 1), curve: Curves.linear);
                            }
                          },
                          expandedCrossAxisAlignment: CrossAxisAlignment.start,
                          childrenPadding: EdgeInsets.zero,
                          tilePadding: EdgeInsets.zero,
                          title: Text(
                            maxLines: 2,
                            faqs['faqs']?[index]['question'] ?? '',
                            style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 12),
                          ),
                          children: [
                            Text(
                              faqs['faqs']?[index]['ans'] ?? '',
                              textAlign: TextAlign.justify,
                              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                    letterSpacing: 1,
                                    fontSize: 12,
                                  ),
                            ),
                            index == faqs['faqs']!.length - 1
                                ? ElevatedButton1(
                                    backgroundColor: Theme.of(context).primaryColor,
                                    width: MediaQuery.sizeOf(context).width,
                                    onclick: () {
                                      showCupertinoModalPopup(
                                        context: context,
                                        builder: (_) => CupertinoAlertDialog(
                                          title: Icon(
                                            Icons.warning_outlined,
                                            color: Colors.yellow.shade600,
                                            size: 50,
                                          ),
                                          content: Column(
                                            children: [
                                              const Text(
                                                'If you delete your account we temporarily deactivate your account for next 14 days, within this duration if you login again  we activate your account again, otherwise we delete your account permanently after 14 days.',
                                                textAlign: TextAlign.justify,
                                              ),
                                              SizedBox(
                                                height: 45,
                                                child: Material(
                                                  color: Colors.transparent,
                                                  child: CustomTextField(
                                                    controller: _reasontextController,
                                                    contentPadding: const EdgeInsets.only(top: 0, left: 0),
                                                    hint: 'Why you want to deactivate your account?',
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          actions: [
                                            CupertinoDialogAction(
                                              child: const Text(
                                                'Cancel',
                                                style: TextStyle(color: Colors.redAccent),
                                              ),
                                              onPressed: () => Navigator.of(context).pop(true),
                                            ),
                                            CupertinoDialogAction(
                                              child: const Text(
                                                'Confirm',
                                              ),
                                              onPressed: () async {
                                                Get.back();
                                                await delAccController.deleteAccount(
                                                    comments: _reasontextController.text);
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    text: 'Deactivate Your Account')
                                : Container(),
                            const SizedBox(
                              height: 30,
                            ),
                          ],
                        ),
                      );
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
