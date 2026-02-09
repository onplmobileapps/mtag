import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mtag_flutterapp/constants/other_consts.dart';

class StoryViewPage extends StatefulWidget {
  final List<int> storiesIndex;

  const StoryViewPage({super.key, required this.storiesIndex});

  @override
  State<StoryViewPage> createState() => _StoryViewPageState();
}

class _StoryViewPageState extends State<StoryViewPage>
    with TickerProviderStateMixin {
  late final PageController _pageController;
  late AnimationController _progressController;
  int _currentIndex = 0;
  bool _isDisposed = false;
  bool _isClosing = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..addStatusListener(_handleProgressStatus);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed && mounted) {
        _startProgress();
      }
    });
  }

  void _handleProgressStatus(AnimationStatus status) {
    if (_isDisposed || !mounted) return;
    if (status == AnimationStatus.completed) {
      _goToNextStory();
    }
  }

  void _startProgress() {
    if (_isDisposed || !mounted) return;
    _progressController.reset();
    _progressController.forward();
  }

  Future<void> _goToNextStory() async {
    if (_isDisposed || !mounted || _isClosing) return;

    if (_currentIndex >= widget.storiesIndex.length - 1) {
      await _closeStoryView();
      return;
    }

    _currentIndex++;
    await _pageController.animateToPage(
      _currentIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    if (mounted) {
      _startProgress();
    }
  }

  Future<void> _goToPreviousStory() async {
    if (_isDisposed || !mounted || _isClosing || _currentIndex <= 0) return;

    _currentIndex--;
    await _pageController.animateToPage(
      _currentIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    if (mounted) {
      _startProgress();
    }
  }

  void _onPageChanged(int index) {
    if (_isDisposed || !mounted) return;
    setState(() {
      _currentIndex = index;
    });
    _startProgress();
  }

  void _onTapDown(TapDownDetails details) {
    if (_isDisposed || !mounted || _isClosing) return;
    final width = MediaQuery.of(context).size.width;
    if (details.globalPosition.dx > width / 2) {
      _goToNextStory();
    } else {
      _goToPreviousStory();
    }
  }

  Future<void> _closeStoryView() async {
    if (_isClosing || _isDisposed || !mounted) return;

    _isClosing = true;
    _progressController.stop();

    await Future.delayed(const Duration(milliseconds: 50));

    if (mounted) {
      // Go back to home
      Get.back();
      // If you want to go to a specific route:
      // Get.offAllNamed('/home');
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _isClosing = true;
    _progressController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragStart: (details) {
        if (details.globalPosition.dx < 20) {}
      },
      onHorizontalDragUpdate: (details) {
        // Block horizontal drag updates
      },
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            _buildStoryContent(),
            _buildProgressIndicators(),
            _buildCloseButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryContent() {
    return PageView.builder(
      padEnds: false,
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      onPageChanged: _onPageChanged,
      itemCount: widget.storiesIndex.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTapDown: _onTapDown,
          child: Container(
            color: Colors.black,
            child: Image.asset(
              "assets/slider/${OtherConsts.sliderImages[widget.storiesIndex[index]]}",
              fit: BoxFit.cover,
              // Scaling down during decoding reduces GPU memory pressure and prevents
              // "Failed to submit image decoding command buffer" errors.
              cacheWidth: 1080,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(
                    Icons.broken_image,
                    color: Colors.white,
                    size: 50,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressIndicators() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 8,
      right: 8,
      child: AnimatedBuilder(
        animation: _progressController,
        builder: (context, child) {
          return Row(
            children: List.generate(widget.storiesIndex.length, (index) {
              final isCurrent = index == _currentIndex;
              final isCompleted = index < _currentIndex;

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: LinearProgressIndicator(
                    minHeight: 2,
                    borderRadius: BorderRadius.circular(1),
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                    value: isCompleted
                        ? 1.0
                        : (isCurrent ? _progressController.value : 0.0),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }

  Widget _buildCloseButton() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      right: 8,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _closeStoryView,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.black26,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.close, color: Colors.white, size: 24),
        ),
      ),
    );
  }
}
