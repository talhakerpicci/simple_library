import 'package:flutter/material.dart';

import '../values/values.dart';

class CustomFloationgActionButton extends StatelessWidget {
  final Function onPressed;
  final Icon icon;
  final bool mini;
  CustomFloationgActionButton({this.onPressed, this.icon = const Icon(Icons.add), this.mini = false});
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: AppColors.nord2,
      splashColor: AppColors.grey3,
      child: icon,
      onPressed: onPressed,
      mini: mini,
    );
  }
}
