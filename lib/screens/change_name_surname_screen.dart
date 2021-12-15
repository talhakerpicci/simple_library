import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

import '../widgets/custom_entry_field.dart';
import '../utils/utils.dart';
import '../values/values.dart';
import '../widgets/spaces.dart';
import '../viewmodels/user_model.dart';

class ChangeNameSurnameScreen extends StatefulWidget {
  final String nameSurname;

  ChangeNameSurnameScreen({this.nameSurname});
  @override
  _ChangeNameSurnameScreenState createState() => _ChangeNameSurnameScreenState();
}

class _ChangeNameSurnameScreenState extends State<ChangeNameSurnameScreen> {
  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();

  final _form = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _showIndicator = false;

  String _newNameSurname = '';

  final FocusNode _nameSurnameFocusNode = FocusNode();

  final TextEditingController _nameSurnameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _newNameSurname = widget.nameSurname;
    _nameSurnameController.value = TextEditingValue(text: _newNameSurname, selection: _nameSurnameController.selection);
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

          if (_newNameSurname == widget.nameSurname) {
            Get.back();
            return;
          }

          bool success = false;
          setState(() {
            _isLoading = true;
          });

          _btnController.start();

          try {
            var result = await model.updateNameSurname(nameSurname: _newNameSurname);
            if (result) {
              success = true;
              _btnController.success();
              Utils.showFlushSuccess(context, StringConst.yourInfoHasBeenUpdated.tr);
            } else {
              Utils.showFlushError(context, StringConst.anErrorOccured.tr);
            }
          } catch (e) {
            Utils.showFlushError(context, StringConst.anErrorOccured.tr);
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

  Widget _nameSurnameWidget() {
    return Form(
      key: _form,
      child: EntryField(
        hintText: StringConst.nameSurname.tr,
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.done,
        focusNode: _nameSurnameFocusNode,
        controller: _nameSurnameController,
        icon: Icon(Icons.person),
        onChanged: (value) {
          setState(() {
            _newNameSurname = value;
          });
        },
        validator: (value) {
          if (_newNameSurname.trim().isEmpty) {
            return StringConst.thisFieldIsRequired.tr;
          }
          if (_newNameSurname.length > 200) {
            return StringConst.nameSurnameLengthMustBeLowerThan.tr;
          }
        },
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
                              child: const Text(
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
                                StringConst.updateProfile.tr,
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
                            _nameSurnameWidget(),
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
