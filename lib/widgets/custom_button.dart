import 'package:flutter/material.dart';

import '../values/values.dart';

class CustomButton extends StatelessWidget {
  final String title;
  final double width;
  final double height;
  final double paddingRight;
  final double paddingLeft;
  final Function onPressed;
  final TextStyle textStyle;
  final double borderRadius;
  CustomButton({
    this.title,
    this.width,
    this.height,
    this.paddingRight = 0,
    this.paddingLeft = 0,
    this.onPressed,
    this.textStyle,
    this.borderRadius = 80,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: EdgeInsets.only(left: paddingLeft, right: paddingRight),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
          ),
          padding: MaterialStateProperty.all(
            const EdgeInsets.all(0.0),
          ),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const <Color>[
                AppColors.nord3,
                AppColors.nord0,
              ],
            ),
            borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
          ),
          child: Container(
            constraints: const BoxConstraints(minWidth: 88.0, minHeight: 36.0),
            padding: EdgeInsets.symmetric(
              horizontal: 10,
            ),
            alignment: Alignment.center,
            child: FittedBox(
              fit: BoxFit.fitWidth,
              child: Text(
                title,
                style: textStyle != null
                    ? textStyle
                    : const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
