import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:loading_overlay/loading_overlay.dart';

import '../locator.dart';
import '../services/api.dart';
import '../utils/utils.dart';
import '../values/values.dart';
import '../widgets/spaces.dart';

class CustomPasswordInputDialog extends StatefulWidget {
  final String email;
  CustomPasswordInputDialog({this.email});
  @override
  _CustomPasswordInputDialogState createState() => _CustomPasswordInputDialogState();
}

class _CustomPasswordInputDialogState extends State<CustomPasswordInputDialog> {
  Api _api = locator<Api>();
  String _password;
  bool _isLoading = false;

  Widget _entryField(String title, {bool isPassword = false, Function onChanged}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(
            height: 10,
          ),
          TextField(
            obscureText: isPassword,
            decoration: const InputDecoration(
              border: InputBorder.none,
              fillColor: Color(0xfff3f3f4),
              filled: true,
            ),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  dialogContent(BuildContext context, double width, double height) {
    return Container(
      height: height * 0.4,
      width: width * 0.85,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: LoadingOverlay(
          isLoading: _isLoading,
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
                  StringConst.confirmPassword.tr,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                _entryField(StringConst.enterPassword.tr, isPassword: true, onChanged: (value) {
                  setState(() {
                    _password = value;
                  });
                }),
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
                            Utils.unFocus();

                            setState(() {
                              _isLoading = true;
                            });

                            try {
                              var result = await _api.signInUser(
                                email: widget.email,
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
                              }
                              if (result.success) {
                                setState(() {
                                  _isLoading = false;
                                });
                                Get.back(result: true);
                              } else {
                                setState(() {
                                  _isLoading = false;
                                });
                                Utils.showFlushError(context, StringConst.anErrorOccured.tr);
                              }
                            } catch (e) {
                              Utils.showFlushError(context, StringConst.anErrorOccured.tr);
                            }

                            setState(() {
                              _isLoading = false;
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
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: const <Color>[
                                  Colors.red,
                                  Colors.red,
                                ],
                              ),
                              borderRadius: const BorderRadius.all(const Radius.circular(5)),
                            ),
                            child: Container(
                              constraints: const BoxConstraints(minWidth: 88.0, minHeight: 36.0),
                              alignment: Alignment.center,
                              child: Text(
                                StringConst.delete.tr,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    var widthOfScreen = MediaQuery.of(context).size.width;
    var heightOfScreen = MediaQuery.of(context).size.height;
    return WillPopScope(
      onWillPop: () {
        Get.back(result: false);
        return Future.value(true);
      },
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        elevation: 0.0,
        insetPadding: const EdgeInsets.all(0),
        child: dialogContent(
          context,
          widthOfScreen,
          heightOfScreen,
        ),
      ),
    );
  }
}
