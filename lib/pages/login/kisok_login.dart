import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../constants/input_formater.dart';
// import '../../utils/utils.dart';

class KisokLogin extends StatelessWidget {
  KisokLogin({super.key});

  final _cnicController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _cnicFocusNode = FocusNode();

  Widget _buildInstructions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              // 'How to Recharge / ریچارج کرنے کا طریقہ',
              'Recharge Instructions',

              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          ..._buildInstructionSteps(),
        ],
      ),
    );
  }

  List<Widget> _buildInstructionSteps() {
    List<Map<String, String>> steps = [
      {
        'en': 'Enter 13 Digit CNIC Number',
        'ur': 'قومی شناختی کارڈ نمبر درج کریں'
      },
      {'en': 'Tap Continue', 'ur': 'جاری رکھیں'},
      {'en': 'Select Vehicle', 'ur': 'گاڑی منتخب کریں'},
      {'en': 'Enter Amount', 'ur': 'رقم درج کریں'},
      {'en': 'Choose Payment Method', 'ur': 'ادائیگی کا طریقہ منتخب کریں۔'},
      {
        'en': 'Select Saved Card or Add New Card to Recharge.',
        'ur': 'محفوظ کارڈ منتخب کریں یا ریچارج کے لیے نیا کارڈ شامل کریں۔'
      },
    ];

    return steps.map((step) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: RichText(
          text: TextSpan(
            style:
                TextStyle(fontSize: 24, height: 1.5, color: Colors.redAccent),
            children: [
              TextSpan(text: '${steps.indexOf(step) + 1}. ${step['en']} '),
              // TextSpan(
              //   text: step['ur'],
              //   style: const TextStyle(
              //       color: Colors.black87, fontWeight: FontWeight.w500),
              // ),
            ],
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey[200]!.withAlpha(90)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.12,
                    vertical: 40,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/logolight.svg',
                        height: MediaQuery.of(context).size.width * 0.3,
                      ),
                      const SizedBox(height: 40),
                      Text(
                        'Welcome to M-TAG One Network',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[900],
                          letterSpacing: 1.1,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                      _buildInstructions(),
                      const SizedBox(height: 40),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: Colors.grey[300]!, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.grey.withAlpha(40),
                                      blurRadius: 6)
                                ],
                              ),
                              child: TextFormField(
                                focusNode: _cnicFocusNode,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                keyboardType: TextInputType.number,
                                inputFormatters: [CnicMaskTextInputFormatter()],
                                style: TextStyle(
                                    fontSize: 28,
                                    color: Colors.grey[900],
                                    fontWeight: FontWeight.w500),
                                decoration: InputDecoration(
                                  hintText: 'XXXXX-XXXXXXX-X',
                                  hintStyle: TextStyle(
                                      fontSize: 22, color: Colors.grey[400]),
                                  border: InputBorder.none,
                                  prefixIcon: Icon(Icons.person,
                                      size: 30, color: colorScheme.primary),
                                  labelText: 'Enter 13 Digit CNIC',
                                  labelStyle: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[800]),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty || v.length < 15) {
                                    return 'درست قومی شناختی کارڈ نمبر درج کریں';
                                  }
                                  return null;
                                },
                                controller: _cnicController,
                              ),
                            ),
                            const SizedBox(height: 50),
                            GestureDetector(
                              onTap: () async {
                                if (_formKey.currentState?.validate() ??
                                    false) {
                                  // var release =await DeviceInfo.getDeviceInfo();
                                  // Uncomment and integrate AuthController if needed
                                  // Get.find<AuthController>().login(
                                  //   cnic: _cnicController.text.trim(),
                                  //   metaData: '"Android"__"${release['release']} "__"${release['manufacturer']}""${release['model']} "__"android_id"__"fcmToken"__"3.1.4"',
                                  // );
                                }
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.6,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 22),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                        color:
                                            colorScheme.primary.withAlpha(40),
                                        blurRadius: 8)
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Continue',
                                      style: TextStyle(
                                          fontSize: 28,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(width: 10),
                                    const Icon(Icons.arrow_forward,
                                        color: Colors.white, size: 28),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey[600]!.withAlpha(100),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('v1.0',
                      style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
