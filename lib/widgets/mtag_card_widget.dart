import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class MTagCard extends StatelessWidget {
  final int index;
  final String token;
  final String registration;
  final bool isSelected;
  final VoidCallback onTap;

  const MTagCard({
    super.key,
    required this.index,
    required this.token,
    required this.registration,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).focusColor,
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).disabledColor,
                width: 0.5,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            width: MediaQuery.sizeOf(context).width / 3.2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/mtag_logo.svg',
                  fit: BoxFit.fill,
                ),
                const SizedBox(height: 8),
                Text(
                  registration,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  token,
                  style: Theme.of(context)
                      .textTheme
                      .displaySmall
                      ?.copyWith(color: Theme.of(context).primaryColor),
                ),
              ],
            ),
          ),
        ),
        Center(
          child: CircleAvatar(
            backgroundColor: isSelected ? Colors.green : Colors.grey,
            radius: 9,
            child: const Icon(
              Icons.done_rounded,
              size: 15,
            ),
          ),
        ),
      ],
    );
  }
}