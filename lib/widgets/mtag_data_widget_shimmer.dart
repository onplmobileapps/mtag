import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

Widget buildMtagDataShimmer(BuildContext context, double height) {
  final isDarkMode = Get.isDarkMode;
  return SizedBox(
    width: MediaQuery.sizeOf(context).width,
    child: Shimmer.fromColors(
      baseColor: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
      highlightColor: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade100,
      child: Container(
        width: MediaQuery.sizeOf(context).width,
        height: height,
        margin: const EdgeInsets.only(left: 10, right: 10),
        padding: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(width: 0.3),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const SizedBox(height: 8),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox.shrink(),
                  const SizedBox.shrink(),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(thickness: 0.2, height: 0.7),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox.shrink(),
                      const SizedBox.shrink(),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}