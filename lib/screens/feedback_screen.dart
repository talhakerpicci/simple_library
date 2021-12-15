import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';

import '../values/values.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_button.dart';
import '../widgets/spaces.dart';

class FeedbackScreen extends StatefulWidget {
  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: StringConst.feedback.tr),
      body: SafeArea(
        child: LoadingOverlay(
          isLoading: _isLoading,
          color: Colors.white,
          opacity: 0.65,
          progressIndicator: const SpinKitCircle(
            color: AppColors.nord1,
            size: 60,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SpaceH20(),
                Image.asset(
                  StringConst.itsMe,
                  width: width,
                  height: 240,
                ),
                SpaceH20(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    StringConst.thanksForConsideringFeedback.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: StringConst.trtRegular,
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                SpaceH30(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: CustomButton(
                    height: 40,
                    title: StringConst.sendFeedback.tr,
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                    borderRadius: 5,
                    onPressed: () async {
                      final Uri _emailLaunchUri = Uri(
                        scheme: 'mailto',
                        path: 'simple.library.app@gmail.com',
                        queryParameters: {
                          'subject': StringConst.customTranslation(
                            key: StringConst.feedbackAboutSimpleLibrary,
                          ),
                        },
                      );
                      await launch(_emailLaunchUri.toString().replaceAll('+', ' '));
                    },
                  ),
                ),
                SpaceH18(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
