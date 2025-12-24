import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../../../constants/call_helper.dart';

Future showCustomDialog({bool? isError, String? message, BuildContext? context}) {
  return showDialog(
      barrierDismissible: false,
      context: context!,
      builder: (_) => AlertDialog(
            backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
            contentPadding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Customer Support',
                ),
                InkWell(
                  onTap: () {
                    Get.back();
                  },
                  child: const Icon(
                    Icons.close,
                    size: 20,
                  ),
                )
              ],
            ),
            content: Padding(
              padding: const EdgeInsets.only(left: 18, right: 16, top: 16, bottom: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    enableFeedback: true,
                    onTap: () {
                      CallWhatsappUtil.openWhatsAppChat();
                      Get.back();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Theme.of(context).disabledColor,
                      ),
                      child: Row(
                        children: [
                          Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                              child: Image.asset(
                                'assets/whatsapp.png',
                                height: 40,
                                width: 40,
                                fit: BoxFit.fill,
                              )),
                          const Spacer(),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Chat Now',
                                style: Theme.of(context).textTheme.displayMedium,
                              ),
                              const Text(
                                'Start a chat with our\nSupport team.',
                                maxLines: 2,
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  InkWell(
                    enableFeedback: true,
                    onTap: () {
                      CallWhatsappUtil.openCall1313();
                      Get.back();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Theme.of(context).disabledColor,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                            child: SvgPicture.asset(
                              'assets/helpline.svg',
                              fit: BoxFit.fill,
                            ),
                          ),
                          const Spacer(),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Call Helpline',
                                style: Theme.of(context).textTheme.displayMedium,
                              ),
                              const Text(
                                'Speak to the team for\nassistance.',
                                maxLines: 2,
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ));
}
