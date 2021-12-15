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
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  Api _api = locator<Api>();
  bool _isLoading = false;
  String _email = '';
  String _password = '';
  String _passwordAgain = '';
  String _nameSurname = '';

  final _form = GlobalKey<FormState>();

  final FocusNode _nameSurnameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _passwordAgainFocusNode = FocusNode();

  final TextEditingController _nameSurnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordAgainController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameSurnameController.value = TextEditingValue(text: _nameSurname, selection: _nameSurnameController.selection);
    _emailController.value = TextEditingValue(text: _email, selection: _emailController.selection);
    _passwordController.value = TextEditingValue(text: _password, selection: _passwordController.selection);
    _passwordAgainController.value = TextEditingValue(text: _passwordAgain, selection: _passwordAgainController.selection);
  }

  Widget _backButton() {
    return InkWell(
      onTap: () {
        Get.back();
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
      title: StringConst.register.tr,
      textStyle: const TextStyle(
        fontSize: 20,
        color: Colors.white,
      ),
      height: 50,
      onPressed: () async {
        final isValid = _form.currentState.validate();
        if (!isValid) {
          return;
        }

        Utils.unFocus();

        setState(() {
          _isLoading = true;
        });

        try {
          var result = await _api.registerUser(
            email: _email,
            password: _password,
            nameSurname: _nameSurname,
          );
          if (result.error != null) {
            String errorMessage;
            switch (result.error.code) {
              case 'email-already-in-use':
                errorMessage = StringConst.theEnteredEmailAlreadyInUse.tr;
                break;
              case 'weak-password':
                errorMessage = StringConst.passwordMustBeAtLeastSixCharacters.tr;
                break;
              default:
                errorMessage = StringConst.failedToRegister.tr;
                break;
            }
            Utils.showFlushError(context, errorMessage);
          } else {
            Get.off(() => EmailConfirmationScreen());
          }
        } catch (e) {
          Utils.showFlushError(context, StringConst.failedToRegister.tr);
        }

        setState(() {
          _isLoading = false;
        });
      },
    );
  }

  Widget _loginAccountLabel() {
    return InkWell(
      onTap: () {
        Get.off(() => LoginScreen());
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.all(15),
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              StringConst.alreadyHaveAnAccount.tr,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppColors.grey1,
              ),
            ),
            SpaceW10(),
            Text(
              StringConst.login.tr,
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

  Widget _userInfoWidget() {
    return Form(
      key: _form,
      child: Column(
        children: <Widget>[
          EntryField(
            hintText: StringConst.nameSurname.tr,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            focusNode: _nameSurnameFocusNode,
            controller: _nameSurnameController,
            icon: const Icon(Icons.person),
            onChanged: (value) {
              setState(() {
                _nameSurname = value;
              });
            },
            onSubmit: (_) {
              FocusScope.of(context).requestFocus(_emailFocusNode);
            },
            validator: (value) {
              if (_nameSurname.trim().isEmpty) {
                return StringConst.thisFieldIsRequired.tr;
              }
              if (_nameSurname.length > 200) {
                return StringConst.nameSurnameLengthMustBeLowerThan.tr;
              }
            },
          ),
          SpaceH10(),
          EntryField(
            hintText: StringConst.email.tr,
            inputType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            focusNode: _emailFocusNode,
            controller: _emailController,
            icon: const Icon(Icons.email),
            onChanged: (value) {
              setState(() {
                _email = value;
              });
            },
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
            hintText: StringConst.password.tr,
            textInputAction: TextInputAction.next,
            focusNode: _passwordFocusNode,
            controller: _passwordController,
            icon: const Icon(Icons.vpn_key),
            isPassword: true,
            onChanged: (value) {
              setState(() {
                _password = value;
              });
            },
            onSubmit: (_) {
              FocusScope.of(context).requestFocus(_passwordAgainFocusNode);
            },
            validator: (value) {
              if (_password.trim().isEmpty) {
                return StringConst.thisFieldIsRequired.tr;
              }
              if (_password.length < 6) {
                return StringConst.passwordMustBeAtLeastSixCharacters.tr;
              }
              if (_password != _passwordAgain) {
                return StringConst.passwordsDoesNotMatch.tr;
              }
            },
          ),
          SpaceH10(),
          EntryField(
            hintText: StringConst.passwordAgain.tr,
            focusNode: _passwordAgainFocusNode,
            controller: _passwordAgainController,
            textInputAction: TextInputAction.done,
            icon: const Icon(Icons.vpn_key),
            isPassword: true,
            onChanged: (value) {
              setState(() {
                _passwordAgain = value;
              });
            },
            validator: (value) {
              if (_passwordAgain.trim().isEmpty) {
                return StringConst.thisFieldIsRequired.tr;
              }
              if (_password != _passwordAgain) {
                return StringConst.passwordsDoesNotMatch.tr;
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
                    top: -MediaQuery.of(context).size.height * .15,
                    right: -MediaQuery.of(context).size.width * .4,
                    child: const CustomBezierContainer(),
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
                          _userInfoWidget(),
                          SpaceH20(),
                          _submitButton(),
                          SpaceH12(),
                          _loginAccountLabel(),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 40,
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
