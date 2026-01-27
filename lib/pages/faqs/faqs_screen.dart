import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mtag_flutterapp/theme/app_theme.dart';
import 'package:mtag_flutterapp/widgets/elevated_button.dart';
import '../../constants/input_formater.dart';
import '../../pages/faqs/controller/delete_account_controller.dart';
import '../../widgets/gradient_appbar.dart';

class FaqsScreen extends StatelessWidget {
  FaqsScreen({super.key});

  final _reasontextController = TextEditingController();
  final delAccController = Get.find<DeleteAccountController>();
  final ScrollController _scrollController = ScrollController(); // scroll controller

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(title: const Text('FAQ\'s')),
      body: ListView.builder(
        controller: _scrollController, // attach scroll controller
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: faqs['faqs']?.length ?? 0,
        itemBuilder: (context, index) {
          final isLast = index == (faqs['faqs']!.length - 1);

          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              gradient: Theme.of(context).extension<AppGradients>()!.background,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                  splashColor: Colors.white24,
                  highlightColor: Colors.white10,
                ),
                child: ExpansionTile(
                  backgroundColor: Colors.transparent,
                  collapsedBackgroundColor: Colors.transparent,
                  tilePadding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  expandedCrossAxisAlignment: CrossAxisAlignment.start,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  collapsedShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  title: Text(
                    faqs['faqs']?[index]['question'] ?? '',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  onExpansionChanged: (expanded) {
                    if (expanded && isLast) {
                      // Scroll to bottom to make last item visible
                      Future.delayed(const Duration(milliseconds: 200), () {
                        _scrollController.animateTo(
                          _scrollController.position.maxScrollExtent,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      });
                    }
                  },
                  children: [
                    Text(
                      faqs['faqs']?[index]['ans'] ?? '',
                      textAlign: TextAlign.justify,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(height: 1.5),
                    ),
                    if (isLast) ...[
                      const SizedBox(height: 20),
                      ElevatedButton1(
                        backgroundColor: Colors.red.shade700,
                        width: double.infinity,
                        onclick: () {
                          showCupertinoModalPopup(
                            context: context,
                            builder: (_) => _deactivateDialog(context),
                          );
                        },
                        icon: const Icon(Icons.block),
                        isShowIcon: true,
                        iconAlignment: .start,
                        text: "Deactivate Your Account",
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _deactivateDialog(BuildContext context) {
    return CupertinoAlertDialog(
      title: const Icon(
        Icons.warning_amber_rounded,
        color: Colors.orange,
        size: 48,
      ),
      content: Column(
        children: [
          const SizedBox(height: 12),
          const Text(
            "Your account will be temporarily deactivated for 14 days. "
            "If you log in during this period, your account will be restored. "
            "Otherwise, it will be permanently deleted.",
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          CupertinoTextField(
            controller: _reasontextController,
            placeholder: "Reason for deactivation",
            padding: const EdgeInsets.all(12),
            maxLines: 1,
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey6,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
      actions: [
        CupertinoDialogAction(
          isDestructiveAction: true,
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        CupertinoDialogAction(
          onPressed: () async {
            Navigator.pop(context);
            await delAccController.deleteAccount(
              comments: _reasontextController.text,
            );
          },
          child: const Text("Confirm"),
        ),
      ],
    );
  }
}

