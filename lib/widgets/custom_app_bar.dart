import 'package:flutter/material.dart';

import '../values/values.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool centerTitle;
  final List<Widget> actions;
  final Widget bottom;
  final List<Color> colors;
  final double elevation;

  CustomAppBar({
    @required this.title,
    this.centerTitle = false,
    this.actions,
    this.bottom,
    this.elevation = 4.0,
    this.colors = const [
      AppColors.grey1,
      AppColors.grey0,
    ],
  });

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontFamily: StringConst.trtRegular,
        ),
      ),
      elevation: elevation,
      centerTitle: centerTitle,
      actions: actions != null ? actions : [],
      bottom: bottom,
      iconTheme: const IconThemeData(
        color: Colors.white,
      ),
    );
  }
}
