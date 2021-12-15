import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../values/values.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_button.dart';
import '../widgets/spaces.dart';

class InfoScreen extends StatelessWidget {
  Widget _helpCard({String question, String answer}) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 5,
        horizontal: 10,
      ),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          side: const BorderSide(
            color: AppColors.nord2,
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(30.0),
        ),
        child: ExpansionTile(
          trailing: const Icon(
            Icons.expand_more,
            color: AppColors.nord2,
          ),
          title: Text(
            question,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.nord2,
            ),
          ),
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: Text(
                answer,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.nord2,
                  fontFamily: StringConst.trtRegular,
                  height: 1.3,
                ),
              ),
            ),
            SpaceH10(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: CustomAppBar(
        title: StringConst.faqs.tr,
      ),
      body: Container(
        width: width,
        height: height,
        child: SingleChildScrollView(
          child: Column(
            children: [
              SpaceH12(),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child: CustomButton(
                  height: 50,
                  onPressed: () async {
                    await launch('https://www.youtube.com/watch?v=4Go0qeIhCTE');
                  },
                  title: StringConst.watchDemoVideo.tr,
                ),
              ),
              SpaceH5(),
              _helpCard(
                question: StringConst.whatsIsSimpleLibrary.tr,
                answer: StringConst.answer1.tr,
              ),
              _helpCard(
                question: StringConst.iosVersion.tr,
                answer: StringConst.answer2.tr,
              ),
              _helpCard(
                question: StringConst.whyDoIHaveToRegister.tr,
                answer: StringConst.answer3.tr,
              ),
              _helpCard(
                question: StringConst.isTheAppFree.tr,
                answer: StringConst.answer4.tr,
              ),
              _helpCard(
                question: StringConst.iCantReadBooksIAdded.tr,
                answer: StringConst.answer5.tr,
              ),
              _helpCard(
                question: StringConst.isThereALimit.tr,
                answer: StringConst.answer6.tr,
              ),
              _helpCard(
                question: StringConst.whyThereIsALimit.tr,
                answer: StringConst.answer7.tr,
              ),
              _helpCard(
                question: StringConst.howCanIMakeADonation.tr,
                answer: StringConst.answer8.tr,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
