import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

import '../locator.dart';
import '../services/api.dart';
import '../utils/utils.dart';
import '../values/values.dart';
import '../widgets/spaces.dart';
import '../viewmodels/user_model.dart';
import '../dialogs/custom_yes_no_dialog.dart';
import '../widgets/custom_entry_field.dart';

class ChangePasswordScreen extends StatefulWidget {
  ChangePasswordScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();

  final _form = GlobalKey<FormState>();

  Api _api = locator<Api>();
  bool _isLoading = false;
  bool _showIndicator = false;
  String _oldPassword = '';
  String _newPassword = '';
  String _newPasswordAgain = '';

  final FocusNode oldPasswordFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  final FocusNode passwordAgainFocusNode = FocusNode();

  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordAgainController = TextEditingController();

  Widget _backButton() {
    return InkWell(
      onTap: () {
        if (!_isLoading) {
          Get.back();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: const Icon(Icons.keyboard_arrow_left, color: Colors.white),
      ),
    );
  }

  Widget _submitButton() {
    var model = Provider.of<UserModel>(context, listen: false);
    return Container(
      child: RoundedLoadingButton(
        height: 45,
        borderRadius: 50,
        color: AppColors.nord0,
        child: Ink(
          decoration: const BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const <Color>[
                AppColors.nord3,
                AppColors.nord0,
              ],
            ),
            borderRadius: const BorderRadius.all(const Radius.circular(30)),
          ),
          child: Container(
            constraints: const BoxConstraints(minWidth: 88.0, minHeight: 36.0),
            alignment: Alignment.center,
            child: Text(
              StringConst.update.tr,
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        controller: _btnController,
        animateOnTap: false,
        onPressed: () async {
          final isValid = _form.currentState.validate();
          if (!isValid) {
            return;
          }

          Utils.unFocus();

          bool success = false;
          setState(() {
            _isLoading = true;
          });

          _btnController.start();

          var result = await model.reAuth(email: model.user.email, password: _oldPassword);

          if (result.success) {
            var result2 = await model.updatePassword(
              newPassword: _newPassword,
            );
            if (result2) {
              success = true;
              _btnController.success();
              oldPasswordController.clear();
              passwordController.clear();
              passwordAgainController.clear();
              Utils.showFlushSuccess(context, StringConst.passwordUpdateSuccess.tr);
            } else {
              Utils.showFlushError(context, StringConst.anErrorOccured.tr);
            }
          } else {
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
                case 'too-many-requests':
                  errorMessage = StringConst.madeTooMuchAttempts.tr;
                  break;
                default:
                  errorMessage = StringConst.failedToReAuth.tr;
                  break;
              }
              Utils.showFlushError(context, errorMessage);
            } else {
              Utils.showFlushError(context, StringConst.anErrorOccured.tr);
            }
          }

          setState(() {
            _isLoading = false;
          });

          if (!success) {
            _btnController.error();
            await Future.delayed(const Duration(milliseconds: 2000));
            _btnController.reset();
          }
        },
      ),
    );
  }

  Widget _passwrodWidgets() {
    return Form(
      key: _form,
      child: Column(
        children: <Widget>[
          SpaceH14(),
          EntryField(
            hintText: StringConst.currentPassword.tr,
            textInputAction: TextInputAction.next,
            focusNode: oldPasswordFocusNode,
            controller: oldPasswordController,
            isPassword: true,
            icon: const Icon(
              Icons.lock,
              color: AppColors.nord0,
            ),
            onChanged: (value) {
              setState(() {
                _oldPassword = value;
              });
            },
            onSubmit: (_) {
              FocusScope.of(context).requestFocus(passwordFocusNode);
            },
            validator: (value) {
              if (_oldPassword.trim().isEmpty) {
                return StringConst.thisFieldIsRequired.tr;
              }
            },
          ),
          SpaceH14(),
          EntryField(
            hintText: StringConst.newPassword.tr,
            textInputAction: TextInputAction.next,
            focusNode: passwordFocusNode,
            controller: passwordController,
            isPassword: true,
            icon: const Icon(
              Icons.lock,
              color: AppColors.nord0,
            ),
            onChanged: (value) {
              setState(() {
                _newPassword = value;
              });
            },
            onSubmit: (_) {
              FocusScope.of(context).requestFocus(passwordAgainFocusNode);
            },
            validator: (value) {
              if (_newPassword.trim().isEmpty) {
                return StringConst.thisFieldIsRequired.tr;
              }
              if (_newPassword != _newPasswordAgain) {
                return StringConst.passwordsDoesNotMatch.tr;
              }
              if (_newPassword.length < 6) {
                return StringConst.passwordMustBeAtLeastSixCharacters.tr;
              }
            },
          ),
          SpaceH14(),
          EntryField(
            hintText: StringConst.newPasswordAgain.tr,
            textInputAction: TextInputAction.done,
            controller: passwordAgainController,
            focusNode: passwordAgainFocusNode,
            isPassword: true,
            icon: const Icon(
              Icons.lock,
              color: AppColors.nord0,
            ),
            onChanged: (value) {
              setState(() {
                _newPasswordAgain = value;
              });
            },
            validator: (value) {
              if (_newPasswordAgain.trim().isEmpty) {
                return StringConst.thisFieldIsRequired.tr;
              }
              if (_newPassword != _newPasswordAgain) {
                return StringConst.passwordsDoesNotMatch.tr;
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _forgotPasswordWidget() {
    return GestureDetector(
      onTap: () async {
        String email = Provider.of<UserModel>(context, listen: false).user.email;
        var result = await showDialog(
          builder: (context) => CustomYesNoDialog(
            buttonTitleLeft: StringConst.yes.tr,
            buttonTitleRight: StringConst.no.tr,
            message: StringConst.customTranslation(
              key: StringConst.passwordResetWillBeSentTo,
              data: email,
            ),
          ),
          context: context,
        );
        if (result != null && result) {
          setState(() {
            _showIndicator = true;
          });

          if (!(await Utils.isOnline())) {
            Utils.showFlushError(
              context,
              StringConst.makeSureYouAreOnline.tr,
            );
            setState(() {
              _showIndicator = false;
            });
            return;
          }

          await _api.sendPasswordResetEmail(email: email);
          Utils.showFlushInfo(context, StringConst.aPasswordResetEmailHasBeenSent.tr);
          setState(() {
            _showIndicator = false;
          });
        }
      },
      child: Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Text(
            StringConst.forgotPassword.tr,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: LoadingOverlay(
        isLoading: _showIndicator,
        color: Colors.white,
        opacity: 0.65,
        progressIndicator: const SpinKitCircle(
          color: AppColors.nord1,
          size: 60,
        ),
        child: GestureDetector(
          onTap: () {
            Utils.unFocus();
          },
          child: Stack(
            children: [
              Container(
                height: height,
                child: Column(
                  children: <Widget>[
                    Container(
                      width: width,
                      height: height / 3,
                      decoration: const BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: const [
                            AppColors.nord3,
                            AppColors.nord0,
                          ],
                        ),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: const Radius.circular(90),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Spacer(),
                          Padding(
                            padding: const EdgeInsets.only(top: 50.0),
                            child: const Align(
                              alignment: Alignment.center,
                              child: Text(
                                StringConst.appName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 38,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const Spacer(),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 32, right: 32),
                              child: Text(
                                StringConst.changePassword.tr,
                                style: const TextStyle(color: Colors.white, fontSize: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        child: ListView(
                          children: <Widget>[
                            _passwrodWidgets(),
                            _forgotPasswordWidget(),
                            SpaceH20(),
                            _submitButton(),
                            SpaceH20(),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Positioned(
                top: 30,
                left: 0,
                child: _backButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
