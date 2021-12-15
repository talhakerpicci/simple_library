import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../values/values.dart';
import '../widgets/spaces.dart';
import '../utils/utils.dart';
import '../viewmodels/db_model.dart';

import 'info_screen.dart';
import 'sign_up_screen.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatefulWidget {
  final String message;
  final bool removeNotifs;
  WelcomeScreen({
    this.message,
    this.removeNotifs = false,
  });
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.message != null) {
        Utils.showInfoDialog(context, message: widget.message);
      }

      if (widget.removeNotifs) {
        var dbModel = Provider.of<DbModel>(context, listen: false);
        await dbModel.deleteAllReminders();
        await dbModel.canceAllNotifications();
      }
    });
  }

  Widget _logo({double height, double width}) {
    return Image.asset(
      StringConst.iconPath,
      width: width,
      height: height * 0.25,
      color: Colors.white,
    );
  }

  Widget _loginButton() {
    return InkWell(
      onTap: () {
        Get.to(() => LoginScreen());
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(vertical: 13),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(
            const Radius.circular(5),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.white.withAlpha(100),
              offset: const Offset(2, 4),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
          color: Colors.white,
        ),
        child: Text(
          StringConst.login.tr,
          style: const TextStyle(
            fontSize: 20,
            color: AppColors.nord0,
          ),
        ),
      ),
    );
  }

  Widget _signUpButton() {
    return InkWell(
      onTap: () {
        Get.to(() => SignUpScreen());
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(vertical: 13),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(5)),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Text(
          StringConst.register.tr,
          style: const TextStyle(
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _title() {
    return AutoSizeText(
      StringConst.appName,
      style: const TextStyle(
        fontSize: 42,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        fontFamily: StringConst.trtRegular,
      ),
    );
  }

  Widget _infoButton() {
    return GestureDetector(
      onTap: () {
        Get.to(() => InfoScreen());
      },
      child: Text(
        StringConst.faqs.tr,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.white,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: const <Color>[
            AppColors.grey0,
            AppColors.grey1,
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          width: width,
          height: height,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Container(
                height: height * 0.1,
              ),
              Container(
                height: height * 0.5,
                child: Column(
                  children: [
                    _logo(
                      height: height,
                      width: width,
                    ),
                    SpaceH30(),
                    _title(),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _loginButton(),
                      SpaceH20(),
                      _signUpButton(),
                      SpaceH20(),
                      _infoButton(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
