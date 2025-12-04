import 'package:flutter/material.dart';
import 'package:mtag_flutterapp/constants/other_consts.dart';

class PromotionPage extends StatelessWidget {
  const PromotionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
  scrollDirection: Axis.vertical,
  itemCount: OtherConsts.sliderImages.length,
  itemBuilder: (context, index) {
    return Container(
      margin: const EdgeInsets.all(8),
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        image: DecorationImage(
          fit: BoxFit.fill,
          image: AssetImage(
            'assets/slider/${OtherConsts.sliderImages[index]}',
          ),
        ),
      ),
    );
  },
)

    );
  }
}
