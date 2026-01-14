import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget title;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const GradientAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = false,
    this.onBackPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      title: title,
      actions: actions,
      titleTextStyle: Theme.of(context).textTheme.titleLarge,

      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onBackPressed,
            )
          : null,

      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: Theme.of(context).extension<AppGradients>()!.background,
        ),
      ),
    );
  }
}
