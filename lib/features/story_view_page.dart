import 'package:flutter/material.dart';

class StoryViewPage extends StatefulWidget {
  final List<String> stories;

  const StoryViewPage({super.key, required this.stories});

  @override
  State<StoryViewPage> createState() => _StoryViewPageState();
}

class _StoryViewPageState extends State<StoryViewPage>
    with TickerProviderStateMixin {
  late final PageController _controller;
  AnimationController? _animationController;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _startProgress();
  }

  void _startProgress() {
    _animationController?.dispose();
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 5))
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _nextStory();
            }
          });

    if (mounted) {
      _animationController!.forward();
    }
  }

  void _nextStory() {
    if (currentIndex >= widget.stories.length - 1) {
      Navigator.pop(context);
      return;
    }

    currentIndex++;
    _controller.nextPage(
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeInCubic,
    );
    setState(() {});
    _startProgress();
  }

  void _previousStory() {
    if (currentIndex <= 0) return;

    currentIndex--;
    _controller.previousPage(
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
    );
    setState(() {});
    _startProgress();
  }

  @override
  void dispose() {
    _animationController?.dispose();
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
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (index) {
              currentIndex = index;
              setState(() {});
              _startProgress();
            },
            itemCount: widget.stories.length,
            itemBuilder: (_, index) {
              return GestureDetector(
                onTapDown: (details) {
                  final width = MediaQuery.of(context).size.width;
                  if (details.globalPosition.dx > width / 2) {
                    _nextStory();
                  } else {
                    _previousStory();
                  }
                },
                onLongPress: () => _animationController?.stop(),
                onLongPressEnd: (_) => _animationController?.forward(),
                child: Image.asset(
                  'assets/slider/${widget.stories[index]}',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              );
            },
          ),

          Positioned(
            top: MediaQuery.of(context).padding.top + 15,
            left: 10,
            right: 10,
            child: Row(
              children: widget.stories.asMap().entries.map((entry) {
                final i = entry.key;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: LinearProgressIndicator(
                      minHeight: 3,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation(Colors.white),
                      value: i < currentIndex
                          ? 1.0
                          : i == currentIndex
                          ? _animationController?.value ?? 0.0
                          : 0.0,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 10,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 32),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
