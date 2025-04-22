import 'package:flutter/material.dart';

class JazzCardWidget extends StatelessWidget {
  final String? jazzcardNumber;
  final String? isActive;
  const JazzCardWidget({super.key, this.isActive, this.jazzcardNumber});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 12, right: 4, top: 0),
      child: IntrinsicHeight(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: MediaQuery.sizeOf(context).width - 45,
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                image: const DecorationImage(
                  image: AssetImage('assets/bg_jazz_card.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Row(
                children: [
                  IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isActive == '1' ? 'Active' : 'Blocked',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 20.0,
                          ),
                        ),
                        const SizedBox(height: 5.0),
                        const Text(
                          'Jazz Cash Number',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 14.0,
                          ),
                        ),
                        Text(
                          '$jazzcardNumber',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      alignment: Alignment.centerRight,
                      child: Image.asset(
                        'assets/jazzcash.png',
                        width: 100.0,
                        height: 100.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
