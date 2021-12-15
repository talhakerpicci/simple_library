import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../values/values.dart';
import '../widgets/custom_button.dart';
import '../widgets/spaces.dart';

class ErrorScreen extends StatelessWidget {
  final Function function;
  ErrorScreen({@required this.function});
  @override
  Widget build(BuildContext context) {
    var widthOfScreen = MediaQuery.of(context).size.width;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 120,
            height: 100,
            child: const Icon(
              FontAwesomeIcons.exclamationTriangle,
              size: 100,
            ),
          ),
          SpaceH20(),
          Text(
            StringConst.anErrorOccuredPleaseCheckConnection.tr,
            textAlign: TextAlign.center,
          ),
          SpaceH10(),
          CustomButton(
            borderRadius: 30,
            onPressed: () => function(),
            height: 35,
            title: StringConst.tryAgain.tr,
            width: widthOfScreen * 0.5,
            textStyle: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
