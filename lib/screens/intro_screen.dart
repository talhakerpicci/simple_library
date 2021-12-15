import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:intro_slider/slide_object.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../values/values.dart';

import 'welcome_screen.dart';

class IntroScreen extends StatefulWidget {
  @override
  IntroScreenState createState() => IntroScreenState();
}

class IntroScreenState extends State<IntroScreen> {
  List<Slide> slides = [];

  @override
  void initState() {
    super.initState();

    slides.add(
      Slide(
        widgetTitle: Text(
          StringConst.welcomeToSimpleLibrary.tr,
          maxLines: 2,
          style: const TextStyle(
            color: AppColors.nord1,
            fontSize: 22,
          ),
          textAlign: TextAlign.center,
        ),
        description: StringConst.welcomeDescription.tr,
        pathImage: StringConst.bookLoverImg,
        backgroundColor: Colors.white,
        styleTitle: const TextStyle(
          color: AppColors.nord1,
          fontSize: 22,
        ),
        styleDescription: const TextStyle(
          color: AppColors.nord1,
          fontSize: 14,
          height: 1.4,
        ),
      ),
    );
    slides.add(
      Slide(
        widgetTitle: Text(
          StringConst.allBooksInOnePlace.tr,
          maxLines: 2,
          style: const TextStyle(
            color: AppColors.nord1,
            fontSize: 22,
          ),
          textAlign: TextAlign.center,
        ),
        description: StringConst.allBooksInOnePlaceDescription.tr,
        pathImage: StringConst.bookshelvesImg,
        backgroundColor: Colors.white,
        styleTitle: const TextStyle(
          color: AppColors.nord1,
          fontSize: 22,
        ),
        styleDescription: const TextStyle(
          color: AppColors.nord1,
          fontSize: 14,
          height: 1.4,
        ),
      ),
    );
    slides.add(
      Slide(
        widgetTitle: Text(
          StringConst.setGoals.tr,
          maxLines: 2,
          style: const TextStyle(
            color: AppColors.nord1,
            fontSize: 22,
          ),
          textAlign: TextAlign.center,
        ),
        description: StringConst.setGoalsDescription.tr,
        pathImage: StringConst.setGoalsImg,
        backgroundColor: Colors.white,
        styleTitle: const TextStyle(
          color: AppColors.nord1,
          fontSize: 22,
        ),
        styleDescription: const TextStyle(
          color: AppColors.nord1,
          fontSize: 14,
          height: 1.4,
        ),
      ),
    );
    slides.add(
      Slide(
        widgetTitle: Text(
          StringConst.viewYourStats.tr,
          maxLines: 2,
          style: const TextStyle(
            color: AppColors.nord1,
            fontSize: 22,
          ),
          textAlign: TextAlign.center,
        ),
        description: StringConst.viewYourStatsDescription.tr,
        pathImage: StringConst.viewStatsImg,
        backgroundColor: Colors.white,
        styleTitle: const TextStyle(
          color: AppColors.nord1,
          fontSize: 22,
        ),
        styleDescription: const TextStyle(
          color: AppColors.nord1,
          fontSize: 14,
          height: 1.4,
        ),
      ),
    );
    slides.add(
      Slide(
        widgetTitle: Text(
          StringConst.muchMoreToDiscover.tr,
          maxLines: 2,
          style: const TextStyle(
            color: AppColors.nord1,
            fontSize: 22,
          ),
          textAlign: TextAlign.center,
        ),
        description: StringConst.muchMoreToDiscoverDescription.tr,
        pathImage: StringConst.discoveMoreImg,
        backgroundColor: Colors.white,
        styleTitle: const TextStyle(
          color: AppColors.nord1,
          fontSize: 22,
        ),
        styleDescription: const TextStyle(
          color: AppColors.nord1,
          fontSize: 14,
          height: 1.4,
        ),
      ),
    );
  }

  void onDonePress() async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setBool('showSliders', false);

    Get.offAll(() => WelcomeScreen());
  }

  Widget renderDoneBtn() {
    return Text(
      StringConst.getStarted.tr,
      style: const TextStyle(
        color: AppColors.nord1,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget renderSkipBtn() {
    return FittedBox(
      fit: BoxFit.fitWidth,
      child: Text(
        StringConst.skip.tr,
        style: const TextStyle(
          color: AppColors.nord1,
        ),
      ),
    );
  }

  Widget renderNextBtn() {
    return FittedBox(
      fit: BoxFit.fitWidth,
      child: Text(
        StringConst.next.tr,
        style: const TextStyle(
          color: AppColors.nord1,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IntroSlider(
      slides: slides,
      onDonePress: onDonePress,
      hideStatusBar: false,
      renderDoneBtn: renderDoneBtn(),
      renderSkipBtn: renderSkipBtn(),
      renderNextBtn: renderNextBtn(),
    );
  }
}
