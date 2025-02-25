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
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(16),
            width: isSelected
                ? MediaQuery.sizeOf(context).width / 2.8 // Slightly larger when selected
                : MediaQuery.sizeOf(context).width / 3.2,
            decoration: BoxDecoration(
              color: Theme.of(context).focusColor,
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).disabledColor,
                width: isSelected ? 1.0 : 0.5, // Thicker border when selected
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? Theme.of(context).primaryColor.withAlpha(70)
                      : Colors.black12,
                  blurRadius: isSelected ? 4 : 2,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/mtag_logo.svg',
                  fit: BoxFit.fill,
                  height:  30, // Larger logo when selected
                  colorFilter: isSelected
                      ? ColorFilter.mode(
                          Theme.of(context).primaryColor, BlendMode.srcIn)
                      : null,
                ),
                const SizedBox(height: 8),
                Text(
                  registration,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.red : Colors.redAccent,
                        fontSize: isSelected ? 13 : 12, // Larger text when selected
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  token,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).primaryColor.withAlpha(200),
                        fontSize: isSelected ? 14 : 12,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Center(
            child: AnimatedScale(
              duration: const Duration(milliseconds: 200),
              scale: isSelected ? 1.2 : 1.0, // Slightly larger when selected
              child: CircleAvatar(
                backgroundColor: isSelected ? Colors.green : Colors.grey,
                radius: isSelected ? 10 : 9, // Larger circle when selected
                child: Icon(
                  Icons.done_rounded,
                  size: isSelected ? 16 : 15,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}