import 'package:flutter/material.dart';
import 'package:mtag_flutterapp/constants/other_consts.dart';


class PromotionPage extends StatelessWidget {
  const PromotionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text('Promotions'),),
      body: ListView.builder(
      scrollDirection: Axis.vertical,
      itemCount: OtherConsts.promotionsImages.length,
      itemBuilder: (context, index) {
    return GestureDetector(onTap:(){
      //Get.to(()=>StoryViewPage(stories: ['assets/slider/${OtherConsts.promotionsImages[index]}']),)
    },
      child: Container(
      height: 150,
      width: double.infinity,
      margin: const EdgeInsets.all(8),
      child: ClipRRect(
    borderRadius: BorderRadius.circular(8), // Add rounded corners if needed
    child: Image.asset(
      'assets/promotions/${OtherConsts.promotionsImages[index]}',
      fit: BoxFit.fill,
      alignment: Alignment.center, // Focus on center
    ),
      ),
    )
    );
      },
    )

    );
  }
}
  void returnToBottomBar(BuildContext context) {
  
    Navigator.of(context).popUntil((route) => route.isFirst);
    
   
  }

