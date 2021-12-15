import 'dart:math';
import 'package:flutter/material.dart';

import '../values/values.dart';

import 'customClipper.dart';

class CustomBezierContainer extends StatelessWidget {
  const CustomBezierContainer({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Transform.rotate(
        angle: -pi / 3.2,
        child: ClipPath(
          clipper: ClipPainter(),
          child: Container(
            height: MediaQuery.of(context).size.height * .45,
            width: MediaQuery.of(context).size.width - 25,
            decoration: const BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: const [
                  AppColors.nord3,
                  AppColors.nord0,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
