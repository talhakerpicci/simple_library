import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:widget_circular_animator/widget_circular_animator.dart';

import '../utils/utils.dart';
import '../values/values.dart';
import '../viewmodels/user_model.dart';
import '../widgets/spaces.dart';

import 'change_password_screen.dart';
import 'image_edit_screen.dart';
import 'change_email_screen.dart';
import 'change_name_surname_screen.dart';
import 'buy_premium_screen.dart';

class UserProfileScreen extends StatefulWidget {
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool _isLoading = false;
  File _imageFile;

  void _settingModalBottomSheet(BuildContext context, UserModel model) {
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      backgroundColor: AppColors.grey2,
      context: context,
      builder: (BuildContext bc) {
        return Container(
          child: Wrap(
            children: <Widget>[
              Column(
                children: <Widget>[
                  SpaceH14(),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.only(left: 15),
                      child: Text(
                        StringConst.profilePhoto.tr,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                  SpaceH14(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        width: 90,
                        child: Column(
                          children: <Widget>[
                            IconButton(
                              icon: const Icon(
                                Icons.photo_size_select_actual,
                                color: Colors.white,
                              ),
                              onPressed: () async {
                                Get.back();
                                if (await Permission.storage.request().isGranted) {
                                  _imageFile = await Utils.captureImage(ImageSource.gallery);
                                  if (_imageFile != null) {
                                    var newImage = await Get.to(
                                      () => ImageEditScreen(
                                        imageFile: _imageFile,
                                        type: 'Galery',
                                        source: 'avatar',
                                        title: 'Avatar',
                                      ),
                                    );
                                    if (newImage != null) {
                                      setState(() {
                                        _isLoading = true;
                                      });
                                      if ((newImage.lengthSync() * pow(10, -6)) > 8) {
                                        Utils.showFlushError(context, StringConst.fileSizeMustBeLowerThanEight.tr);
                                        setState(() {
                                          _imageFile = null;
                                        });
                                      } else {
                                        if (!(await Utils.isOnline())) {
                                          Utils.showFlushError(
                                            context,
                                            StringConst.makeSureYouAreOnline.tr,
                                          );
                                          setState(() {
                                            _isLoading = false;
                                          });
                                          return;
                                        }

                                        var result = await model.updateAvatar(avatar: newImage);
                                        setState(() {
                                          _isLoading = false;
                                        });
                                        if (result) {
                                          Utils.showFlushSuccess(context, StringConst.profilePhotoUpdateSuccess.tr);
                                        } else {
                                          Utils.showFlushError(context, StringConst.errorOccuredWhileUpdating.tr);
                                        }
                                      }
                                    }
                                  }
                                } else if (await Permission.storage.isPermanentlyDenied) {
                                  var state = await Utils.showAlertDialog(context, description: StringConst.toSelectImageGivePermission.tr);
                                  if (state) {
                                    openAppSettings();
                                  }
                                }
                              },
                            ),
                            Text(
                              StringConst.takePhotoFromGallery.tr,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SpaceW10(),
                      Container(
                        width: 90,
                        child: Column(
                          children: <Widget>[
                            IconButton(
                              icon: const Icon(
                                Icons.camera,
                                color: Colors.white,
                              ),
                              onPressed: () async {
                                Get.back();
                                if (await Permission.camera.request().isGranted) {
                                  _imageFile = await Utils.captureImage(ImageSource.camera);
                                  if (_imageFile != null) {
                                    var newImage = await Get.to(
                                      () => ImageEditScreen(
                                        imageFile: _imageFile,
                                        type: 'Camera',
                                        source: 'avatar',
                                        title: 'Avatar',
                                      ),
                                    );
                                    if (newImage != null) {
                                      setState(() {
                                        _isLoading = true;
                                      });
                                      if ((newImage.lengthSync() * pow(10, -6)) > 8) {
                                        Utils.showFlushError(context, StringConst.fileSizeMustBeLowerThanEight.tr);
                                        setState(() {
                                          _imageFile = null;
                                        });
                                      } else {
                                        if (!(await Utils.isOnline())) {
                                          Utils.showFlushError(
                                            context,
                                            StringConst.makeSureYouAreOnline.tr,
                                          );
                                          setState(() {
                                            _isLoading = false;
                                          });
                                          return;
                                        }

                                        var result = await model.updateAvatar(avatar: newImage);
                                        setState(() {
                                          _isLoading = false;
                                        });
                                        if (result) {
                                          Utils.showFlushSuccess(context, StringConst.profilePhotoUpdateSuccess.tr);
                                        } else {
                                          Utils.showFlushError(context, StringConst.errorOccuredWhileUpdating.tr);
                                        }
                                      }
                                      setState(() {
                                        _isLoading = false;
                                      });
                                    }
                                  }
                                } else if (await Permission.camera.isPermanentlyDenied) {
                                  var state = await Utils.showAlertDialog(context, description: StringConst.toUseCameraGivePermission.tr);
                                  if (state) {
                                    openAppSettings();
                                  }
                                }
                              },
                            ),
                            Text(
                              StringConst.takeProfilePhoto.tr,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SpaceW10(),
                      Container(
                        width: 90,
                        child: Column(
                          children: <Widget>[
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                              onPressed: () async {
                                Get.back();
                                if (model.user.image != '') {
                                  setState(() {
                                    _isLoading = true;
                                  });

                                  if (!(await Utils.isOnline())) {
                                    Utils.showFlushError(
                                      context,
                                      StringConst.makeSureYouAreOnline.tr,
                                    );
                                    setState(() {
                                      _isLoading = false;
                                    });
                                    return;
                                  }

                                  var result = await model.deleteAvatar();
                                  setState(() {
                                    _isLoading = false;
                                  });
                                  if (result) {
                                    Utils.showFlushSuccess(context, StringConst.profilePhotoDeleteSuccess.tr);
                                  } else {
                                    Utils.showFlushError(context, StringConst.errorOccuredWhileDeleting.tr);
                                  }
                                }
                              },
                            ),
                            Text(
                              StringConst.deleteProfilePhoto.tr,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: const EdgeInsets.only(top: 15),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var widthOfScreen = MediaQuery.of(context).size.width;
    var model = Provider.of<UserModel>(context, listen: true);
    return Scaffold(
      body: LoadingOverlay(
        isLoading: _isLoading,
        color: Colors.white,
        opacity: 0.65,
        progressIndicator: const SpinKitCircle(
          color: AppColors.nord1,
          size: 60,
        ),
        child: Column(
          children: <Widget>[
            Stack(
              children: <Widget>[
                Image.asset(
                  StringConst.libraryPath,
                  height: 240,
                  width: widthOfScreen,
                  fit: BoxFit.fill,
                ),
                Container(
                  height: 240,
                  padding: const EdgeInsets.only(bottom: 0.0, right: 0.0),
                  alignment: Alignment.topLeft,
                  child: const SafeArea(
                    child: const BackButton(
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 190),
                  child: Column(
                    children: <Widget>[
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey.shade300,
                        child: CircleAvatar(
                          radius: 46,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 42,
                            child: ClipOval(
                              child: Container(
                                width: 90,
                                height: 90,
                                color: Colors.white,
                                child: GestureDetector(
                                  onTap: () {
                                    _settingModalBottomSheet(context, model);
                                  },
                                  child: WidgetCircularAnimator(
                                    innerColor: AppColors.nord0,
                                    outerColor: AppColors.frost3,
                                    child: Container(
                                      width: 70,
                                      height: 70,
                                      margin: const EdgeInsets.all(8),
                                      child: ClipOval(
                                        child: Utils.getAvatarImage(
                                          model.user.image,
                                          Colors.grey[500],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
            SpaceH24(),
            Expanded(
              child: Container(
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      Container(
                        height: 42,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 30,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: AppColors.grey5,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              Get.to(() => ChangeNameSurnameScreen(
                                    nameSurname: model.user.nameSurname,
                                  ));
                            },
                            child: Row(
                              children: <Widget>[
                                SpaceW12(),
                                const Icon(
                                  Icons.person,
                                  size: 18,
                                ),
                                SpaceW20(),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.only(top: 2),
                                    margin: const EdgeInsets.only(right: 10),
                                    child: Text(
                                      '${model.user.nameSurname}',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 14,
                                ),
                                SpaceW12(),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SpaceH12(),
                      Container(
                        height: 42,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 30,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: AppColors.grey5,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              _settingModalBottomSheet(context, model);
                            },
                            child: Row(
                              children: <Widget>[
                                SpaceW12(),
                                const Icon(
                                  Icons.camera,
                                  size: 18,
                                ),
                                SpaceW20(),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.only(top: 2),
                                    margin: const EdgeInsets.only(right: 10),
                                    child: Text(
                                      StringConst.profilePicture.tr,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 14,
                                ),
                                SpaceW12(),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SpaceH12(),
                      Container(
                        height: 42,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 30,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: AppColors.grey5,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              Get.to(() => ChangeEmailScreen());
                            },
                            child: Row(
                              children: <Widget>[
                                SpaceW12(),
                                const Icon(
                                  Icons.email,
                                  size: 18,
                                ),
                                SpaceW20(),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.only(top: 2),
                                    margin: const EdgeInsets.only(right: 10),
                                    child: Text(
                                      '${model.user.email}',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 14,
                                ),
                                SpaceW12(),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SpaceH12(),
                      Container(
                        height: 42,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 30,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: AppColors.grey5,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              Get.to(() => ChangePasswordScreen());
                            },
                            child: Row(
                              children: <Widget>[
                                SpaceW12(),
                                const Icon(
                                  Icons.vpn_key,
                                  size: 18,
                                ),
                                SpaceW20(),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.only(top: 2),
                                    margin: const EdgeInsets.only(right: 10),
                                    child: Text(
                                      StringConst.changePassword.tr,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 14,
                                ),
                                SpaceW12(),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SpaceH12(),
                      Container(
                        height: 42,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 30,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: AppColors.grey5,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              Get.to(() => BuyPremiumScreen(
                                    userId: model.user.id,
                                  ));
                            },
                            child: Row(
                              children: <Widget>[
                                SpaceW12(),
                                const Icon(
                                  Icons.auto_awesome,
                                  size: 18,
                                ),
                                SpaceW20(),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.only(top: 2),
                                    margin: const EdgeInsets.only(right: 10),
                                    child: Text(
                                      StringConst.upgradeToPremium.tr,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 14,
                                ),
                                SpaceW12(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
