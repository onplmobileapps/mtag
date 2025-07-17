import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
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
    return Obx(
      () {
        var data = _receiptController.receiptModel.value.data;
        return Scaffold(resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: const Text("Recharge/Travel Receipt"),
            actions: [
              IconButton(
                  onPressed: () {
                    Get.bottomSheet(
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10))),
                      backgroundColor: Theme.of(context).bottomSheetTheme.backgroundColor,
                      SafeArea(
                        child: Wrap(
                          children: [
                            ListTile(
                              onTap: () async {
                                try {
                                  _screenshotController.capture().then((Uint8List? image) async {
                                    if (image != null) {
                                      final directory = await getApplicationDocumentsDirectory();
                                      final imagePath = await File('${directory.path}/receipt.png').create();
                                      await imagePath.writeAsBytes(image);
                        
                                      await SharePlus.instance.share(ShareParams(files:  [XFile(imagePath.path)]));
                                    }
                                  });
                                } catch (e) {
                                  throw Exception(e);
                                }
                              },
                              dense: true,
                              leading: const Icon(
                                Icons.screenshot,
                                size: 30.0,
                              ),
                              title: Text(
                                'Share as Screenshot',
                                style: Theme.of(context).textTheme.displaySmall,
                              ),
                            ),
                            const Divider(),
                            ListTile(
                              onTap: () async {
                                final headerImage =
                                    pw.MemoryImage((await rootBundle.load('assets/h.png')).buffer.asUint8List());
                                final brandImage = pw.MemoryImage(
                                  (await rootBundle.load('assets/mtagbrand.png')).buffer.asUint8List(),
                                );
                                final footerImage = pw.MemoryImage(
                                  (await rootBundle.load('assets/footer.png')).buffer.asUint8List(),
                                );
                                final pdf = pw.Document(version: PdfVersion.pdf_1_4);
                        
                                pdf.addPage(
                                  pw.Page(
                                    orientation: pw.PageOrientation.portrait,
                                    margin: pw.EdgeInsets.zero,
                                    build: (pw.Context context1) {
                                      return pw.Column(
                                        mainAxisSize: pw.MainAxisSize.max,
                                        mainAxisAlignment: pw.MainAxisAlignment.start,
                                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                                        children: [
                                          pw.Image(headerImage, height: 20, fit: pw.BoxFit.fitWidth),
                                          pw.Container(
                                            height: 30,
                                            width: double.infinity,
                                          ),
                                          pw.Center(child: pw.Image(brandImage, height: 120, width: 200)),
                                          pw.Container(
                                            height: 30,
                                            width: double.infinity,
                                          ),
                                          pw.Center(
                                            child: pw.Text(
                                              'Travel Receipt',
                                              style: pw.TextStyle(
                                                color: PdfColor.fromHex(
                                                  'E73B3E',
                                                ),
                                                fontSize: 25,
                                              ),
                                            ),
                                          ),
                                          pw.SizedBox(height: 40),
                                          pw.Padding(
                                            padding: const pw.EdgeInsets.only(left: 12, right: 12),
                                            child: pw.Column(children: [
                                              pw.Container(
                                                padding: const pw.EdgeInsets.all(10),
                                                color: PdfColor.fromHex('F5F5F5'),
                                                child: pw.Row(
                                                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                                                  children: [
                                                    pw.Text('Amount'),
                                                    pw.Text('PKR ${data?.amount ?? data?.fare ?? ''}/-'),
                                                  ],
                                                ),
                                              ),
                                              pw.SizedBox(height: 10),
                                              pw.Container(
                                                padding: const pw.EdgeInsets.all(10),
                                                color: PdfColor.fromHex('F5F5F5'),
                                                child: pw.Row(
                                                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                                                  children: [
                                                    pw.Text('Vehicle Number'),
                                                    pw.Text(data?.registration ?? ''),
                                                  ],
                                                ),
                                              ),
                                              pw.SizedBox(height: 10),
                                              pw.Container(
                                                padding: const pw.EdgeInsets.all(10),
                                                color: PdfColor.fromHex('F5F5F5'),
                                                child: pw.Row(
                                                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                                                  children: [
                                                    pw.Text('M-TAG ID'),
                                                    pw.Text('${data?.mTagID}'),
                                                  ],
                                                ),
                                              ),
                                              pw.SizedBox(height: 10),
                                              pw.Container(
                                                padding: const pw.EdgeInsets.all(10),
                                                color: PdfColor.fromHex('F5F5F5'),
                                                child: pw.Row(
                                                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                                                  children: [
                                                    pw.Text('Date & Time (PKT)'),
                                                    pw.Text(data?.rechargeDate ?? data?.time ?? ''),
                                                  ],
                                                ),
                                              ),
                                              pw.SizedBox(height: 10),
                                              pw.Container(
                                                padding: const pw.EdgeInsets.all(10),
                                                color: PdfColor.fromHex('F5F5F5'),
                                                child: pw.Row(
                                                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                                                  children: [
                                                    pw.Text('Booth Name'),
                                                    pw.Text(data?.boothName ?? ''),
                                                  ],
                                                ),
                                              ),
                                              pw.SizedBox(height: 10),
                                              pw.Container(
                                                padding: const pw.EdgeInsets.all(10),
                                                color: PdfColor.fromHex('F5F5F5'),
                                                child: pw.Row(
                                                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                                                  children: [
                                                    pw.Text('Entry Station'),
                                                    pw.Text(data?.entryStation ?? ''),
                                                  ],
                                                ),
                                              ),
                                              pw.SizedBox(height: 10),
                                              pw.Container(
                                                padding: const pw.EdgeInsets.all(10),
                                                color: PdfColor.fromHex('F5F5F5'),
                                                child: pw.Row(
                                                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                                                  children: [
                                                    pw.Text('Exit Station'),
                                                    pw.Text(data?.exitStation ?? ''),
                                                  ],
                                                ),
                                              ),
                                              pw.SizedBox(height: 10),
                                              pw.Container(
                                                padding: const pw.EdgeInsets.all(10),
                                                color: PdfColor.fromHex('F5F5F5'),
                                                child: pw.Row(
                                                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                                                  children: [
                                                    pw.Text('Reference Number'),
                                                    pw.Text(data?.uID ?? ''),
                                                  ],
                                                ),
                                              ),
                                            ]),
                                          ),
                                          pw.SizedBox(height: 20),
                                          pw.Padding(
                                            padding: const pw.EdgeInsets.only(
                                              left: 10,
                                            ),
                                            child: pw.Text(
                                              'Disclaimer',
                                              style: pw.TextStyle(color: PdfColor.fromHex('E73B3E'), fontSize: 25),
                                            ),
                                          ),
                                          pw.SizedBox(height: 15),
                                          pw.Padding(
                                            padding: const pw.EdgeInsets.only(left: 10, right: 10),
                                            child: pw.Text(
                                                'This document is computer generated and does not require the Registrar\'s signature or the Company\'s stamp in order to be considered valid'),
                                          ),
                                          pw.SizedBox(height: 30),
                                          pw.Container(
                                              margin: const pw.EdgeInsets.only(left: 10, right: 10),
                                              color: PdfColor.fromHex('E73B3E'),
                                              height: 2,
                                              width: double.infinity),
                                          pw.SizedBox(height: 20),
                                          pw.Spacer(),
                                          pw.Center(
                                            child: pw.Text('Powered by One Network\u00AE',
                                                style: const pw.TextStyle(fontSize: 20, letterSpacing: 0)),
                                          ),
                                          pw.Spacer(),
                                          pw.Image(
                                            footerImage,
                                          ),
                                        ],
                                      );
                        
                                      // Center
                                    },
                                    pageFormat: const PdfPageFormat(500, 1024),
                                  ),
                                );
                        
                                Directory documentDirectory = await getApplicationDocumentsDirectory();
                                String documentPath = documentDirectory.path;
                        
                                File pdfFile = File('$documentPath/${data?.uID}.pdf');
                        
                                pdfFile.writeAsBytesSync(await pdf.save());
                                SharePlus.instance.share(ShareParams(files: [XFile(pdfFile.path)]));
                              },
                              dense: true,
                              leading: const Icon(
                                Icons.picture_as_pdf,
                                size: 30.0,
                              ),
                              title: Text(
                                'Share as PDF',
                                style: Theme.of(context).textTheme.displaySmall,
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.share))
            ],
          ),
          body: Container(
            constraints: const BoxConstraints.expand(),
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            child: Screenshot(
              controller: _screenshotController,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: const BorderRadiusDirectional.only(
                    topEnd: Radius.circular(15),
                    topStart: Radius.circular(15),
                  ),
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 15.0),
                      Image.asset(
                        'assets/mtagbrand.png',
                        height: 50.0,
                      ),
                      const SizedBox(height: 15.0),
                      Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 40.0, left: 20.0, right: 20.0),
                            padding: const EdgeInsets.all(20.0),
                            decoration: BoxDecoration(
                              color: Theme.of(context).focusColor,
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(height: 40.0),
                                Align(
                                  child: Text(
                                    'PKR ${data?.amount ?? data?.fare ?? ''}/-',
                                    style: TextStyle(
                                        fontSize: 25.0, color: Theme.of(context).primaryColor, fontFamily: "Poppins"),
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  data?.registration ?? '',
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(data?.mTagID ?? '',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black)),
                                const SizedBox(height: 10),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Date & Time (PKT)',
                                    style: Theme.of(context).textTheme.titleSmall,
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    data?.rechargeDate ?? data?.time ?? '',
                                    style: TextStyle(
                                        fontSize: 14.0, color: Theme.of(context).primaryColor, fontFamily: "Poppins"),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                ...[
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text('Booth Name', style: Theme.of(context).textTheme.titleSmall),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      data?.boothName ?? '',
                                      style: TextStyle(
                                          fontSize: 14.0, color: Theme.of(context).primaryColor, fontFamily: "Poppins"),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text('Payment Options', style: Theme.of(context).textTheme.titleSmall),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      data?.paymentOption ?? '',
                                      style: TextStyle(
                                          fontSize: 14.0, color: Theme.of(context).primaryColor, fontFamily: "Poppins"),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                ],
                                if (istravel) ...[
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text("Entry Station", style: Theme.of(context).textTheme.titleSmall),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      data?.entryStation ?? '',
                                      style: TextStyle(
                                          fontSize: 14.0, color: Theme.of(context).primaryColor, fontFamily: "Poppins"),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text("Exit Station", style: Theme.of(context).textTheme.titleSmall),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      data?.exitStation ?? '',
                                      style: TextStyle(
                                          fontSize: 14.0, color: Theme.of(context).primaryColor, fontFamily: "Poppins"),
                                    ),
                                  ),
                                ],
                                const SizedBox(
                                  height: 10,
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text('Reference Number', style: Theme.of(context).textTheme.titleSmall),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    data?.uID ?? '',
                                    style: TextStyle(
                                        fontSize: 14.0, color: Theme.of(context).primaryColor, fontFamily: "Poppins"),
                                  ),
                                ),
                              ],
                            ),
                          ),
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
                          //NOTE: ENTRY STATION & EXIT STATIONS ARE FOR TRAVEL RECEIPT HIDE BOTH TEXTVIEWS IN RECHARGE RECEIPT AND CHECK_GREEN.PNG FOR RECHARGE AND CHECK.PNG FOR TRAVEL RECEIPT.
                        ],
                      ),
                      const SizedBox(height: 10.0),
                      Text(
                        'Powered By One Network\u00AE Private Limited',
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
