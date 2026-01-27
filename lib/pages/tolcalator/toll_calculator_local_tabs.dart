import 'package:flutter/material.dart';
import 'package:mtag_flutterapp/widgets/gradient_appbar.dart';
import 'local_tollcalculator.dart';

class TollCalculator extends StatelessWidget {
  const TollCalculator({super.key});

  static const String title = 'Toll Calculator';

  @override
  Widget build(BuildContext context) {
    final AnimationController animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: Navigator.of(context),
    );
    final Animation<double> fadeAnimation = Tween<double>(begin: 0, end: 1)
        .animate(
          CurvedAnimation(parent: animationController, curve: Curves.easeIn),
        );

    // test
    return Scaffold(
      appBar: GradientAppBar(title: const Text(TollCalculator.title)),
      body: TollPlazaTab(
        animationController: animationController,
        fadeAnimation: fadeAnimation,
      ),
    );
  }
}
