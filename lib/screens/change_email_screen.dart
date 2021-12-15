import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

import '../dialogs/custom_warning_dialog.dart';
import '../services/api.dart';
import '../widgets/custom_entry_field.dart';
import '../locator.dart';
import '../utils/utils.dart';
import '../values/values.dart';
import '../widgets/spaces.dart';
import '../viewmodels/user_model.dart';

import 'welcome_screen.dart';

class ChangeEmailScreen extends StatefulWidget {
  @override
  _ChangeEmailScreenState createState() => _ChangeEmailScreenState();
}

class _ChangeEmailScreenState extends State<ChangeEmailScreen> {
  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();

  final _form = GlobalKey<FormState>();

  bool _isLoading = false;

  String _newEmail = '';
  String _password = '';

  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _emailController.value = TextEditingValue(text: _newEmail, selection: _emailController.selection);
    _passwordController.value = TextEditingValue(text: _password, selection: _passwordController.selection);
  }

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
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const <Color>[
                AppColors.nord3,
                AppColors.nord0,
              ],
            ),
            borderRadius: const BorderRadius.all(Radius.circular(30)),
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

          var proceed = await showDialog(
            builder: (context) => WarningDialog(
              header: StringConst.warning.tr,
              message: StringConst.youWillHaveToReLogin.tr,
            ),
            context: context,
          );

          if (proceed != null && proceed) {
            bool success = false;
            setState(() {
              _isLoading = true;
            });

            _btnController.start();

            var result = await model.reAuth(email: model.user.email, password: _password);

            if (result.success) {
              var result2 = await model.updateEmail(newEmail: _newEmail);

              if (result2) {
                success = true;
                _btnController.success();

                model.clearUserData();

                imageCache.clear();
                imageCache.clearLiveImages();

                await locator<Api>().signOut();

                Get.offAll(() => WelcomeScreen(
                      message: StringConst.customTranslation(
                        key: StringConst.emailUpdateInfo,
                        data: _newEmail,
                      ),
                    ));
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
          }
        },
      ),
    );
  }

  Widget _entryFields() {
    var model = Provider.of<UserModel>(context, listen: false);
    return Form(
      key: _form,
      child: Column(
        children: [
          EntryField(
            hintText: StringConst.newEmail.tr,
            inputType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            focusNode: _emailFocusNode,
            controller: _emailController,
            icon: const Icon(
              Icons.email,
              color: AppColors.nord0,
            ),
            onChanged: (value) {
              setState(() {
                _newEmail = value;
              });
            },
            onSubmit: (_) {
              FocusScope.of(context).requestFocus(_passwordFocusNode);
            },
            validator: (value) {
              if (_newEmail.trim().isEmpty) {
                return StringConst.thisFieldIsRequired.tr;
              }
              if (!_newEmail.trim().isEmail) {
                return StringConst.enterValidEmailAddress.tr;
              }
              if (_newEmail.trim() == model.user.email) {
                return StringConst.enterDifferentEmail.tr;
              }
            },
          ),
          SpaceH14(),
          EntryField(
            hintText: StringConst.currentPassword.tr,
            textInputAction: TextInputAction.done,
            focusNode: _passwordFocusNode,
            controller: _passwordController,
            isPassword: true,
            icon: const Icon(
              Icons.lock,
              color: AppColors.nord0,
            ),
            onChanged: (value) {
              setState(() {
                _password = value;
              });
            },
            validator: (value) {
              if (_password.trim().isEmpty) {
                return StringConst.thisFieldIsRequired.tr;
              }
              if (_password.length < 6) {
                return StringConst.passwordMustBeAtLeastSixCharacters.tr;
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: GestureDetector(
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
                          child: Align(
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
                              StringConst.updateEmail.tr,
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
                          SpaceH60(),
                          _entryFields(),
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
    );
  }
}
