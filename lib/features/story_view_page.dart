import 'package:flutter/material.dart';

class StoryViewPage extends StatefulWidget {
  final List<String> stories; // image paths or URLs

  const StoryViewPage({super.key, required this.stories});

  @override
  State<StoryViewPage> createState() => _StoryViewPageState();
}

class _StoryViewPageState extends State<StoryViewPage>
    with TickerProviderStateMixin {
  final PageController _controller = PageController();
  late AnimationController _animationController;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadStory();
  }

  void _loadStory() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5), // story duration
    );

    _animationController.forward();
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _nextStory();
      }
    });
  }

  void _nextStory() {
    if (currentIndex < widget.stories.length - 1) {
      setState(() {
        currentIndex++;
      });
      _controller.nextPage(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
      _animationController.dispose();
      _loadStory();
    } else {
      Navigator.pop(context);
    }
  }

  void _previousStory() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
      });
      _controller.previousPage(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
      _animationController.dispose();
      _loadStory();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: widget.stories.length,
            physics: const NeverScrollableScrollPhysics(), // swipe handled manually
            itemBuilder: (_, index) {
              return GestureDetector(
                onTapUp: (details) {
                  final w = MediaQuery.of(context).size.width;
                  if (details.localPosition.dx > w / 2) {
                    _nextStory();
                  } else {
                    _previousStory();
                  }
                },
                child: SizedBox.expand(
                  child: Image.asset(
                    'assets/slider/${widget.stories[index]}',
                    fit: BoxFit.fill,
                  ),
                ),
              );
            },
          ),

          // Top Progress Indicators
          Positioned(
            top: 50,
            left: 8,
            right: 8,
            child: Row(
              children: widget.stories
                  .asMap()
                  .map((i, e) {
                    return MapEntry(
                      i,
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: LinearProgressIndicator(
                            value: i == currentIndex
                                ? _animationController.value
                                : (i < currentIndex ? 1 : 0),
                            backgroundColor: Colors.white24,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white),
                          ),
                        ),
                      ),
                    );
                  })
                  .values
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
