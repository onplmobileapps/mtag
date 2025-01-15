import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ShimmerContainer extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final Color color;

  const ShimmerContainer({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 4.0,
    this.color = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withAlpha(128),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      height: height,
      width: width,
    );
  }
}

class ShimmerCard extends StatelessWidget {
  final double screenHeight;

  const ShimmerCard({super.key, required this.screenHeight});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: screenHeight * 0.35,
      color: Colors.grey[200],
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerContainer(width: 200, height: 10),
                ShimmerContainer(width: 150, height: 10),
                ShimmerContainer(width: 150, height: 10),
                ShimmerContainer(width: 200, height: 10),
                ShimmerContainer(width: 150, height: 10),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShimmerContainer(width: 150, height: 10),
                 
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.add),
                      label: const Text('Recharge'),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.green.shade100),
                        backgroundColor: Colors.green.shade100,
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          
            // Vehicle Image (SVG)
            Flexible(
              child: SvgPicture.asset(
                'assets/f1.svg',
                colorFilter: ColorFilter.mode(
                  Theme.of(context).hintColor.withAlpha(139),
                  BlendMode.srcIn,
                ),
              
              ),
            ),
          ],
        ),
      ),
    );
  }
}
