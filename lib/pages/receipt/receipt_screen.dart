import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mtag_flutterapp/theme/app_theme.dart';
import 'package:mtag_flutterapp/widgets/gradient_appbar.dart';
import '../../pages/receipt/controller/receipt_generate_controller.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class ReceiptScreen extends StatelessWidget {
  ReceiptScreen({super.key, this.name});
  final String? name;
  final _screenshotController = ScreenshotController();
  final _receiptController = Get.find<ReceiptController>();
  final bool istravel = Get.arguments ?? false;

  @override
  Widget build(BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    return Obx(() {
      var data = _receiptController.receiptModel.value.data;
      return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: GradientAppBar(
          title: const Text("Recharge/Travel Receipt"),
          actions: [
            IconButton(
              onPressed: () {
                Get.bottomSheet(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                  ),
                  backgroundColor: Theme.of(
                    context,
                  ).bottomSheetTheme.backgroundColor,
                  SafeArea(
                    child: Wrap(
                      children: [
                        ListTile(
                          onTap: () async {
                            try {
                              final box =
                                  context.findRenderObject() as RenderBox?;

                              _screenshotController.capture().then((
                                Uint8List? image,
                              ) async {
                                if (image != null) {
                                  final directory =
                                      await getApplicationDocumentsDirectory();
                                  final imagePath = await File(
                                    '${directory.path}/receipt.png',
                                  ).create();
                                  await imagePath.writeAsBytes(image);

                                  await SharePlus.instance.share(
                                    ShareParams(
                                      files: [XFile(imagePath.path)],
                                      sharePositionOrigin:
                                          box!.localToGlobal(Offset.zero) &
                                          box.size,
                                    ),
                                  );
                                }
                              });
                            } catch (e) {
                              throw Exception(e);
                            }
                          },
                          dense: true,
                          leading: const Icon(Icons.screenshot, size: 30.0),
                          title: Text(
                            'Share as Screenshot',
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                        ),
                        const Divider(endIndent: 10,indent: 10,),
                        ListTile(
                          onTap: () async {
                            final headerImage = pw.MemoryImage(
                              (await rootBundle.load(
                                'assets/h.png',
                              )).buffer.asUint8List(),
                            );
                            final brandImage = pw.MemoryImage(
                              (await rootBundle.load(
                                'assets/mtagbrand.png',
                              )).buffer.asUint8List(),
                            );
                            final footerImage = pw.MemoryImage(
                              (await rootBundle.load(
                                'assets/footer.png',
                              )).buffer.asUint8List(),
                            );
                            final pdf = pw.Document(
                              version: PdfVersion.pdf_1_4,
                            );

                            pdf.addPage(
                              pw.Page(
                                orientation: pw.PageOrientation.portrait,
                                margin: pw.EdgeInsets.zero,
                                build: (pw.Context context1) {
                                  return pw.Column(
                                    mainAxisSize: pw.MainAxisSize.max,
                                    mainAxisAlignment:
                                        pw.MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Image(
                                        headerImage,
                                        height: 20,
                                        fit: pw.BoxFit.fitWidth,
                                      ),
                                      pw.Container(
                                        height: 30,
                                        width: double.infinity,
                                      ),
                                      pw.Center(
                                        child: pw.Image(
                                          brandImage,
                                          height: 120,
                                          width: 200,
                                        ),
                                      ),
                                      pw.Container(
                                        height: 30,
                                        width: double.infinity,
                                      ),
                                      pw.Center(
                                        child: pw.Text(
                                          'Travel Receipt',
                                          style: pw.TextStyle(
                                            color: PdfColor.fromHex('E73B3E'),
                                            fontSize: 25,
                                          ),
                                        ),
                                      ),
                                      pw.SizedBox(height: 40),
                                      pw.Padding(
                                        padding: const pw.EdgeInsets.only(
                                          left: 12,
                                          right: 12,
                                        ),
                                        child: pw.Column(
                                          children: [
                                            pw.Container(
                                              padding: const pw.EdgeInsets.all(
                                                10,
                                              ),
                                              color: PdfColor.fromHex('F5F5F5'),
                                              child: pw.Row(
                                                mainAxisAlignment: pw
                                                    .MainAxisAlignment
                                                    .spaceBetween,
                                                crossAxisAlignment:
                                                    pw.CrossAxisAlignment.start,
                                                children: [
                                                  pw.Text('Amount'),
                                                  pw.Text(
                                                    'PKR ${data?.amount ?? data?.fare ?? ''}/-',
                                                  ),
                                                ],
                                              ),
                                            ),
                                            pw.SizedBox(height: 10),
                                            pw.Container(
                                              padding: const pw.EdgeInsets.all(
                                                10,
                                              ),
                                              color: PdfColor.fromHex('F5F5F5'),
                                              child: pw.Row(
                                                mainAxisAlignment: pw
                                                    .MainAxisAlignment
                                                    .spaceBetween,
                                                crossAxisAlignment:
                                                    pw.CrossAxisAlignment.start,
                                                children: [
                                                  pw.Text('Vehicle Number'),
                                                  pw.Text(
                                                    data?.registration ?? '',
                                                  ),
                                                ],
                                              ),
                                            ),
                                            pw.SizedBox(height: 10),
                                            pw.Container(
                                              padding: const pw.EdgeInsets.all(
                                                10,
                                              ),
                                              color: PdfColor.fromHex('F5F5F5'),
                                              child: pw.Row(
                                                mainAxisAlignment: pw
                                                    .MainAxisAlignment
                                                    .spaceBetween,
                                                crossAxisAlignment:
                                                    pw.CrossAxisAlignment.start,
                                                children: [
                                                  pw.Text('M-TAG ID'),
                                                  pw.Text('${data?.mTagID}'),
                                                ],
                                              ),
                                            ),
                                            pw.SizedBox(height: 10),
                                            pw.Container(
                                              padding: const pw.EdgeInsets.all(
                                                10,
                                              ),
                                              color: PdfColor.fromHex('F5F5F5'),
                                              child: pw.Row(
                                                mainAxisAlignment: pw
                                                    .MainAxisAlignment
                                                    .spaceBetween,
                                                crossAxisAlignment:
                                                    pw.CrossAxisAlignment.start,
                                                children: [
                                                  pw.Text('Date & Time (PKT)'),
                                                  pw.Text(
                                                    data?.rechargeDate ??
                                                        data?.time ??
                                                        '',
                                                  ),
                                                ],
                                              ),
                                            ),
                                            pw.SizedBox(height: 10),
                                            pw.Container(
                                              padding: const pw.EdgeInsets.all(
                                                10,
                                              ),
                                              color: PdfColor.fromHex('F5F5F5'),
                                              child: pw.Row(
                                                mainAxisAlignment: pw
                                                    .MainAxisAlignment
                                                    .spaceBetween,
                                                crossAxisAlignment:
                                                    pw.CrossAxisAlignment.start,
                                                children: [
                                                  pw.Text('Booth Name'),
                                                  pw.Text(
                                                    data?.boothName ?? '',
                                                  ),
                                                ],
                                              ),
                                            ),
                                            pw.SizedBox(height: 10),
                                            pw.Container(
                                              padding: const pw.EdgeInsets.all(
                                                10,
                                              ),
                                              color: PdfColor.fromHex('F5F5F5'),
                                              child: pw.Row(
                                                mainAxisAlignment: pw
                                                    .MainAxisAlignment
                                                    .spaceBetween,
                                                crossAxisAlignment:
                                                    pw.CrossAxisAlignment.start,
                                                children: [
                                                  pw.Text('Entry Station'),
                                                  pw.Text(
                                                    data?.entryStation ?? '',
                                                  ),
                                                ],
                                              ),
                                            ),
                                            pw.SizedBox(height: 10),
                                            pw.Container(
                                              padding: const pw.EdgeInsets.all(
                                                10,
                                              ),
                                              color: PdfColor.fromHex('F5F5F5'),
                                              child: pw.Row(
                                                mainAxisAlignment: pw
                                                    .MainAxisAlignment
                                                    .spaceBetween,
                                                crossAxisAlignment:
                                                    pw.CrossAxisAlignment.start,
                                                children: [
                                                  pw.Text('Exit Station'),
                                                  pw.Text(
                                                    data?.exitStation ?? '',
                                                  ),
                                                ],
                                              ),
                                            ),
                                            pw.SizedBox(height: 10),
                                            pw.Container(
                                              padding: const pw.EdgeInsets.all(
                                                10,
                                              ),
                                              color: PdfColor.fromHex('F5F5F5'),
                                              child: pw.Row(
                                                mainAxisAlignment: pw
                                                    .MainAxisAlignment
                                                    .spaceBetween,
                                                crossAxisAlignment:
                                                    pw.CrossAxisAlignment.start,
                                                children: [
                                                  pw.Text('Reference Number'),
                                                  pw.Text(data?.uID ?? ''),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      pw.SizedBox(height: 20),
                                      pw.Padding(
                                        padding: const pw.EdgeInsets.only(
                                          left: 10,
                                        ),
                                        child: pw.Text(
                                          'Disclaimer',
                                          style: pw.TextStyle(
                                            color: PdfColor.fromHex('E73B3E'),
                                            fontSize: 25,
                                          ),
                                        ),
                                      ),
                                      pw.SizedBox(height: 15),
                                      pw.Padding(
                                        padding: const pw.EdgeInsets.only(
                                          left: 10,
                                          right: 10,
                                        ),
                                        child: pw.Text(
                                          'This document is computer generated and does not require the Registrar\'s signature or the Company\'s stamp in order to be considered valid',
                                        ),
                                      ),
                                      pw.SizedBox(height: 30),
                                      pw.Container(
                                        margin: const pw.EdgeInsets.only(
                                          left: 10,
                                          right: 10,
                                        ),
                                        color: PdfColor.fromHex('E73B3E'),
                                        height: 2,
                                        width: double.infinity,
                                      ),
                                      pw.SizedBox(height: 20),
                                      pw.Spacer(),
                                      pw.Center(
                                        child: pw.Text(
                                          'Powered by One Network',
                                          style: const pw.TextStyle(
                                            fontSize: 20,
                                            letterSpacing: 0,
                                          ),
                                        ),
                                      ),
                                      pw.Spacer(),
                                      pw.Image(footerImage),
                                    ],
                                  );

                                  // Center
                                },
                                pageFormat: const PdfPageFormat(500, 1024),
                              ),
                            );

                            Directory documentDirectory =
                                await getApplicationDocumentsDirectory();
                            String documentPath = documentDirectory.path;

                            File pdfFile = File(
                              '$documentPath/${data?.uID}.pdf',
                            );

                            pdfFile.writeAsBytesSync(await pdf.save());
                            SharePlus.instance.share(
                              ShareParams(
                                files: [XFile(pdfFile.path)],
                                sharePositionOrigin:
                                    box!.localToGlobal(Offset.zero) & box.size,
                              ),
                            );
                          },
                          dense: true,
                          leading: const Icon(Icons.picture_as_pdf, size: 30.0),
                          title: Text(
                            'Share as PDF',
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.share),
            ),
          ],
        ),
        body: Screenshot(
          controller: _screenshotController,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 24),
            decoration: BoxDecoration(
              gradient: Theme.of(context).extension<AppGradients>()!.background,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: ColorScheme.of(context).shadow.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// STATUS ICON
                Center(
                  child: CircleAvatar(
                    backgroundColor: istravel ? Colors.redAccent : Colors.green,
                    radius: 30,
                    child: const Icon(
                      Icons.done_sharp,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                /// AMOUNT
                Center(
                  child: Text(
                    'PKR ${data?.amount ?? data?.fare ?? ''}/-',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 4),

                Center(
                  child: Text(
                    data?.registration ?? '',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),

                const SizedBox(height: 6),

                Center(
                  child: Text(
                    data?.mTagID ?? '',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),

                const SizedBox(height: 20),

                Divider(color: ColorScheme.of(context).outlineVariant),

                const SizedBox(height: 12),

                _infoRow(
                  context,
                  "Date & Time (PKT)",
                  data?.rechargeDate ?? data?.time,
                ),
                _infoRow(context, "Booth Name", data?.boothName),
                _infoRow(context, "Payment Method", data?.paymentOption),

                if (istravel) ...[
                  _infoRow(context, "Entry Station", data?.entryStation),
                  _infoRow(context, "Exit Station", data?.exitStation),
                ],

                _infoRow(context, "Reference No.", data?.uID),
                SizedBox(height: 10),
                Text(
                  'Powered By One Network\u00AE Private Limited',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _infoRow(BuildContext context, String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: ColorScheme.of(context).onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value ?? '',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
