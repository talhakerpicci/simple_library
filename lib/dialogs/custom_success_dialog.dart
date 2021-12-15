import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/spaces.dart';
import '../values/values.dart';

class SuccessDialog extends StatelessWidget {
  final String message;
  final double height;
  SuccessDialog(this.message, {this.height = 240});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            height: height,
            width: 300,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), color: Colors.white),
            padding: const EdgeInsets.fromLTRB(20, 70, 20, 20),
            child: Column(
              children: [
                SpaceH12(),
                Text(
                  message,
                  style: const TextStyle(fontSize: 22),
                  textAlign: TextAlign.center,
                ),
                SpaceH12(),
                Text(
                  StringConst.yourAccHasBeenUpgraded.tr,
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: StringConst.trtRegular,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Positioned(
            top: -25,
            child: ClipOval(
              child: Container(
                color: Colors.green[600],
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 90,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            child: TextButton(
              child: Text(
                StringConst.close.tr,
                style: TextStyle(
                  color: Colors.green[700],
                  fontSize: 14.0,
                ),
              ),
              onPressed: () {
                Get.back();
              },
            ),
          ),
        ],
      ),
    );
  }
}
