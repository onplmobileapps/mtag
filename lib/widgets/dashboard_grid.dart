import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DashboardGridItem {
  final String? title;
  final String? image;
  final String? routeName;

  DashboardGridItem({this.title, this.image, this.routeName});
}

class DashboardGrid extends StatelessWidget {
  final List<DashboardGridItem> items;
  final double maxCrossAxisExtent;
  final double mainAxisExtent;
  final double spacing;
  final Color itemColor;
  final void Function(DashboardGridItem item, int index)? onItemTap;

  const DashboardGrid({
    super.key,
    required this.items,
    required this.maxCrossAxisExtent,
    required this.mainAxisExtent,
    this.spacing = 10,
    this.itemColor = Colors.blue,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.all(spacing),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: maxCrossAxisExtent,
          mainAxisSpacing: spacing,
          crossAxisSpacing: spacing,
          mainAxisExtent: mainAxisExtent,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final item = items[index];
          return InkWell(
            onTap: () => onItemTap?.call(item, index),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: itemColor,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (item.image != null)
                    SvgPicture.asset(
                      item.image!,
                      width: maxCrossAxisExtent * 0.2,
                      height: mainAxisExtent * 0.5,
                    ),
                  const SizedBox(height: 8),
                  if (item.title != null)
                    Text(
                      item.title!,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.white,
                        fontSize: maxCrossAxisExtent * 0.08,
                      ),
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            ),
          );
        }, childCount: items.length),
      ),
    );
  }
}
