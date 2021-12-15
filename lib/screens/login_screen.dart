import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:loading_overlay/loading_overlay.dart';

import '../widgets/custom_entry_field.dart';
import '../locator.dart';
import '../services/api.dart';
import '../utils/utils.dart';
import '../values/values.dart';
import '../widgets/custom_bezier_container.dart';
import '../widgets/custom_button.dart';
import '../widgets/spaces.dart';

import 'email_confirmation_screen.dart';
import 'home_screen_base.dart';
import 'sign_up_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  Api _api = locator<Api>();
  bool _isLoading = false;
  String _email = '';
  String _password = '';

  final _form = GlobalKey<FormState>();

  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _emailController.value = TextEditingValue(text: _email, selection: _emailController.selection);
    _passwordController.value = TextEditingValue(text: _password, selection: _passwordController.selection);
  }

  void onSubmit() async {
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    }

    Utils.unFocus();

    setState(() {
      _isLoading = true;
    });

    try {
      var result = await _api.signInUser(
        email: _email,
        password: _password,
      );
      if (result.error != null) {
        String errorMessage;
        switch (result.error.code) {
          case 'invalid-email':
            errorMessage = StringConst.invalidEmail.tr;
            break;
          case 'user-not-found':
            errorMessage = StringConst.noUserFound.tr;
            break;
          case 'wrong-password':
            errorMessage = StringConst.wrongPassword.tr;
            break;
          case 'user-disabled':
            errorMessage = StringConst.accountDisabled.tr;
            break;
          default:
            errorMessage = StringConst.failedToLogin.tr;
            break;
        }
        Utils.showFlushError(context, errorMessage);
      } else {
        if (_api.isUserVerified()) {
          Get.offAll(() => HomeScreenBase());
        } else {
          Get.off(() => EmailConfirmationScreen());
        }
      }
    } catch (e) {
      Utils.showFlushError(context, StringConst.failedToLogin.tr);
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<bool> showEmailInputDialog({BuildContext context, double width, double height}) async {
    bool isLoading = false;
    String forgotEmail = '';

    TextEditingController emailController = TextEditingController();
    emailController.value = TextEditingValue(text: forgotEmail, selection: emailController.selection);

    final form = GlobalKey<FormState>();
    var result = await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          elevation: 0.0,
          insetPadding: const EdgeInsets.all(0),
          child: Container(
            height: 250,
            width: width * 0.85,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: LoadingOverlay(
                isLoading: isLoading,
                color: Colors.white,
                opacity: 0.65,
                progressIndicator: const SpinKitCircle(
                  color: AppColors.nord1,
                  size: 60,
                ),
                child: Container(
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SpaceH18(),
                      Text(
                        StringConst.emailAddress.tr,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SpaceH10(),
                      Text(
                        StringConst.aPasswordResetEmailWillBeSent.tr,
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: StringConst.trtRegular,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const Spacer(),
                      Form(
                        key: form,
                        child: EntryField(
                          hintText: StringConst.email.tr,
                          textInputAction: TextInputAction.done,
                          inputType: TextInputType.emailAddress,
                          controller: emailController,
                          onChanged: (value) {
                            setState(() {
                              forgotEmail = value;
                            });
                          },
                          validator: (value) {
                            if (forgotEmail.trim().isEmpty) {
                              return StringConst.thisFieldIsRequired.tr;
                            }
                            if (!forgotEmail.trim().isEmail) {
                              return StringConst.enterValidEmailAddress.tr;
                            }
                          },
                        ),
                      ),
                      SpaceH24(),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 40,
                              child: ElevatedButton(
                                onPressed: () {
                                  Get.back(result: false);
                                },
                                style: ButtonStyle(
                                  shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                  ),
                                  padding: MaterialStateProperty.all(
                                    const EdgeInsets.all(0.0),
                                  ),
                                ),
                                child: Ink(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: <Color>[
                                        Colors.grey[400],
                                        Colors.grey[400],
                                      ],
                                    ),
                                    borderRadius: const BorderRadius.all(const Radius.circular(5)),
                                  ),
                                  child: Container(
                                    constraints: const BoxConstraints(minWidth: 88.0, minHeight: 36.0),
                                    alignment: Alignment.center,
                                    child: Text(
                                      StringConst.cancel.tr,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SpaceW12(),
                          Expanded(
                            child: Container(
                              height: 40,
                              child: ElevatedButton(
                                onPressed: () async {
                                  final isValid = form.currentState.validate();
                                  if (!isValid) {
                                    return;
                                  }

                                  Utils.unFocus();

                                  setState(() {
                                    isLoading = true;
                                  });

                                  try {
                                    await _api.sendPasswordResetEmail(
                                      email: forgotEmail,
                                    );
                                  } catch (e) {
                                    Get.back();
                                    Utils.showFlushError(context, StringConst.anErrorOccuredMakeSureToTypeEmailCorrectly.tr);
                                    return;
                                  }

                                  Get.back();

                                  Utils.showFlushSuccess(context, StringConst.aPasswordResetEmailHasBeenSent.tr);

                                  setState(() {
                                    isLoading = false;
                                  });
                                },
                                style: ButtonStyle(
                                  shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                  ),
                                  padding: MaterialStateProperty.all(
                                    const EdgeInsets.all(0.0),
                                  ),
                                ),
                                child: Ink(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: <Color>[
                                        AppColors.nord3,
                                        AppColors.nord0,
                                      ],
                                    ),
                                    borderRadius: const BorderRadius.all(const Radius.circular(5)),
                                  ),
                                  child: Container(
                                    constraints: const BoxConstraints(minWidth: 88.0, minHeight: 36.0),
                                    alignment: Alignment.center,
                                    child: Text(
                                      StringConst.sendEmail.tr,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    return result;
  }

  Widget _backButton() {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: const Icon(Icons.keyboard_arrow_left, color: Colors.black),
      ),
    );
  }

  Widget _submitButton() {
    return CustomButton(
      borderRadius: 5,
      title: StringConst.login.tr,
      textStyle: const TextStyle(fontSize: 20, color: Colors.white),
      height: 50,
      onPressed: onSubmit,
    );
  }

  Widget _forgotPasswordWidget() {
    return GestureDetector(
      onTap: () async {
        await showEmailInputDialog(
          context: context,
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.centerRight,
        child: Text(
          StringConst.forgotPassword.tr,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _createAccountLabel() {
    return InkWell(
      onTap: () {
        Get.off(() => SignUpScreen());
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.all(15),
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              StringConst.dontHaveAnAccount.tr,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.grey1),
            ),
            SpaceW10(),
            Text(
              StringConst.register.tr,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _title() {
    return Text(
      StringConst.appName,
      style: const TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        color: AppColors.nord1,
      ),
    );
  }

  Widget _emailPasswordWidget() {
    return Form(
      key: _form,
      child: Column(
        children: <Widget>[
          EntryField(
            focusNode: _emailFocusNode,
            hintText: StringConst.email.tr,
            controller: _emailController,
            icon: const Icon(
              Icons.email,
            ),
            onChanged: (value) {
              setState(() {
                _email = value;
              });
            },
            inputType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            onSubmit: (_) {
              FocusScope.of(context).requestFocus(_passwordFocusNode);
            },
            validator: (value) {
              if (_email.trim().isEmpty) {
                return StringConst.thisFieldIsRequired.tr;
              }
              if (!_email.trim().isEmail) {
                return StringConst.enterValidEmailAddress.tr;
              }
            },
          ),
          SpaceH10(),
          EntryField(
            focusNode: _passwordFocusNode,
            hintText: StringConst.password.tr,
            icon: Icon(Icons.vpn_key),
            controller: _passwordController,
            isPassword: true,
            onChanged: (value) {
              setState(() {
                _password = value;
              });
            },
            validator: (value) {
              if (_password.trim().isEmpty) {
                return StringConst.thisFieldIsRequired.tr;
              }
            },
            onSubmit: (_) {
              onSubmit();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          Utils.unFocus();
        },
        child: SafeArea(
          child: LoadingOverlay(
            isLoading: _isLoading,
            color: Colors.white,
            opacity: 0.65,
            progressIndicator: const SpinKitCircle(
              color: AppColors.nord1,
              size: 60,
            ),
            child: Container(
              height: height,
              child: Stack(
                children: <Widget>[
                  Positioned(
                    top: -height * .15,
                    right: -MediaQuery.of(context).size.width * .4,
                    child: CustomBezierContainer(),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(height: height * .2),
                          _title(),
                          SpaceH50(),
                          _emailPasswordWidget(),
                          SpaceH20(),
                          _submitButton(),
                          _forgotPasswordWidget(),
                          SpaceH12(),
                          _createAccountLabel(),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 20,
                    left: 0,
                    child: _backButton(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
