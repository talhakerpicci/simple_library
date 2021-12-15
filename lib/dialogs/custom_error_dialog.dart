import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../values/values.dart';

class ErrorDialog extends StatelessWidget {
  final String message;
  final double height;
  ErrorDialog(this.message, {this.height = 200});
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
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), color: Colors.white),
            padding: const EdgeInsets.fromLTRB(20, 70, 20, 20),
            child: Text(
              message,
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
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
            right: 10,
            bottom: 0,
            child: TextButton(
              child: Text(
                StringConst.close.tr,
                style: const TextStyle(color: Colors.red, fontSize: 14.0),
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
