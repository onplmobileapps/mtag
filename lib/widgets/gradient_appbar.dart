import 'package:flutter/material.dart';


import '../theme/app_theme.dart';

class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget title;
 final List<Widget>? actions;

  const GradientAppBar({
    super.key,
    required this.title,this.actions,

  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(backgroundColor: Colors.transparent,centerTitle: true,
      elevation: 0,actions: actions,
      title: title,titleTextStyle: TextTheme.of(context).titleLarge,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: Theme.of(context).extension<AppGradients>()!.background,
        ),
      ),
     
    );
  }
}