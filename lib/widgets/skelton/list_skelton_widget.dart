import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ListSkeleton extends StatelessWidget {
  final int itemCount;

  const ListSkeleton({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView.builder(
      shrinkWrap: true,
      itemCount: itemCount,
      padding: const EdgeInsets.all(8),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Shimmer.fromColors(
            baseColor: colorScheme.surfaceContainerLowest,
            highlightColor: colorScheme.surface,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              decoration: BoxDecoration(
                color: colorScheme.surface.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Column(
                    children: [
                      ...List.generate(
                        3,
                        (i) => Container(
                          width: i==0? 120:100,
                          height: 10,
                          margin: const EdgeInsets.only(right: 8, bottom: 4),
                          decoration: BoxDecoration(
                            color: colorScheme.onSurface.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // 3 Leading items
                  const Spacer(),
                  Column(children: [...List.generate(
                    2,
                    (i) => Container(
                      width: 50,
                      height: 10,
                      margin: const EdgeInsets.only(left: 8, top: 2, bottom: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.onSurface.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),],)
                  // 2 Trailing items
                  
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
