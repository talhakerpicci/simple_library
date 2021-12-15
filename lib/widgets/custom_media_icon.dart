import 'package:flutter/material.dart';

class CustomMediaIcon extends StatelessWidget {
  final Widget icon;
  final Function onTap;
  CustomMediaIcon({
    this.icon,
    this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Container(
              decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  border: Border.all(
                    width: 1.0,
                    color: Colors.white,
                  )),
              child: Center(child: icon),
            ),
          ),
        ),
      ),
    );
  }
}
