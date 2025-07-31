import 'package:flutter/material.dart';


import 'package:mtag_flutterapp/pages/tolcalator/toll_calculator_cities.dart';

import 'local_tollcalculator.dart';


class TollCalculatorLocalTabs extends StatelessWidget {
  const TollCalculatorLocalTabs({super.key});

  static const String title = 'Toll Calculator';

  @override
  Widget build(BuildContext context) {
    final TabController tabController = TabController(length: 2, vsync: Navigator.of(context));
    final AnimationController animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: Navigator.of(context),
    );
    final Animation<double> fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeIn),
    );

    return Scaffold(
      appBar: AppBar(title: const Text(TollCalculatorLocalTabs.title)),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                TollPlazaTab(
                  animationController: animationController,
                  fadeAnimation: fadeAnimation,
                ),
                CitiesTab(
                  animationController: animationController,
                  fadeAnimation: fadeAnimation,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
