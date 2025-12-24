import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mtag_flutterapp/constants/other_consts.dart';
import 'package:mtag_flutterapp/features/story_view_page.dart';

class PromotionPage extends StatelessWidget {
  const PromotionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text('Promotions'),),
      body: ListView.builder(
  scrollDirection: Axis.vertical,
  itemCount: OtherConsts.sliderImages.length,
  itemBuilder: (context, index) {
    return GestureDetector(onTap:()=>Get.to(()=>StoryViewPage(stories: ['assets/slider/${OtherConsts.sliderImages[index]}']),),
      child: Container(height: 150,width: double.infinity,
        margin: const EdgeInsets.all(8),
     
       child: ClipRRect(child: Image.asset('assets/slider/${OtherConsts.sliderImages[index]}',fit: .contain,),),
        
        
      ),
    );
  },
)

    );
  }
}
