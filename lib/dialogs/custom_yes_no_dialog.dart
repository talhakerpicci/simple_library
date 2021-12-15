import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../values/values.dart';
import '../widgets/spaces.dart';
import '../widgets/custom_button.dart';

class CustomYesNoDialog extends StatelessWidget {
  final String message;
  final String buttonTitleLeft;
  final String buttonTitleRight;
  final bool leftButtonReturn;
  final bool rightButtonReturn;
  final double widthMultiplyer;
  final TextAlign messageAlignment;
  final Widget header;
  CustomYesNoDialog({
    @required this.message,
    @required this.buttonTitleLeft,
    @required this.buttonTitleRight,
    this.leftButtonReturn = true,
    this.rightButtonReturn = false,
    this.widthMultiplyer = 0.5,
    this.messageAlignment = TextAlign.center,
    this.header,
  });

  dialogContent(BuildContext context, double width, double height) {
    return Container(
      height: 165,
      width: width * widthMultiplyer,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          header == null ? Container() : header,
          Container(
            padding: const EdgeInsets.only(left: 10, right: 10, top: 20, bottom: 10),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: width,
                maxWidth: width,
                minHeight: 60,
                maxHeight: 60,
              ),
              child: AutoSizeText(
                message,
                textAlign: messageAlignment,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xff717D8D),
                ),
              ),
            ),
          ),
          SpaceH10(),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: CustomButton(
                    title: buttonTitleLeft,
                    textStyle: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontFamily: StringConst.trtRegular,
                    ),
                    borderRadius: 5,
                    height: 30,
                    onPressed: () {
                      Get.back(result: leftButtonReturn);
                    },
                    paddingLeft: 10,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomButton(
                    title: buttonTitleRight,
                    textStyle: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontFamily: StringConst.trtRegular,
                    ),
                    borderRadius: 5,
                    height: 30,
                    onPressed: () {
                      Get.back(result: rightButtonReturn);
                    },
                    paddingRight: 10,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var widthOfScreen = MediaQuery.of(context).size.width;
    var heightOfScreen = MediaQuery.of(context).size.height;
    return Dialog(
      elevation: 0.0,
      insetPadding: const EdgeInsets.all(0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: dialogContent(context, widthOfScreen, heightOfScreen),
    );
  }
}
