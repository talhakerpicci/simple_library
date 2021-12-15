import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:argon_buttons_flutter/argon_buttons_flutter.dart';

import '../locator.dart';
import '../services/api.dart';
import '../utils/double_back_to_close_app.dart';
import '../utils/utils.dart';
import '../values/values.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_button.dart';
import '../widgets/spaces.dart';

import 'home_screen_base.dart';

class EmailConfirmationScreen extends StatefulWidget {
  @override
  _EmailConfirmationScreenState createState() => _EmailConfirmationScreenState();
}

class _EmailConfirmationScreenState extends State<EmailConfirmationScreen> {
  bool _isLoading = false;
  Api _api = locator<Api>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _api.sendVerificationEmail();
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: StringConst.confirmYourEmail.tr),
      body: SafeArea(
        child: LoadingOverlay(
          isLoading: _isLoading,
          color: Colors.white,
          opacity: 0.65,
          progressIndicator: const SpinKitCircle(
            color: AppColors.nord1,
            size: 60,
          ),
          child: DoubleBackToCloseApp(
            snackBar: SnackBar(
              content: Text(StringConst.tapOneMoreTimeToGetBack.tr),
              duration: const Duration(seconds: 2),
              backgroundColor: AppColors.nord0,
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SpaceH20(),
                  Image.asset(
                    StringConst.mailSent,
                    width: width,
                    height: 130,
                  ),
                  SpaceH20(),
                  Center(
                    child: Text(
                      StringConst.oneLastStep.tr,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SpaceH12(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      children: <Widget>[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            StringConst.yourAccountHasBeenCreated.tr,
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              fontFamily: StringConst.trtRegular,
                            ),
                          ),
                        ),
                        SpaceH12(),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            StringConst.youWillSoonReceiveEmail.tr,
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              fontFamily: StringConst.trtRegular,
                            ),
                          ),
                        ),
                        SpaceH12(),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            StringConst.toVerifyEmail.tr,
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              fontFamily: StringConst.trtRegular,
                            ),
                          ),
                        ),
                        SpaceH12(),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            StringConst.afterVerification.tr,
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              fontFamily: StringConst.trtRegular,
                            ),
                          ),
                        ),
                        SpaceH12(),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            StringConst.ifYouDidNotReceive.tr,
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              fontFamily: StringConst.trtRegular,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SpaceH24(),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10, right: 5),
                          child: ArgonTimerButton(
                            initialTimer: 180,
                            height: 40,
                            width: MediaQuery.of(context).size.width,
                            borderRadius: 5.0,
                            roundLoadingShape: false,
                            child: Ink(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: const <Color>[
                                    AppColors.nord3,
                                    AppColors.nord0,
                                  ],
                                ),
                                borderRadius: const BorderRadius.all(
                                  const Radius.circular(5),
                                ),
                              ),
                              child: Container(
                                constraints: const BoxConstraints(minWidth: 88.0, minHeight: 36.0),
                                alignment: Alignment.center,
                                child: Text(
                                  StringConst.resendEmail.tr,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            loader: (timeLeft) {
                              return Ink(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: const <Color>[
                                      AppColors.nord3,
                                      AppColors.nord0,
                                    ],
                                  ),
                                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                                ),
                                child: Container(
                                  constraints: const BoxConstraints(minWidth: 88.0, minHeight: 36.0),
                                  alignment: Alignment.center,
                                  child: Text(
                                    "${StringConst.wait.tr} | $timeLeft",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            },
                            onTap: (startTimer, btnState) async {
                              if (btnState != ButtonState.Busy) {
                                setState(() {
                                  _isLoading = true;
                                });
                                try {
                                  await _api.sendVerificationEmail();
                                  if (btnState == ButtonState.Idle) {
                                    startTimer(120);
                                  }
                                  Utils.showFlushInfo(context, StringConst.newEmailSent.tr);
                                } catch (e) {
                                  Utils.showFlushError(context, StringConst.failedToSendEmail.tr);
                                }
                                setState(() {
                                  _isLoading = false;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 5, right: 10),
                          child: CustomButton(
                            height: 40,
                            title: StringConst.continueTo.tr,
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.white,
                            ),
                            borderRadius: 5,
                            onPressed: () async {
                              setState(() {
                                _isLoading = true;
                              });
                              await _api.reloadUser();
                              setState(() {
                                _isLoading = false;
                              });
                              if (_api.isUserVerified()) {
                                Get.offAll(() => HomeScreenBase());
                              } else {
                                Utils.showFlushError(context, StringConst.pleaseVerifyToContinue.tr);
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  SpaceH18(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
