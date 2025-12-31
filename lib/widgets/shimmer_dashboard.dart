import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

Widget buildShimmerEffect(double screenWidth, double screenHeight) {
  final isDarkMode = Get.isDarkMode;

  return SafeArea(
    child: CustomScrollView(shrinkWrap: true,
      slivers: [
       
        SliverToBoxAdapter(
          child: Shimmer.fromColors(
            baseColor: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
            highlightColor: isDarkMode
                ? Colors.grey.shade400
                : Colors.grey.shade100,
            child: Container(
              margin: EdgeInsets.only(left: 16, right: 16),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              height: screenHeight * 0.25,
            ),
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 10,),),
         SliverToBoxAdapter(
          child: Shimmer.fromColors(
            baseColor: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade100,
            highlightColor: isDarkMode
                ? Colors.grey.shade600
                : Colors.grey.shade100,
            child: Container(
              margin: EdgeInsets.only(left: 16, right: 16, bottom: 4),
              height: screenHeight * 0.38,
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(8.0),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: screenWidth * 0.5,
              mainAxisSpacing: 2,
              crossAxisSpacing: 2,
              mainAxisExtent: screenHeight * 0.17,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              return Shimmer.fromColors(
                baseColor: isDarkMode
                    ? Colors.grey.shade700
                    : Colors.grey.shade300,
                highlightColor: isDarkMode
                    ? Colors.grey.shade600
                    : Colors.grey.shade100,
                child: Container(
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? Colors.grey.shade700
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  margin: const EdgeInsets.all(8.0),
                ),
              );
            }, childCount: 4),
          ),
        ),
      ],
    ),
  );
}
