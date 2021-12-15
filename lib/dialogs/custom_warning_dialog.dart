import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../values/values.dart';
import '../widgets/spaces.dart';

class WarningDialog extends StatelessWidget {
  final String header;
  final String message;
  final double height;
  WarningDialog({
    this.header,
    this.message,
    this.height = 200,
  });
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
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), color: Colors.white),
            padding: const EdgeInsets.fromLTRB(20, 70, 20, 20),
            child: Column(
              children: [
                Text(
                  header,
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                SpaceH12(),
                Text(
                  message,
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
                color: Colors.white,
                child: const Icon(
                  Icons.error,
                  color: Colors.red,
                  size: 90,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            child: Row(
              children: [
                TextButton(
                  child: Text(
                    StringConst.cancel.tr,
                    style: const TextStyle(color: Colors.red, fontSize: 14.0),
                  ),
                  onPressed: () {
                    Get.back(result: false);
                  },
                ),
                TextButton(
                  child: Text(
                    StringConst.proceed.tr,
                    style: const TextStyle(color: AppColors.nord0, fontSize: 14.0),
                  ),
                  onPressed: () {
                    Get.back(result: true);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
