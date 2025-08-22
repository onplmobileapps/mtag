import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

Widget buildCarLoaderWidget(BuildContext context, double height) {
  final responsiveHeight = height.clamp(100.0, MediaQuery.sizeOf(context).height * 0.3);

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    child: Container(
      width: MediaQuery.sizeOf(context).width - 20,
      height: responsiveHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(width: 0.3),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: _SpeedingCarAnimation(height: responsiveHeight),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Please wait while we fetch your balance',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Theme.of(context).primaryColorLight,
                fontSize: 12.0,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _SpeedingCarAnimation extends StatefulWidget {
  final double height;
  const _SpeedingCarAnimation({required this.height});

  @override
  State<_SpeedingCarAnimation> createState() => _SpeedingCarAnimationState();
}

class _SpeedingCarAnimationState extends State<_SpeedingCarAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _positionAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _positionAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.85, 1.0, curve: Curves.easeOut),
      ),
    );

    // Start the animation loop
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final carWidth = widget.height / 8;
        final carEndX = constraints.maxWidth - (carWidth * 4.2);

        return SizedBox(
          width: constraints.maxWidth,
          height: widget.height * 0.65,
          child: Stack(
            children: [
              Positioned.fill(
                child: SvgPicture.asset(
                  'assets/demo.svg',
                  fit: BoxFit.contain,
                ),
              ),
              // Moving small car
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final dx = carEndX * _positionAnimation.value;
                  return Positioned(
                    left: dx,
                    bottom: 5,
                    child: Opacity(
                      opacity: _opacityAnimation.value,
                      child: SvgPicture.asset(
                        'assets/car.svg',
                        width: carWidth,
                        height: carWidth,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}