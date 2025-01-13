// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:mtag_flutterapp/fcm_handeler.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<Offset>? _animation;
  final Offset _offset = const Offset(0.35, 0);
  final _messagingService = MessagingService();
  @override
  void initState() {
    super.initState();
    _messagingService.init(context);


    _animationController = AnimationController(vsync: this, duration: Duration(seconds: 2))
    ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          Get.offAllNamed('/login');
        }
      });
    _animation = Tween<Offset>(begin: Offset.fromDirection(0.0, 0.0), end: _offset).animate(_animationController!);
    _animationController?.forward().whenComplete(() {});
    _animationController?.stop;
  }

  @override
  void dispose() {
    if (mounted) _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: MediaQuery.sizeOf(context).height / 9,
          ),
          Center(
            child: SvgPicture.asset(
              'assets/logolight.svg',
              height: 79,
              width: 179,
            ),
          ),
          SizedBox(
            height: 50,
          ),
          Column(
            children: [
              Stack(
                children: [
                  SvgPicture.asset(
                    'assets/demo.svg',
                    fit: BoxFit.contain,
                    height: MediaQuery.sizeOf(context).height / 2.5,
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: MediaQuery.sizeOf(context).height / 3.5,
                    child: SlideTransition(
                      position: _animation!,
                      child: AnimatedContainer(
                        decoration: BoxDecoration(color: Colors.transparent),
                        alignment: Alignment.topLeft,
                        duration: Duration(seconds: 1),
                        child: Image(
                          fit: BoxFit.contain,
                          image: AssetImage('assets/car.png'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Spacer(),
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 20),
          //   child: ElevatedButton1(
          //     backgroundColor: Theme.of(context).primaryColor,
          //     width: MediaQuery.sizeOf(context).width,
          //     onclick: () {
          //       Get.offAllNamed('/login');
          //     },
          //     text: 'Continue',
          //   ),
          // ),
          SizedBox(
            height: 10,
          ),
          Column(
            children: [
              Text(
                'Powered By One Network\u00AE',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              Text(
                'Version: 4.0.0',
                style: Theme.of(context).textTheme.displaySmall,
              ),
            ],
          ),
          SizedBox(
            height: 35,
          ),
        ],
      ),
    );
  }
}
