import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class MTagCard extends StatelessWidget {
  final int index;
  final String token;
  final String registration;
  final bool isSelected;
  final VoidCallback onTap;
  final double isActive;

  const MTagCard({
    super.key,
    required this.index,
    required this.token,
    required this.registration,
    required this.isSelected,
    required this.onTap,
    required this.isActive,
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

            width: isSelected
                ? MediaQuery.sizeOf(context).width /
                      2.8 // Slightly larger when selected
                : MediaQuery.sizeOf(context).width / 3.2,
            decoration: BoxDecoration(
              color: Theme.of(context).focusColor,
              border: Border.all(
                color: isActive == 8
                    ? Colors.redAccent
                    : isSelected
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
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: .start,
              children: [
                Transform.translate(
                  offset: Offset(65.0, -8),
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 200),
                    scale: isSelected
                        ? 1.2
                        : 1.0, // Slightly larger when selected
                    child: isActive == 8
                        ? CircleAvatar(
                            backgroundColor: Colors.redAccent,
                            radius: 12,
                            child: Icon(
                              Icons.close_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                          )
                        : CircleAvatar(
                            backgroundColor: isSelected
                                ? Colors.green
                                : Colors.grey,
                            radius: isSelected
                                ? 9
                                : 7, // Larger circle when selected
                            child: Icon(
                              Icons.done_rounded,
                              size: isSelected ? 12 : 11,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                Center(
                  child: Column(
                    children: [
                      isActive == 8
                          ? Container(
                              alignment: .center,
                              padding: EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red.withAlpha(77),
                                    blurRadius: 4,
                                    offset: Offset(2, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                'Blacklisted',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            )
                          : SvgPicture.asset(
                              'assets/mtag_logo.svg',
                              fit: BoxFit.fill,
                              height: 30, // Larger logo when selected
                              colorFilter: isSelected
                                  ? ColorFilter.mode(
                                      Theme.of(context).primaryColor,
                                      BlendMode.srcIn,
                                    )
                                  : null,
                            ),
                      const SizedBox(height: 8),
                      Text(
                        registration,
                        style: Theme.of(context).textTheme.displaySmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.red : Colors.redAccent,
                              fontSize: isSelected
                                  ? 13
                                  : 12, // Larger text when selected
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        token,
                        style: Theme.of(context).textTheme.displaySmall
                            ?.copyWith(
                              color: isSelected
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(
                                      context,
                                    ).primaryColor.withAlpha(200),
                              fontSize: isSelected ? 14 : 12,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
