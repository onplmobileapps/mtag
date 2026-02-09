import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DebitCard extends StatelessWidget {
  final String? cardNumber;
  final String? issuer;
  final String? expire;
  final String? fundinMethod;
  final bool isActivity;
  final String? brandName;
  const DebitCard({
    super.key,
    this.cardNumber,
    this.expire,
    this.fundinMethod,
    this.issuer,
    required this.isActivity,
    this.brandName,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 8, right: 4, top: 4),
      padding: const EdgeInsets.only(left: 10, right: 10),
      width: MediaQuery.sizeOf(context).width - 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          end: Alignment.centerRight,
          colors: [
            Color(0xff030303),
            Color(0xff030303),
            Color(0xff2D2F31),
            Color(0xff3C3C3C),
            Color(0xff666666),
          ],
        ),
      ),
      child: IntrinsicHeight(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Card Number',
                  style: Theme.of(context)
                      .textTheme
                      .displayMedium
                      ?.copyWith(color: Colors.white, fontWeight: FontWeight.w900),
                ),
                brandName == 'MASTERCARD'
                    ? Image.asset(
                        'assets/mastercard.png',
                        height: 40,
                        width: 40,
                      )
                    : brandName == 'VISA'
                        ? Image.asset(
                            'assets/visa.png',
                            height: 40,
                            width: 40,
                          )
                :brandName == 'AMEX'
                    ? SvgPicture.asset(
                        'assets/american.svg',
                        height: 40,
                        width: 40,
                      )
                        : const SizedBox(
                            height: 40,
                            width: 40,
                          )
              ],
            ),
            Text(
              cardNumber ?? '',
              style: const TextStyle(fontFamily: 'kredit back', color: Color(0xffFFD700)),
            ),
            Row(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Text(
                      'Issuer',
                      style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.w900),
                    ),
                    Text(
                      issuer ?? '',
                      style: const TextStyle(fontFamily: 'kredit back', color: Color(0xffFFD700)),
                    ),
                  ],
                ),
                const Spacer(
                  flex: 1,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Expires',
                      style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.w900),
                    ),
                    Text(
                      expire ?? '',
                      style: const TextStyle(fontFamily: 'kredit back', color: Color(0xffFFD700)),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Funding Method',
                    style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '$fundinMethod',
                    style: const TextStyle(fontFamily: 'kredit back', color: Color(0xffFFD700)),
                  ),
                ],
              ),
            ),
            if (isActivity == false) ...[
              Center(
                child: Text(
                  '<< Swipe left to delete card',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}

class DebitCardSmall extends StatelessWidget {
  final String? cardNumber;
  final String? issuer;
  final String? expire;
  final String? fundinMethod;
  final bool isActivity;
  final String? brandName;
  const DebitCardSmall({
    super.key,
    this.cardNumber,
    this.expire,
    this.fundinMethod,
    this.issuer,
    required this.isActivity,
    this.brandName,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 8, right: 4, top: 4, bottom: 0),
      padding: const EdgeInsets.only(left: 10, right: 10),
      width: MediaQuery.sizeOf(context).width - 40,
      decoration: BoxDecoration(
        border: Border.all(),
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          end: Alignment.centerRight,
          colors: [
            Color(0xff030303),
            Color(0xff030303),
            Color(0xff2D2F31),
            Color(0xff3C3C3C),
            Color(0xff666666),
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Card Number',
                style: Theme.of(context)
                    .textTheme
                    .displayMedium
                    ?.copyWith(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11),
              ),
              brandName == 'MASTERCARD'
                  ? Image.asset(
                      'assets/mastercard.png',
                      height: 30,
                      width: 30,
                    )
                  : brandName == 'VISA'
                      ? Image.asset(
                          'assets/visa.png',
                          height: 30,
                          width: 30,
                        )
                      : const SizedBox(
                          height: 20,
                          width: 20,
                        )
            ],
          ),
          Text(
            cardNumber ?? '',
            style: const TextStyle(
                fontFamily: 'kredit back',
                color: Color(
                  0xffFFD700,
                ),
                fontSize: 11),
          ),
          Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text(
                    'Issuer',
                    style: TextStyle(
                        fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11),
                  ),
                  Text(
                    issuer ?? '',
                    style: const TextStyle(fontFamily: 'kredit back', color: Color(0xffFFD700)),
                  ),
                ],
              ),
              const Spacer(
                flex: 1,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Expires',
                    style: TextStyle(
                        fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11),
                  ),
                  Text(
                    expire ?? '',
                    style: const TextStyle(
                      fontFamily: 'kredit back',
                      color: Color(0xffFFD700),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Funding Method',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
                Text(
                  '$fundinMethod',
                  style: const TextStyle(fontFamily: 'kredit back', color: Color(0xffFFD700), fontSize: 11),
                ),
              ],
            ),
          ),
          if (isActivity == false) ...[
            Center(
              child: Text(
                '<< Swipe left to delete card',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
              ),
            )
          ]
        ],
      ),
    );
  }
}
