import 'package:flutter/material.dart';

import '../../constants/other_consts.dart';
import '../story_view_page.dart';

class SliderSection extends StatelessWidget {
  const SliderSection({super.key});

  static final ValueNotifier<int> _currentIndex = ValueNotifier<int>(0);

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 5),
          Text(
            'Tap to see what\'s new',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 5),
          Column(
            children: [
              SizedBox(
                height: 150,
                child: NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification is ScrollUpdateNotification) {
                      const itemWidth = 158;
                      final index = (notification.metrics.pixels / itemWidth)
                          .round();
                      if (index >= 0 && index < OtherConsts.thumbnails.length) {
                        // Only update if index actually changed
                        if (_currentIndex.value != index) {
                          _currentIndex.value = index;
                        }
                      }
                    }
                    return false;
                  },
                  child: ListView.separated(
                    padding: .zero,
                    scrollDirection: Axis.horizontal,
                    itemCount: OtherConsts.thumbnails.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      return SliderItem(imageIndex: index);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),

              ValueListenableBuilder<int>(
                valueListenable: _currentIndex,
                builder: (context, currentIndex, child) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(OtherConsts.thumbnails.length - 1, (
                      index,
                    ) {
                      bool isActive =
                          currentIndex == index ||
                          (index == OtherConsts.thumbnails.length - 2 &&
                              currentIndex ==
                                  OtherConsts.thumbnails.length - 1);

                      return Container(
                        decoration: BoxDecoration(
                          color: isActive
                              ? Theme.of(context).colorScheme.onSurface
                              : Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        margin: const EdgeInsets.all(2),
                        height: 5,
                        width: isActive ? 15 : 5,
                      );
                    }),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
class SliderItem extends StatelessWidget {
  final int imageIndex;

  const SliderItem({super.key, required this.imageIndex});

  @override
  Widget build(BuildContext context) {
    final imageName = OtherConsts.thumbnails[imageIndex];
    final imageUrl = 'assets/thumbnail/$imageName';

    return GestureDetector(
      onTap: () {
        showDialog(
          barrierDismissible: false,
          useRootNavigator: false,
          context: context,
          builder: (_) => Dialog.fullscreen(
            backgroundColor: Colors.transparent,
            child: StoryViewPage(storiesIndex: [imageIndex]),
          ),
        );
      },
      child: Container(
        margin: .all(1),
        height: 150,
        width: 150,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(color: Colors.grey, blurRadius: 4, blurStyle: .outer),
          ],
          borderRadius: BorderRadius.circular(8),

          image: DecorationImage(image: AssetImage(imageUrl), fit: BoxFit.fill),
        ),
      ),
    );
  }
}