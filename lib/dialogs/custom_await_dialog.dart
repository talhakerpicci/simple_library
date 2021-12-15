import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';

import '../values/values.dart';
import '../widgets/spaces.dart';

class AwaitDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return Future.value(false);
      },
      child: AlertDialog(
        shape: const RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(
            const Radius.circular(10.0),
          ),
        ),
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 60),
        content: Builder(
          builder: (context) {
            double height = MediaQuery.of(context).size.height;
            return Container(
              height: height * 0.1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const SpinKitPouringHourglass(
                    color: AppColors.nord0,
                    size: 55,
                  ),
                  SpaceW20(),
                  Flexible(
                    child: Container(
                      child: Text(
                        StringConst.pleaseWait.tr,
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
